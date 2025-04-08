import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/base.dart";
import "package:flow/entity/transaction/extensions/default/geo.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/transaction_page/description_section.dart";
import "package:flow/routes/transaction_page/input_amount_sheet.dart";
import "package:flow/routes/transaction_page/section.dart";
import "package:flow/routes/transaction_page/select_account_sheet.dart";
import "package:flow/routes/transaction_page/select_category_sheet.dart";
import "package:flow/routes/transaction_page/title_input.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/transactions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/location_picker_sheet.dart";
import "package:flow/widgets/square_map.dart";
import "package:flow/widgets/transaction/type_selector.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/services.dart";
import "package:flutter_map/flutter_map.dart";
import "package:geolocator/geolocator.dart";
import "package:go_router/go_router.dart";
import "package:latlong2/latlong.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

final Logger _log = Logger("TransactionPage");

class TransactionPage extends StatefulWidget {
  /// Transaction Object ID
  final int transactionId;

  final TransactionType? initialTransactionType;

  bool get isNewTransaction => transactionId == 0;

  const TransactionPage.create({
    super.key,
    this.initialTransactionType = TransactionType.expense,
  }) : transactionId = 0;
  const TransactionPage.edit({super.key, required this.transactionId})
    : initialTransactionType = null;

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late TransactionType _transactionType;

  bool get isTransfer => _transactionType == TransactionType.transfer;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late double _amount;

  double _conversionRate = 1.0;

  late final Transaction? _currentlyEditing;

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _selectAccountFocusNode = FocusNode();
  final FocusNode _selectAccountTransferToFocusNode = FocusNode();

  late final List<Account> accounts;
  late final List<Category> categories;

  Geo? _geo;
  bool _geoHandpicked = false;

  bool locationFailed = false;

  dynamic error;

  Account? _selectedAccount;
  Category? _selectedCategory;

  Account? _selectedAccountTransferTo;

  List<RelevanceScoredTitle>? autofillHints;

  late DateTime _transactionDate;

  late final bool enableGeo;

  late final MapController? _mapController;

  bool get crossCurrencyTransfer =>
      isTransfer &&
      _selectedAccount != null &&
      _selectedAccountTransferTo != null &&
      _selectedAccount!.currency != _selectedAccountTransferTo!.currency;

