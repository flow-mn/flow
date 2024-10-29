// import "package:flow/objectbox.dart";
// import "package:flow/objectbox/actions.dart";
// import "package:flow/widgets/category_card.dart";
// import "package:flow/widgets/home/home/info_card.dart";
// import "package:flutter/cupertino.dart";

// class FlowCards extends StatefulWidget {
//   const FlowCards({super.key});

//   @override
//   State<FlowCards> createState() => _FlowCardsState();
// }

// class _FlowCardsState extends State<FlowCards> {
//   @override
//   Widget build(BuildContext context) {
//     final totalBalance = ObjectBox().getPrimaryCurrencyGrandTotal();

//     return Row(
//       children: [
//         Column(
//           children: [
//             InfoCard(title: title, value: value),
//             const SizedBox(height: 12.0),
//             InfoCard(title: title, value: value),
//           ],
//         ),
//         const SizedBox(width: 12.0),
//         InfoCard(title: title, value: value),
//       ],
//     );
//   }
// }
