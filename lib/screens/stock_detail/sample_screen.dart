import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:flutter/material.dart';

class ScreenSampleNoTabWithParentTabs extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;
  ScreenSampleNoTabWithParentTabs(this.tabIndex, this.tabController, {Key? key})
      : super(key: key);

  @override
  _ScreenSampleNoTabWithParentTabsState createState() =>
      _ScreenSampleNoTabWithParentTabsState(tabIndex, tabController);
}

class _ScreenSampleNoTabWithParentTabsState
    extends BaseStateNoTabsWithParentTab<ScreenSampleNoTabWithParentTabs>
//with AutomaticKeepAliveClientMixin<ScreenSampleNoTabWithParentTabs>
{
  LocalForeignNotifier? _localForeignNotifier;
  PerformanceNotifier? _performanceNotifier;

  _ScreenSampleNoTabWithParentTabsState(
      int tabIndex, TabController tabController)
      : super('/stock_detail_analysis', tabIndex, tabController);

  // @override
  // bool get wantKeepAlive => true;

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return SingleChildScrollView(
      child: Column(
        children: [
          //CardLocalForeign(_localForeignNotifier),
          Text('sample\n child no tab\n on parent with tab'),
          ComponentCreator.divider(context),
          //CardPerformance(_performanceNotifier),
        ],
      ),
    );
  }

  @override
  void onActive() {
    print(routeName + ' onActive');
  }

  @override
  void initState() {
    super.initState();

    _localForeignNotifier = LocalForeignNotifier(
        new ForeignDomestic('', '', '', '', 0, 0, 0, 0.0, 0, 0, 0, 0.0));
    _performanceNotifier = PerformanceNotifier(new PerformanceData());
  }

  @override
  void dispose() {
    _localForeignNotifier?.dispose();
    _performanceNotifier?.dispose();
    super.dispose();
  }

  @override
  void onInactive() {
    print(routeName + ' onInactive');
  }
}
