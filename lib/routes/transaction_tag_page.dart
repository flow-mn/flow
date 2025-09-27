import "dart:io";

import "package:flow/data/flow_icon.dart";
import "package:flow/data/transaction_contact_tag.dart";
import "package:flow/entity/transaction/tag_type.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/form_validators.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/extensions/transaction_tag_type.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/open_street_map.dart";
import "package:flow/widgets/select_color_scheme_list_tile.dart";
import "package:flow/widgets/sheets/select_contact_sheet.dart";
import "package:flow/widgets/sheets/select_flow_icon_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter_contacts/contact.dart";
import "package:geolocator/geolocator.dart";
import "package:go_router/go_router.dart";
import "package:latlong2/latlong.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:permission_handler/permission_handler.dart";

class TransactionTagPage extends StatefulWidget {
  final int tagId;

  bool get isNewTag => tagId == 0;

  const TransactionTagPage({super.key, required this.tagId});
  const TransactionTagPage.create({super.key}) : tagId = 0;

  @override
  State<TransactionTagPage> createState() => _TransactionTagPageState();
}

class _TransactionTagPageState extends State<TransactionTagPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _titleController;

  late TransactionTagType _type;

  late TransactionTag? _currentlyEditing;

  Object? _payload;

  bool _locationBusy = false;

  String? _colorSchemeName;

  FlowIconData? _iconData;

  String get iconCodeOrError =>
      _iconData?.toString() ?? FlowIconData.icon(_type.icon).toString();

  @override
  void initState() {
    super.initState();

    if (widget.isNewTag) {
      _titleController = TextEditingController();
      _type = TransactionTagType.generic;
    } else {
      _currentlyEditing = ObjectBox().box<TransactionTag>().get(widget.tagId);
      _titleController = TextEditingController(text: _currentlyEditing?.title);
      _type = _currentlyEditing?.tagType ?? TransactionTagType.generic;
      _payload = TransactionTag.parsePayload(_type, _currentlyEditing?.payload);
      _colorSchemeName = _currentlyEditing?.colorSchemeName;
      _iconData = _currentlyEditing?.icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets contentPadding = EdgeInsets.symmetric(horizontal: 16.0);

    final LatLng center = switch ((_type, _payload)) {
      (TransactionTagType.location, List<double> coords)
          when coords.length == 2 =>
        LatLng(coords[0], coords[1]),
      _ => LatLng(47.9184, 106.9175), // Ulaanbaatar center
    };

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40.0,
        leading: FormCloseButton(canPop: () => !hasChanged()),
        actions: [
          IconButton(
            onPressed: () => save(),
            icon: const Icon(Symbols.check_rounded),
            tooltip: "general.save".t(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16.0),
                FlowIcon(
                  _iconData ?? CharacterFlowIcon("T"),
                  size: 80.0,
                  plated: true,
                  onTap: selectIcon,
                  colorScheme: getThemeStrict(_colorSchemeName),
                ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.topLeft,
                  child: SingleChildScrollView(
                    padding: contentPadding,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 12.0,
                      mainAxisSize: MainAxisSize.min,
                      children: TransactionTagType.values
                          .map(
                            (type) => FilterChip(
                              avatar: Icon(type.icon),
                              label: Text(type.localizedNameContext(context)),
                              showCheckmark: false,
                              selected: _type == type,
                              onSelected: (selected) =>
                                  selected ? _updateType(type) : null,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: contentPadding,
                  child: TextFormField(
                    controller: _titleController,
                    maxLength: TransactionTag.maxTitleLength,
                    validator: validateRequiredField,
                    decoration: InputDecoration(
                      label: Text(switch (_type) {
                        TransactionTagType.generic => "transaction.tags.name".t(
                          context,
                        ),
                        TransactionTagType.location =>
                          "transaction.tags.location.name".t(context),
                        TransactionTagType.contact =>
                          "transaction.tags.contact.name".t(context),
                      }),
                      focusColor: context.colorScheme.secondary,
                      counter: const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                if (_type == TransactionTagType.location)
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: OpenStreetMap(
                      center: center,
                      onTap: (point) {
                        _updatePayload(point);
                      },
                    ),
                  ),
                if (_type == TransactionTagType.location)
                  ListTile(
                    enabled: !_locationBusy,
                    leading: Icon(Symbols.my_location_rounded),
                    onTap: _useMyLocation,
                    title: Text(
                      "transaction.tags.location.useCurrent".t(context),
                    ),
                    trailing: DirectionalChevron(),
                  ),
                if ((Platform.isAndroid || Platform.isIOS) &&
                    _type == TransactionTagType.contact) ...[
                  ListTile(
                    leading: Icon(Symbols.contact_page_rounded),
                    onTap: _selectContact,
                    title: Text("transaction.tags.contact.select".t(context)),
                    trailing: DirectionalChevron(),
                  ),
                  Frame(
                    child: InfoText(
                      child: Text(
                        "preferences.transactions.tags.contactUsageDescription"
                            .t(context),
                      ),
                    ),
                  ),
                ],
                SelectColorSchemeListTile(
                  colorScheme: _colorSchemeName,
                  onChanged: (scheme) =>
                      setState(() => _colorSchemeName = scheme?.name),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> selectIcon() async {
    final result = await showModalBottomSheet<FlowIconData>(
      context: context,
      builder: (context) => SelectFlowIconSheet(current: _iconData),
      isScrollControlled: true,
    );

    if (result != null) {
      _iconData = result;
    }

    if (mounted) setState(() {});
  }

  void _updateType(TransactionTagType newType) {
    if (newType == _type) return;

    if (_iconData == null ||
        FlowIconData.icon(_type.icon).toString() == _iconData.toString()) {
      _iconData = FlowIconData.icon(newType.icon);
    }
    _type = newType;

    setState(() {});
  }

  void _updatePayload(Object? payload) {
    _payload = switch (payload) {
      Position position => payload = List<double>.from([
        position.latitude,
        position.longitude,
      ], growable: false),
      LatLng latLng => payload = List<double>.from([
        latLng.latitude,
        latLng.longitude,
      ], growable: false),
      Contact contact => payload = TransactionContactTag(
        id: contact.id,
        name: contact.displayName,
      ),
      _ => null,
    };

    if (mounted) {
      setState(() {});
    }
  }

  void _useMyLocation() async {
    if (_locationBusy) return;

    setState(() {
      _locationBusy = true;
    });

    try {
      final PermissionStatus status = await Permission.locationWhenInUse
          .request();

      switch (status) {
        case PermissionStatus.limited:
        case PermissionStatus.granted:
          break;
        default:
          {
            if (mounted) {
              context.showErrorToast(
                error: "preferences.transactions.geo.auto.permissionDenied".t(
                  context,
                ),
              );
            }
            return;
          }
      }

      final position = await Geolocator.getCurrentPosition();
      _updatePayload(position);
    } finally {
      _locationBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _selectContact([bool requestPermission = true]) async {
    if (_type != TransactionTagType.contact) return;

    final PermissionStatus permissionStatus = await Permission.contacts
        .request();

    switch (permissionStatus) {
      case PermissionStatus.limited:
      case PermissionStatus.granted:
        break;
      default:
        {
          if (mounted) {
            context.showErrorToast(
              error:
                  "preferences.transactions.tags.enablePhoneContacts.permissionDenied"
                      .t(context),
            );
          }
          return;
        }
    }

    if (!mounted) return;

    final Optional<Contact>? selectedContact =
        await showModalBottomSheet<Optional<Contact>>(
          context: context,
          isScrollControlled: true,
          builder: (context) => const SelectContactSheet(),
        );

    final Contact? contact = selectedContact?.value;

    if (contact != null) {
      _updatePayload(contact);
      _titleController.text = contact.displayName;
      if (_iconData == null ||
          FlowIconData.icon(_type.icon).toString() == _iconData.toString()) {
        final ImageFlowIcon? contactImage = await ImageFlowIcon.tryFromData(
          contact.photo,
        );

        if (contactImage != null) {
          _iconData = contactImage;
        }
      }
    }
  }

  bool hasChanged() {
    if (widget.isNewTag) {
      return _titleController.text.isNotEmpty ||
          _payload != null ||
          _colorSchemeName != null ||
          _type != TransactionTagType.generic;
    }

    return _titleController.text != (_currentlyEditing?.title ?? "") ||
        _type != (_currentlyEditing?.tagType ?? TransactionTagType.generic) ||
        _colorSchemeName != _currentlyEditing?.colorSchemeName ||
        _payload != _currentlyEditing?.payload;
  }

  void update(String formattedName) async {
    if (_currentlyEditing == null) return;

    _currentlyEditing!
      ..title = formattedName
      ..type = _type.value
      ..colorSchemeName = _colorSchemeName
      ..payload = TransactionTag.serializePayload(_payload);

    ObjectBox().box<TransactionTag>().put(
      _currentlyEditing!,
      mode: PutMode.update,
    );

    context.pop();
  }

  void save() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final String formattedName = _titleController.text.trim();

    if (!widget.isNewTag) {
      return update(formattedName);
    }

    final TransactionTag tag = TransactionTag(
      title: formattedName,
      type: _type.value,
      payload: TransactionTag.serializePayload(_payload),
      colorSchemeName: _colorSchemeName,
    );

    ObjectBox().box<TransactionTag>().put(tag, mode: PutMode.insert);

    context.pop();
  }
}