  @override
  void initState() {
    super.initState();

    accounts = ObjectBox().getAccounts();
    categories = ObjectBox().getCategories();

    /// Transaction we're editing.
    _currentlyEditing =
        widget.isNewTransaction
            ? null
            : TransactionsService()
                .getOneSync(widget.transactionId)
                ?.findTransferOriginalOrThis();

    if (!widget.isNewTransaction && _currentlyEditing == null) {
      error = "Transaction with id ${widget.transactionId} was not found";
    } else {
      _titleController = TextEditingController(
        text: _currentlyEditing?.title ?? "",
      );
      _descriptionController = TextEditingController(
        text: _currentlyEditing?.description ?? "",
      );
      _selectedAccount = _currentlyEditing?.account.target;
      _selectedCategory = _currentlyEditing?.category.target;
      _transactionDate = _currentlyEditing?.transactionDate ?? DateTime.now();
      _transactionType =
          _currentlyEditing?.type ??
          widget.initialTransactionType ??
          TransactionType.expense;
      _amount =
          _currentlyEditing?.isTransfer == true
              ? _currentlyEditing!.amount.abs()
              : _currentlyEditing?.amount ??
                  (_transactionType == TransactionType.expense ? -0 : 0);
      _selectedAccountTransferTo = accounts.firstWhereOrNull(
        (account) =>
            account.uuid ==
            _currentlyEditing?.extensions.transfer?.toAccountUuid,
      );
      _geo = _currentlyEditing?.extensions.geo;
      if (_currentlyEditing?.isTransfer == true) {
        _conversionRate =
            _currentlyEditing!.extensions.transfer?.conversionRate ?? 1.0;
      }
    }

    enableGeo = LocalPreferences().enableGeo.get();

    _mapController = enableGeo ? MapController() : null;

    if (widget.isNewTransaction) {
      tryFetchLocation();
    }

    if (widget.isNewTransaction) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        selectAccount();
      });
    }
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _selectAccountFocusNode.dispose();
    _selectAccountTransferToFocusNode.dispose();

    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    final bool showPostTransactionBalance =
        _selectedAccount != null && !widget.isNewTransaction;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () => pop(),
          osSingleActivator(LogicalKeyboardKey.enter): () => save(),
          osSingleActivator(LogicalKeyboardKey.numpadEnter): () => save(),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
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
              title: TypeSelector(
                current: _transactionType,
                onChange: updateTransactionType,
                canEdit:
                    _currentlyEditing == null ||
                    _currentlyEditing.isTransfer == false,
              ),
              titleTextStyle: context.textTheme.bodyLarge,
              centerTitle: true,
              backgroundColor: context.colorScheme.surface,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  canPop: !hasChanged(),
                  child: Column(
                    children: [
                      const SizedBox(height: 24.0),
                      TitleInput(
                        focusNode: _titleFocusNode,
                        controller: _titleController,
                        transactionType: _transactionType,
                        selectedAccountId: _selectedAccount?.id,
                        selectedCategoryId: _selectedCategory?.id,
                        amount: _amount,
                        currency: _selectedAccount?.currency,
                        transactionDate: _transactionDate,
                        fallbackTitle: fallbackTitle,
                        onSubmitted: (_) => save(),
                      ),
                      const SizedBox(height: 24.0),
                      Center(
                        child: InkWell(
                          onTap: inputAmount,
                          child: Center(
                            child: Text(
                              Money(
                                _amount,
                                _selectedAccount?.currency ?? primaryCurrency,
                              ).formatMoney(),
                              style: context.textTheme.displayMedium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      // From account
                      Section(
                        title:
                            isTransfer
                                ? "transaction.transfer.from".t(context)
                                : "account".t(context),
                        child: Column(
                          children: [
                            ListTile(
                              leading:
                                  _selectedAccount == null
                                      ? null
                                      : FlowIcon(
                                        _selectedAccount!.icon,
                                        plated: true,
                                      ),
                              title: Text(
                                _selectedAccount?.name ??
                                    "transaction.edit.selectAccount".t(context),
                              ),
                              subtitle:
                                  showPostTransactionBalance
                                      ? MoneyText(
                                        _selectedAccount!.balanceAt(
                                          _transactionDate,
                                        ),
                                      )
                                      : null,
                              onTap: () => selectAccount(),
                              trailing:
                                  _selectedAccount == null
                                      ? const Icon(Symbols.chevron_right)
                                      : null,
                              focusNode: _selectAccountFocusNode,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      // To account
                      if (isTransfer) ...[
                        Section(
                          title: "transaction.transfer.to".t(context),
                          child: ListTile(
                            leading:
                                _selectedAccountTransferTo == null
                                    ? null
                                    : FlowIcon(
                                      _selectedAccountTransferTo!.icon,
                                      plated: true,
                                    ),
                            title: Text(
                              _selectedAccountTransferTo?.name ??
                                  "transaction.edit.selectAccount".t(context),
                            ),
                            subtitle:
                                _selectedAccountTransferTo != null
                                    ? MoneyText(
                                      _selectedAccountTransferTo!.balanceAt(
                                        _transactionDate,
                                      ),
                                    )
                                    : null,
                            onTap: () => selectAccountTransferTo(),
                            trailing:
                                _selectedAccountTransferTo == null
                                    ? const Icon(Symbols.chevron_right)
                                    : null,
                            focusNode: _selectAccountTransferToFocusNode,
                          ),
                        ),
                        if (crossCurrencyTransfer) ...[
                          const SizedBox(height: 24.0),
                          Section(
                            title: "transaction.transfer.conversionRate".t(
                              context,
                            ),
                            child: ListTile(
                              title: Text(
                                "${Money(1.0, _selectedAccount!.currency).formatMoney()} = ${Money(_conversionRate, _selectedAccountTransferTo!.currency).formatMoney()}",
                              ),
                              onTap: () => inputPostConversionAmount(),
                              trailing:
                                  _selectedAccountTransferTo == null
                                      ? const Icon(Symbols.chevron_right)
                                      : null,
                              focusNode: _selectAccountTransferToFocusNode,
                            ),
                          ),
                        ],
                      ],
                      // Category
                      if (!isTransfer)
                        Section(
                          title: "category".t(context),
                          child: ListTile(
                            leading:
                                _selectedCategory == null
                                    ? null
                                    : FlowIcon(
                                      _selectedCategory!.icon,
                                      plated: true,
                                    ),
                            title: Text(
                              _selectedCategory?.name ??
                                  "transaction.edit.selectCategory".t(context),
                            ),
                            // subtitle: _selectedAccount == null
                            //     ? null
                            //     : Text(_selectedAccount!.balance.money),
                            onTap: () => selectCategory(),
                            trailing:
                                _selectedCategory == null
                                    ? const Icon(Symbols.chevron_right)
                                    : null,
                          ),
                        ),
                      const SizedBox(height: 24.0),
                      DescriptionSection(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        onChanged: (_) => setState(() => {}),
                      ),
                      const SizedBox(height: 24.0),
                      Section(
                        title: "transaction.date".t(context),
                        child: ListTile(
                          title: Text(_transactionDate.toMoment().LLL),
                          onTap: () => selectTransactionDate(),
                          trailing:
                              _selectedCategory == null
                                  ? const Icon(Symbols.chevron_right)
                                  : null,
                        ),
                      ),
                      if (_geo != null || enableGeo) ...[
                        const SizedBox(height: 24.0),
                        Section(
                          title: "transaction.location".t(context),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child:
                                _geo == null
                                    ? Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            "assets/images/map_square.png",
                                          ),
                                        ),
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 1.0,
                                        child: Center(
                                          child: Button(
                                            onTap: selectLocation,
                                            trailing: const Icon(
                                              Symbols.pin_drop_rounded,
                                            ),
                                            child: Text(
                                              "transaction.location.add".t(
                                                context,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 1.0,
                                            child: OSMap(
                                              mapController: _mapController,
                                              interactable: false,
                                              onTap: (_) => selectLocation(),
                                              center: LatLng(
                                                _geo?.latitude ??
                                                    sukhbaatarSquareCenterLat,
                                                _geo?.longitude ??
                                                    sukhbaatarSquareCenterLong,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        InfoText(
                                          child: Text(
                                            "transaction.location.edit".t(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24.0),
                      if (_currentlyEditing != null) ...[
                        Section(
                          title: "transaction.actions".t(context),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isTransfer)
                                ListTile(
                                  leading: Icon(Symbols.content_copy_rounded),
                                  title: Text(
                                    "transaction.duplicate".t(context),
                                  ),
                                  onTap: () => _duplicate(),
                                ),
                              if (_currentlyEditing.isDeleted == true)
                                ListTile(
                                  leading: Icon(Symbols.restore_page_rounded),
                                  title: Text(
                                    "transaction.moveToTrashBin.restore".t(
                                      context,
                                    ),
                                  ),
                                  onTap: () => _restoreTransaction(),
                                ),
                              if (_currentlyEditing.isDeleted == true)
                                ListTile(
                                  leading: Icon(Symbols.delete_forever_rounded),
                                  title: Text("transaction.delete".t(context)),
                                  onTap: () => _deleteTransaction(),
                                  iconColor: context.flowColors.expense,
                                  textColor: context.flowColors.expense,
                                ),
                              if (_currentlyEditing.isDeleted != true)
                                ListTile(
                                  leading: Icon(Symbols.delete_forever_rounded),
                                  title: Text(
                                    "transaction.moveToTrashBin".t(context),
                                  ),
                                  onTap: () => _moveToTrash(),
                                ),
                              SizedBox(height: 32.0),
                              Text(
                                "${"transaction.createdDate".t(context)} ${_currentlyEditing.createdDate.format(payload: "LLL", forceLocal: true)}",
                                style: context.textTheme.bodyMedium?.semi(
                                  context,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void tryFetchLocation() {
    if (Platform.isLinux) return;
    if (LocalPreferences().enableGeo.get() != true) return;
    if (LocalPreferences().autoAttachTransactionGeo.get() != true) return;

    Geolocator.getLastKnownPosition()
        .then((lastKnown) {
          if (lastKnown == null) {
            return;
          }

          if (_geo != null) {
            // In case we already have a location, don't override with less accurate one
            return;
          }

          _geo = Geo.fromPosition(lastKnown);

          if (mounted) setState(() => {});
        })
        .catchError((e, stackTrace) {
          _log.warning("Failed to get last known location", e, stackTrace);
        });

    Geolocator.getCurrentPosition()
        .then((current) {
          _geo = Geo.fromPosition(current);
        })
        .catchError((e, stackTrace) {
          locationFailed = true;
          _log.warning("Failed to get current location", e, stackTrace);
        })
        .whenComplete(() {
          if (mounted) setState(() => {});
        });
  }

  void updateTransactionType(TransactionType type) {
    if (type == _transactionType ||
        (_currentlyEditing != null && _currentlyEditing.isTransfer)) {
      return;
    }

    _transactionType = type;

    final double amountSign = switch (type) {
      TransactionType.expense => -1.0,
      _ => 1.0,
    };

    _amount = _amount.abs() * amountSign;

    setState(() {});
  }

  void inputAmount() async {
    await TransitiveLocalPreferences().updateTransitiveProperties();
    final hideCurrencySymbol =
        !TransitiveLocalPreferences().transitiveUsesSingleCurrency.get();

    if (!mounted) return;

    final double? result = await showModalBottomSheet<double>(
      context: context,
      builder:
          (context) => InputAmountSheet(
            initialAmount: _amount.abs(),
            currency: _selectedAccount?.currency,
            hideCurrencySymbol: _selectedAccount == null && hideCurrencySymbol,
            title: _transactionType.localizedNameContext(context),
            lockSign: true,
          ),
      isScrollControlled: true,
    );

    final double? resultAmount =
        result == null
            ? null
            : switch (_transactionType) {
              TransactionType.expense => -result.abs(),
              TransactionType.income => result.abs(),
              TransactionType.transfer => result.abs(),
            };

    setState(() {
      _amount = resultAmount ?? _amount;
    });

    if (!mounted) return;

    await inputPostConversionAmount();

    if (!mounted) return;

    if (widget.isNewTransaction && result != null) {
      FocusScope.of(context).requestFocus(_titleFocusNode);
    }
  }

  Future<void> inputPostConversionAmount() async {
    if (!crossCurrencyTransfer) return;

    final double initialAmount = _amount * _conversionRate;

    // In the currency of [to]
    final double? postConversionAmount = await showModalBottomSheet<double>(
      context: context,
      builder:
          (context) => InputAmountSheet(
            initialAmount: initialAmount,
            currency: _selectedAccountTransferTo?.currency,
            overrideDecimalPrecision: 8,
            hideCurrencySymbol: false,
            title:
                "${Money(_amount, _selectedAccount!.currency).formatMoney()} =",
            lockSign: true,
            allowNegative: false,
          ),
      isScrollControlled: true,
    );

    if (postConversionAmount != null) {
      _conversionRate = postConversionAmount / _amount;
    }

    setState(() {});
  }

  void selectAccount() async {
    final Account? result =
        accounts.length == 1
            ? accounts.single
            : await showModalBottomSheet<Account>(
              context: context,
              builder:
                  (context) => SelectAccountSheet(
                    accounts: accounts,
                    currentlySelectedAccountId: _selectedAccount?.id,
                    titleOverride:
                        isTransfer
                            ? "transaction.transfer.from.select".t(context)
                            : null,
                    showBalance: true,
                    showTrailing: widget.isNewTransaction,
                  ),
              isScrollControlled: true,
            );

    setState(() {
      if (result?.id == _selectedAccountTransferTo?.id) {
        _selectedAccountTransferTo = null;
      }
      _selectedAccount = result ?? _selectedAccount;
    });

    if (widget.isNewTransaction && result != null) {
      if (isTransfer) {
        selectAccountTransferTo();
      } else {
        selectCategory();
      }
    }
  }

  void selectAccountTransferTo() async {
    final List<Account> toAccounts =
        accounts.where((element) {
          return element.id != _selectedAccount?.id;
        }).toList();

    final Account? result =
        toAccounts.length == 1
            ? toAccounts.single
            : await showModalBottomSheet<Account>(
              context: context,
              builder:
                  (context) => SelectAccountSheet(
                    accounts: toAccounts,
                    currentlySelectedAccountId: _selectedAccountTransferTo?.id,
                    titleOverride: "transaction.transfer.to.select".t(context),
                    showBalance: true,
                  ),
              isScrollControlled: true,
            );

    setState(() {
      _selectedAccountTransferTo = result ?? _selectedAccountTransferTo;
    });

    final bool crossCurrency =
        _selectedAccount != null &&
        _selectedAccountTransferTo != null &&
        _selectedAccount!.currency != _selectedAccountTransferTo!.currency;

    if (crossCurrency && widget.isNewTransaction) {
      final ExchangeRates? rates =
          ExchangeRatesService().getPrimaryCurrencyRates();

      if (rates != null) {
        _conversionRate =
            Money(
              1.0,
              _selectedAccount!.currency,
            ).convert(_selectedAccountTransferTo!.currency, rates).amount;
      }
    }

    if (widget.isNewTransaction && result != null) inputAmount();
  }

  void selectCategory() async {
    if (categories.isEmpty) {
      inputAmount();
      return;
    }

    final Optional<Category>? result =
        await showModalBottomSheet<Optional<Category>>(
          context: context,
          builder:
              (context) => SelectCategorySheet(
                categories: categories,
                currentlySelectedCategoryId: _selectedCategory?.id,
                showTrailing: widget.isNewTransaction,
              ),
          isScrollControlled: true,
        );

    if (result != null) {
      setState(() {
        _selectedCategory = result.value;
      });
    }

    if (widget.isNewTransaction && result != null) inputAmount();
  }

  void selectTransactionDate() async {
    final TimeOfDay currentTimeOfDay = TimeOfDay.fromDateTime(_transactionDate);

    final DateTime? result = await showDatePicker(
      context: context,
      firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
      lastDate: DateTime(9999, 12, 31),
      initialDate: _transactionDate,
    );

    setState(() {
      _transactionDate = result ?? _transactionDate;
    });

    if (!mounted || result == null) return;

    final TimeOfDay? timeResult = await showTimePicker(
      context: context,
      initialTime: currentTimeOfDay,
    );

    if (timeResult == null) return;

    setState(() {
      _transactionDate = _transactionDate.copyWith(
        hour: timeResult.hour,
        minute: timeResult.minute,
        second: 0,
        microsecond: 0,
        millisecond: 0,
      );
    });
  }

  void selectLocation() async {
    final Optional<LatLng>? result =
        await showModalBottomSheet<Optional<LatLng>>(
          context: context,
          builder:
              (context) => LocationPickerSheet(
                latitude: _geo?.latitude,
                longitude: _geo?.longitude,
              ),
          isScrollControlled: true,
        );

    if (result != null) {
      final LatLng? newLatLng = result.value;

      _geoHandpicked = newLatLng?.toSexagesimal() != _geo?.toSexagesimal();
      _geo = newLatLng == null ? null : Geo.fromLatLng(newLatLng);

      if (newLatLng != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _mapController?.move(newLatLng, _mapController.camera.zoom);
        });
      }
    }

    setState(() {});
  }

  bool _ensureAccountsSelected() {
    if (_selectedAccount == null) {
      context.showErrorToast(
        error: "error.transaction.missingAccount".t(context),
      );
      _selectAccountFocusNode.requestFocus();
      return false;
    }

    if (isTransfer && _selectedAccountTransferTo == null) {
      context.showErrorToast(
        error: "error.transaction.missingAccount".t(context),
      );
      _selectAccountTransferToFocusNode.requestFocus();
      return false;
    }

    return true;
  }

  void update({
    required String? formattedTitle,
    required String? formattedDescription,
  }) async {
    if (_currentlyEditing == null) return;

    final bool pendingTransactionsRequireConfrimation =
        LocalPreferences().pendingTransactions.requireConfrimation.get();

    final bool? isPending =
        pendingTransactionsRequireConfrimation &&
                _currentlyEditing.transactionDate.isPast
            ? _transactionDate.isFuture
            : _currentlyEditing.isPending;

    if (_transactionType == TransactionType.transfer) {
      try {
        _selectedAccount!.transferTo(
          amount: _amount,
          title: formattedTitle,
          description: formattedDescription,
          targetAccount: _selectedAccountTransferTo!,
          createdDate: _currentlyEditing.createdDate,
          transactionDate: _transactionDate,
          extensions:
              _currentlyEditing.extensions.getOverriden(_geo, Geo.keyName).data,
          isPending: isPending,
          conversionRate: crossCurrencyTransfer ? _conversionRate : null,
        );

        _currentlyEditing.permanentlyDelete(true);
        context.pop();
      } catch (e, stackTrace) {
        _log.severe("Failed to update transfer transaction", e, stackTrace);
      }
      return;
    }

    _currentlyEditing.setCategory(_selectedCategory);
    _currentlyEditing.setAccount(_selectedAccount);
    _currentlyEditing.title = formattedTitle;
    _currentlyEditing.description = formattedDescription;
    _currentlyEditing.amount = _amount;
    _currentlyEditing.transactionDate = _transactionDate;
    _currentlyEditing.isPending = isPending;

    /// When user edits a balance amendment transaction, it is no longer a balance amendment.
    if (_currentlyEditing.subtype == TransactionSubtype.updateBalance.value) {
      _currentlyEditing.subtype = null;
    }

    _currentlyEditing.extensions = _currentlyEditing.extensions.getOverriden(
      _geo,
      Geo.keyName,
    );

    TransactionsService().updateOneSync(_currentlyEditing);

    context.pop();
  }

  void save() {
    if (!_ensureAccountsSelected()) return;

    final bool pendingTransactionsRequireConfrimation =
        LocalPreferences().pendingTransactions.requireConfrimation.get();

    final String trimmedTitle = _titleController.text.trim();
    final String? formattedTitle =
        trimmedTitle.isNotEmpty ? trimmedTitle : null;

    final String trimmedDescription = _descriptionController.text.trim();
    final String? formattedDescription =
        trimmedDescription.isNotEmpty ? trimmedDescription : null;

    if (_currentlyEditing != null) {
      return update(
        formattedTitle: formattedTitle,
        formattedDescription: formattedDescription,
      );
    }

    final List<TransactionExtension> extensions = [if (_geo != null) _geo!];

    final bool isPending =
        pendingTransactionsRequireConfrimation
            ? _transactionDate.isFutureAnchored(
              Moment.now().startOfNextMinute(),
            )
            : false;

    if (isTransfer) {
      _selectedAccount!.transferTo(
        targetAccount: _selectedAccountTransferTo!,
        amount: _amount.abs(),
        transactionDate: _transactionDate,
        title: formattedTitle,
        description: formattedDescription,
        extensions: extensions,
        isPending: isPending,
        conversionRate: crossCurrencyTransfer ? _conversionRate : null,
      );
    } else {
      _selectedAccount!.createAndSaveTransaction(
        amount: _amount,
        title: formattedTitle,
        description: formattedDescription,
        category: _selectedCategory,
        transactionDate: _transactionDate,
        extensions: extensions,
        isPending: isPending,
      );
    }

    context.pop();
  }

  bool hasChanged() {
    if (_currentlyEditing != null) {
      final bool transferToAccountDifferent =
          _currentlyEditing.isTransfer &&
          _currentlyEditing.extensions.transfer?.toAccountUuid !=
              _selectedAccountTransferTo?.uuid;

      if (transferToAccountDifferent) {
        return true;
      }

      final bool ammountChanged =
          isTransfer
              ? _currentlyEditing.amount.abs() != _amount
              : _currentlyEditing.amount != _amount;

      return ammountChanged ||
          _geoHandpicked ||
          (_currentlyEditing.title ?? "") != _titleController.text ||
          (_currentlyEditing.description ?? "") !=
              _descriptionController.text ||
          _currentlyEditing.type != _transactionType ||
          _currentlyEditing.accountUuid != _selectedAccount?.uuid ||
          _currentlyEditing.categoryUuid != _selectedCategory?.uuid ||
          _currentlyEditing.transactionDate != _transactionDate;
    }

    return _amount != 0 ||
        _geoHandpicked ||
        _titleController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _selectedAccount != null ||
        _selectedAccountTransferTo != null ||
        _selectedCategory != null;
  }

  void _moveToTrash() async {
    if (_currentlyEditing == null || _currentlyEditing.isDeleted == true) {
      return;
    }

    _currentlyEditing.moveToTrashBin();

    if (mounted) {
      context.showToast(text: "transaction.moveToTrashBin.success".t(context));
      pop();
    }
  }

  void _restoreTransaction() async {
    if (_currentlyEditing == null || _currentlyEditing.isDeleted != true) {
      return;
    }

    _currentlyEditing.recoverFromTrashBin();

    if (mounted) {
      context.showToast(
        text: "transaction.moveToTrashBin.restore.success".t(context),
      );
      pop();
    }
  }

  void _deleteTransaction() async {
    if (_currentlyEditing == null || _currentlyEditing.isDeleted != true) {
      return;
    }

    final String txnTitle =
        _currentlyEditing.title ?? "transaction.fallbackTitle".t(context);

    final confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(context, txnTitle),
    );

    if (confirmation == true) {
      _currentlyEditing.permanentlyDelete();

      if (mounted) {
        pop();
      }
    }
  }

  void _duplicate() async {
    if (_currentlyEditing == null) return;

    final int duplicate = _currentlyEditing.duplicate();

    context.showToast(text: "transaction.duplicate.success".t(context));
    await context.push("/transaction/$duplicate");
  }

  void pop() {
    context.pop();
  }

  String get fallbackTitle => switch (_transactionType) {
    TransactionType.transfer
        when _selectedAccount != null && _selectedAccountTransferTo != null =>
      "transaction.transfer.fromToTitle".t(context, {
        "from": _selectedAccount!.name,
        "to": _selectedAccountTransferTo!.name,
      }),
    _ => "transaction.fallbackTitle".t(context),
  };
}
