import 'package:flutter/material.dart';

class BaseTradeBottomSheet extends StatelessWidget {
  const BaseTradeBottomSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {}

// Widget TradeComponentCreator.popupRow(BuildContext context, String label, String value) {
//   return Container(
//     //color: Colors.purple,
//     padding: const EdgeInsets.only(top: 10, bottom: 10),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _labelText(context, label),
//         Expanded(
//           flex: 1,
//           child: _valueText(context, value),
//         ),
//       ],
//     ),
//   );
// }
//
// Widget _createTitle(BuildContext context, String title) {
//   return Text(
//     title,
//     style: InvestrendTheme.of(context).regular_w700_compact.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
//   );
// }
//
// Widget _labelText(BuildContext context, String label) {
//   return Container(
//     // color: Colors.yellow,
//     child: Text(
//       label,
//       style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
//     ),
//   );
// }
//
// Widget _valueText(BuildContext context, String label) {
//   return Container(
//     // color: Colors.greenAccent,
//     child: Text(
//       label,
//       style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
//       textAlign: TextAlign.right,
//     ),
//   );
// }
// Widget _createButtonSolid(OrderType orderType, VoidCallback onPressed){
//   return Container(
//       width: double.maxFinite,
//       padding: EdgeInsets.only(top: 24.0, right: 14.0),
//       child: ButtonOrder(orderType,onPressed));
// }
}
