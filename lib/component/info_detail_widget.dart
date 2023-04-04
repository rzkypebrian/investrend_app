
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/custom_text.dart';
import 'package:Investrend/component/tapable_widget.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';

class InfoDetailWidget extends StatefulWidget {
  final Widget normalWiget;
  final Widget expandedWiget;
  final bool expanded;
  const InfoDetailWidget(this.normalWiget, this.expandedWiget, {this.expanded = false, Key key}) : super(key: key);

  @override
  _InfoDetailWidgetState createState() => _InfoDetailWidgetState();
}

class _InfoDetailWidgetState extends State<InfoDetailWidget> {
  bool expanded = false;
  @override
  void initState() {
    super.initState();
    expanded = widget.expanded;
  }
  @override
  void dispose() {

    super.dispose();
  }
  VoidCallback onTap(){
    setState(() {
      expanded = !expanded;
    });
  }
  @override
  Widget build(BuildContext context) {
    return expanded ? Column(
      children: [
        TapableWidget(onTap:onTap,child: widget.normalWiget),
        widget.expandedWiget
      ],
    ) : TapableWidget(
        onTap: onTap,
        child: widget.normalWiget);
    //
    // return ValueListenableBuilder(
    //   valueListenable: notifier,
    //   builder: (context, expanded, child) {
    //
    //     return expanded ? Column(
    //       children: [
    //         TapableWidget(onTap:onTap,child: widget.normalWiget),
    //         widget.expandedWiget
    //       ],
    //     ) : TapableWidget(
    //       onTap: onTap,
    //         child: widget.normalWiget);
    //   },
    // );
  }
}


class TopupBankInfoWidget extends StatefulWidget {
  final String bank_name;
  final String bank_icon;
  final String topup_info;
  const TopupBankInfoWidget(this.bank_name, this.bank_icon,this.topup_info, {Key key}) : super(key: key);

  @override
  _TopupBankInfoWidgetState createState() => _TopupBankInfoWidgetState();
}

class _TopupBankInfoWidgetState extends State<TopupBankInfoWidget>
    //with SingleTickerProviderStateMixin
{
  // AnimationController _controller;
  // Animation<double> _myAnimation;
  bool expanded = false;

  VoidCallback onTap(){
    setState(() {
      expanded = !expanded;
    });
  }
  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 200),
    // );
    // _myAnimation = CurvedAnimation(
    //     curve: Curves.linear,
    //     parent: _controller);
    //
  }

  Widget formattedWidget(BuildContext context, String data){
    List<Widget> list = List.empty(growable: true);

    if(data != null){
      List<String> lines = data.split('\n');
      lines.forEach((line) {
        if(line.startsWith('• ')){
          line = line.replaceFirst('1. ', '');
          list.add(Row(

            children: [
             Text('•'),
             SizedBox(width: 5.0,),
              Text(line,style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor)),
            ],
          ));
        }else{
          list.add(Text(line,style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor)),);
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  @override
  Widget build(BuildContext context) {

    Widget iconWidget;
    if(StringUtils.noNullString(widget.bank_icon).toLowerCase().startsWith('http')){
      iconWidget = ComponentCreator.imageNetworkCached(widget.bank_icon, width: 40.0, height: 40.0);
    }else{
      iconWidget = Image.asset(widget.bank_icon, width: 24.0, height: 24.0);
    }

    
    
    if(expanded){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                //Image.asset(widget.bank_icon, width: 24.0, height: 24.0),
                //ComponentCreator.imageNetworkCached(bank)
                iconWidget,
                SizedBox(width: 14.0),
                Expanded(
                  flex: 1,
                  child: Text(widget.bank_name,
                      style: InvestrendTheme.of(context).regular_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor)),
                ),

                IconButton(onPressed: onTap, icon: Image.asset('images/icons/arrow_up.png', width: 12.0, height: 12.0, color: InvestrendTheme.of(context).greyDarkerTextColor)),

              ],
            ),
            //Text(widget.topup_info, style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor)),

            FormatTextBullet(widget.topup_info, style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
          ],
        );
    }else{
      return Row(
        children: [
          //Image.asset(widget.bank_icon, width: 24.0, height: 24.0),
          iconWidget,
          SizedBox(width: 14.0),
          Expanded(
            flex: 1,
            child: Text(widget.bank_name,
                style: InvestrendTheme.of(context).regular_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor)),
          ),
          //AnimatedIcon(icon: AnimatedIcons.close_menu, progress: _myAnimation),
          IconButton(
            onPressed: onTap,
              icon: Image.asset('images/icons/arrow_down.png', width: 12.0, height: 12.0, color: InvestrendTheme.of(context).greyDarkerTextColor,)),
        ],
      );
    }

  }
}
