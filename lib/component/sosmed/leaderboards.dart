import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/badwords/clean_widget.dart';
import 'package:Investrend/component/badwords/constant.dart';
import 'package:Investrend/component/badwords/string_contains_widget.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:Investrend/component/badwords/string_contains.dart';
import 'dart:math' as math;

class Leaderboards extends StatefulWidget {
  const Leaderboards({Key key}) : super(key: key);

  @override
  _LeaderboardsState createState() => _LeaderboardsState();
}

class _LeaderboardsState extends State<Leaderboards> {
  List<LeaderboardsTransactionDummy> listDummy =
      LeaderboardsTransactionDummy.dummy;
  TextEditingController textController = TextEditingController();
  String displayText = "";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: body(),
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        color: Colors.white,
        margin: EdgeInsets.only(
          top: 20,
          bottom: 10,
          right: 14,
          left: 14,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 15,
                    margin: EdgeInsets.only(bottom: 30, top: 20),
                    child: Image.asset('images/icons/action_back.png'),
                  ),
                ),
                Transform.rotate(
                  angle: -math.pi / 2,
                  child: Container(
                    height: 15,
                    margin: EdgeInsets.only(bottom: 30, top: 20),
                    child: Image.asset(
                      'images/icons/menu_vertical_dots.png',
                      color: Color(0xffCCCCCC),
                    ),
                  ),
                ),
              ],
            ),
            CleanWidget(
              source:
                  "rizkypebrian@gmail.com\nrizkypeb@gmail.com\nbitch\n082112929097",
              keepFirstLastLetters: true,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Colors.black,
                  ),
            ),
            Text("====================="),
            StringContainsWidget(
              source:
                  "rizkypebrian@gmail.com\nrizkypeb@gmail.com\nbitch\n082112929097",
              style: TextStyle(color: Colors.black),
              linkStyle: TextStyle(color: Colors.blue),
              textAlign: TextAlign.left,
              onTap: (url) {
                print('element is a ${url.value} and type of ${url.type}');
                if (url.type == StringContainsElementType.words) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${url.value} is awesome!!',
                      ),
                      duration: const Duration(seconds: 2),
                      dismissDirection: DismissDirection.horizontal,
                    ),
                  );
                }
              },
              highLightWords: const [
                'Flutter',
                'Dart',
              ],
              highlightWordsStyle: const TextStyle(
                color: Colors.red,
              ),
              types: const [
                StringContainsElementType.email,
                StringContainsElementType.url,
                StringContainsElementType.phoneNumber,
                StringContainsElementType.hashtag,
                StringContainsElementType.mention,
                StringContainsElementType.words,
              ],
            ),
            Column(
              children: [
                Text("You are a piece of shit".cleanBadWords()),
                TextField(
                  controller: textController,
                  maxLines: null,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      displayText = textController.text;
                      FocusScope.of(context).unfocus();
                    });
                  },
                  child: Text('test'),
                ),
                CleanWidget(
                  source: displayText,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                        color: Colors.black,
                      ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    child: Text(
                      'Transaction',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    InvestrendTheme.push(context, LeaderboardsTransaction(),
                        ScreenTransition.Fade, '/leaderboardsTransaction');
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 9, right: 10),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "View All",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          WidgetSpan(
                            child: Image.asset(
                              'images/icons/arrow_forward.png',
                              height: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                /*
                Container(
                  margin: EdgeInsets.only(right: 8),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 9, right: 10),
                  height: 15,
                  child: Image.asset(
                    'images/icons/arrow_forward.png',
                  ),
                ),
                */
              ],
            ),
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFDBDBDB),
                  ),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    listLeaderboards(),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      child: Text(
                        'Prediction',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      InvestrendTheme.push(context, LeaderboardsPrediction(),
                          ScreenTransition.Fade, '/leaderboardsPrediction');
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 9, right: 10),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "View All",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            WidgetSpan(
                              child: Image.asset(
                                'images/icons/arrow_forward.png',
                                height: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 20),
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFFDBDBDB),
                ),
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  listLeaderboards(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listLeaderboards() {
    listDummy.sort((a, b) => b.splitPoints.compareTo(a.splitPoints));
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: listDummy.length == null
          ? 0
          : (listDummy.length > 5 ? 5 : listDummy.length),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return index == 0
            ? Container(
                margin: EdgeInsets.only(
                  bottom: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 28),
                      child: AvatarProfileButton(
                        url: "https://freepngimg.com/thumb/man/22654-6-man.png",
                        fullname: ' ',
                        size: 64,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          listDummy[index]?.name != null
                              ? listDummy[index]?.name
                              : '',
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          width: 3.6,
                        ),
                        listDummy[index]?.verified == true
                            ? Container(
                                margin: EdgeInsets.only(top: 6),
                                height: 14,
                                child: Image.asset(
                                  'images/icons/check_verified.png',
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                    Text(
                      listDummy[index]?.username != null
                          ? listDummy[index]?.username
                          : '',
                      style: InvestrendTheme.of(context)
                          .regular_w500_greyDarker
                          .copyWith(
                            fontSize: 13,
                            color: Color(0xff666666),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ('${(index + 1).toString()}st'),
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 18,
                              ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 6),
                          height: 18,
                          width: 1,
                          color: Color(0xffECC249),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          listDummy[index]?.points != null
                              ? listDummy[index]?.points
                              : '',
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 18,
                              ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : Container(
                margin: EdgeInsets.only(
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        right: 10,
                        left: 10,
                      ),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                (index + 1).toString(),
                                style: InvestrendTheme.of(context)
                                    .regular_w500_greyDarker
                                    .copyWith(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          AvatarProfileButton(
                            url:
                                "https://freepngimg.com/thumb/man/22654-6-man.png",
                            fullname: ' ',
                            size: 32,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      listDummy[index]?.name != null
                                          ? listDummy[index]?.name
                                          : '',
                                      style: InvestrendTheme.of(context)
                                          .regular_w500_greyDarker
                                          .copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      width: 3.6,
                                    ),
                                    listDummy[index]?.verified == true
                                        ? Container(
                                            margin: EdgeInsets.only(top: 6),
                                            height: 14,
                                            child: Image.asset(
                                              'images/icons/check_verified.png',
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  listDummy[index]?.username != null
                                      ? listDummy[index]?.username
                                      : '',
                                  style: InvestrendTheme.of(context)
                                      .regular_w500_greyDarker
                                      .copyWith(
                                        fontSize: 13,
                                        color: Color(0xff666666),
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            listDummy[index]?.points != null
                                ? listDummy[index]?.points
                                : '',
                            style: InvestrendTheme.of(context)
                                .regular_w500_greyDarker
                                .copyWith(
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
      },
    );
    /*
    return Column(
      children: List.generate(listDummy.length, (index) {
        return Container(
          margin: EdgeInsets.only(
            bottom: 20,
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                  right: 10,
                  left: 10,
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 30,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          listDummy[index]?.rank != null
                              ? listDummy[index]?.rank
                              : '',
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    AvatarProfileButton(
                      url: "https://freepngimg.com/thumb/man/22654-6-man.png",
                      fullname: ' ',
                      size: 32,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                listDummy[index]?.name != null
                                    ? listDummy[index]?.name
                                    : '',
                                style: InvestrendTheme.of(context)
                                    .regular_w500_greyDarker
                                    .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(
                                width: 3.6,
                              ),
                              listDummy[index]?.verified == true
                                  ? Container(
                                      margin: EdgeInsets.only(top: 6),
                                      height: 14,
                                      child: Image.asset(
                                        'images/icons/check_verified.png',
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            listDummy[index]?.username != null
                                ? listDummy[index]?.username
                                : '',
                            style: InvestrendTheme.of(context)
                                .regular_w500_greyDarker
                                .copyWith(
                                  fontSize: 13,
                                  color: Color(0xff666666),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      listDummy[index]?.points != null
                          ? listDummy[index]?.points
                          : '',
                      style: InvestrendTheme.of(context)
                          .regular_w500_greyDarker
                          .copyWith(
                            fontSize: 13,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
    */
  }
}

class LeaderboardsTransaction extends StatefulWidget {
  const LeaderboardsTransaction({Key key}) : super(key: key);

  @override
  _LeaderboardsTransactionState createState() =>
      _LeaderboardsTransactionState();
}

class _LeaderboardsTransactionState extends State<LeaderboardsTransaction> {
  List<LeaderboardsTransactionDummy> listDummy =
      LeaderboardsTransactionDummy.dummy;

  int countList = 0;

  double blur = 5;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // extendBody: true,
        backgroundColor: Colors.white,
        body: body(),
        bottomNavigationBar: bottomNavBar(),
      ),
    );
  }

// filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
  Widget bottomNavBar() {
    /*
    Material(
      elevation: 0,
      color: Colors.transparent,
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: 60,
            width: double.infinity,
            padding: padding,
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
    */
    return BlurryContainer(
      color: Colors.transparent,
      blur: 10,
      elevation: 0,
      height: 60,
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              right: 25,
              left: 25,
            ),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 30,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '2000',
                      style: InvestrendTheme.of(context)
                          .regular_w500_greyDarker
                          .copyWith(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                AvatarProfileButton(
                  fullname: 'Lo Kheng Hong',
                  size: 32,
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 6),
                            height: 14,
                            child: Image.asset(
                              'images/icons/person.png',
                            ),
                          ),
                          SizedBox(
                            width: 3.6,
                          ),
                          Text(
                            'Lo Kheng Hong',
                            style: InvestrendTheme.of(context)
                                .regular_w500_greyDarker
                                .copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(
                            width: 3.6,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 6),
                            height: 14,
                            child: Image.asset(
                              'images/icons/check_verified.png',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        '@kenghong',
                        style: InvestrendTheme.of(context)
                            .regular_w500_greyDarker
                            .copyWith(
                              fontSize: 13,
                              color: Color(0xff666666),
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '1.172pts',
                  style: InvestrendTheme.of(context)
                      .regular_w500_greyDarker
                      .copyWith(
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        color: Colors.white,
        margin: EdgeInsets.only(
          top: 20,
          bottom: 10,
          right: 14,
          left: 14,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 15,
                    margin: EdgeInsets.only(bottom: 30, top: 20),
                    child: Image.asset('images/icons/action_back.png'),
                  ),
                ),
                Transform.rotate(
                  angle: -math.pi / 2,
                  child: Container(
                    height: 15,
                    margin: EdgeInsets.only(bottom: 30, top: 20),
                    child: Image.asset(
                      'images/icons/menu_vertical_dots.png',
                      color: Color(0xffCCCCCC),
                    ),
                  ),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction',
                  style: InvestrendTheme.of(context)
                      .regular_w500_greyDarker
                      .copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Transaction will be only tracked if the user post the transaction',
                  style: InvestrendTheme.of(context)
                      .regular_w500_greyDarker
                      .copyWith(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                ),
                SizedBox(
                  height: 14,
                ),
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Icon(
                        Icons.info_outlined,
                        color: Color(0xff4462A8),
                        size: 13,
                      ),
                    ),
                    SizedBox(
                      width: 6.5,
                    ),
                    Container(
                      child: Text(
                        'Lihat detail perhitungan',
                        style: InvestrendTheme.of(context)
                            .regular_w500_greyDarker
                            .copyWith(
                              fontSize: 13,
                              color: Color(0xff4462A8),
                            ),
                      ),
                    ),
                  ],
                )
                /*
                Container(
                  margin: EdgeInsets.only(right: 8),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 9, right: 10),
                  height: 15,
                  child: Image.asset(
                    'images/icons/arrow_forward.png',
                  ),
                ),
                */
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFFDBDBDB),
                ),
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  listLeaderboards(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

/*
  Widget firstLeaderboards() {
    return Container(
      margin: EdgeInsets.only(
        bottom: 40,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 28),
            child: AvatarProfileButton(
              url: "https://freepngimg.com/thumb/man/22654-6-man.png",
              fullname: ' ',
              size: 64,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Muhammad Baresi',
                style: InvestrendTheme.of(context)
                    .regular_w500_greyDarker
                    .copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(
                width: 3.6,
              ),
              Container(
                margin: EdgeInsets.only(top: 6),
                height: 14,
                child: Image.asset(
                  'images/icons/check_verified.png',
                ),
              ),
            ],
          ),
          Text(
            '@webb.theresa',
            style: InvestrendTheme.of(context).regular_w500_greyDarker.copyWith(
                  fontSize: 13,
                  color: Color(0xff666666),
                ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '1st',
                style: InvestrendTheme.of(context)
                    .regular_w500_greyDarker
                    .copyWith(
                      fontSize: 18,
                    ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                margin: EdgeInsets.only(top: 6),
                height: 18,
                width: 1,
                color: Color(0xffECC249),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                '1.172pts',
                style: InvestrendTheme.of(context)
                    .regular_w500_greyDarker
                    .copyWith(
                      fontSize: 18,
                    ),
              ),
            ],
          )
        ],
      ),
    );
  }

  */
  Widget listLeaderboards() {
    listDummy.sort((a, b) => b.splitPoints.compareTo(a.splitPoints));
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: listDummy.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return index == 0
            ? Container(
                margin: EdgeInsets.only(
                  bottom: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 28),
                      child: AvatarProfileButton(
                        url: "https://freepngimg.com/thumb/man/22654-6-man.png",
                        fullname: ' ',
                        size: 64,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          listDummy[index]?.name != null
                              ? listDummy[index]?.name
                              : '',
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ),
                        SizedBox(
                          width: 3.6,
                        ),
                        listDummy[index]?.verified == true
                            ? Container(
                                margin: EdgeInsets.only(top: 6),
                                height: 14,
                                child: Image.asset(
                                  'images/icons/check_verified.png',
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                    Text(
                      listDummy[index]?.username != null
                          ? listDummy[index]?.username
                          : '',
                      style: InvestrendTheme.of(context)
                          .regular_w500_greyDarker
                          .copyWith(
                            fontSize: 13,
                            color: Color(0xff666666),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ('${(index + 1).toString()}st'),
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 18,
                              ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 6),
                          height: 18,
                          width: 1,
                          color: Color(0xffECC249),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          listDummy[index]?.points != null
                              ? listDummy[index]?.points
                              : '',
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 18,
                              ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : Container(
                margin: EdgeInsets.only(
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        right: 10,
                        left: 10,
                      ),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                (index + 1).toString(),
                                style: InvestrendTheme.of(context)
                                    .regular_w500_greyDarker
                                    .copyWith(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          AvatarProfileButton(
                            url:
                                "https://freepngimg.com/thumb/man/22654-6-man.png",
                            fullname: ' ',
                            size: 32,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      listDummy[index]?.name != null
                                          ? listDummy[index]?.name
                                          : '',
                                      style: InvestrendTheme.of(context)
                                          .regular_w500_greyDarker
                                          .copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      width: 3.6,
                                    ),
                                    listDummy[index]?.verified == true
                                        ? Container(
                                            margin: EdgeInsets.only(top: 6),
                                            height: 14,
                                            child: Image.asset(
                                              'images/icons/check_verified.png',
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  listDummy[index]?.username != null
                                      ? listDummy[index]?.username
                                      : '',
                                  style: InvestrendTheme.of(context)
                                      .regular_w500_greyDarker
                                      .copyWith(
                                        fontSize: 13,
                                        color: Color(0xff666666),
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            listDummy[index]?.points != null
                                ? listDummy[index]?.points
                                : '',
                            style: InvestrendTheme.of(context)
                                .regular_w500_greyDarker
                                .copyWith(
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
      },
    );
    /*
    return Column(
      children: List.generate(listDummy.length, (index) {
        return Container(
          margin: EdgeInsets.only(
            bottom: 20,
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                  right: 10,
                  left: 10,
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 30,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          listDummy[index]?.rank != null
                              ? listDummy[index]?.rank
                              : '',
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    AvatarProfileButton(
                      url: "https://freepngimg.com/thumb/man/22654-6-man.png",
                      fullname: ' ',
                      size: 32,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                listDummy[index]?.name != null
                                    ? listDummy[index]?.name
                                    : '',
                                style: InvestrendTheme.of(context)
                                    .regular_w500_greyDarker
                                    .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(
                                width: 3.6,
                              ),
                              listDummy[index]?.verified == true
                                  ? Container(
                                      margin: EdgeInsets.only(top: 6),
                                      height: 14,
                                      child: Image.asset(
                                        'images/icons/check_verified.png',
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            listDummy[index]?.username != null
                                ? listDummy[index]?.username
                                : '',
                            style: InvestrendTheme.of(context)
                                .regular_w500_greyDarker
                                .copyWith(
                                  fontSize: 13,
                                  color: Color(0xff666666),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      listDummy[index]?.points != null
                          ? listDummy[index]?.points
                          : '',
                      style: InvestrendTheme.of(context)
                          .regular_w500_greyDarker
                          .copyWith(
                            fontSize: 13,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
    */
  }
}

class LeaderboardsPrediction extends StatefulWidget {
  const LeaderboardsPrediction({Key key}) : super(key: key);

  @override
  _LeaderboardsPredictionState createState() => _LeaderboardsPredictionState();
}

class _LeaderboardsPredictionState extends State<LeaderboardsPrediction> {
  GlobalKey globalKey;
  String selectedValue = "This Week";
  List<LeaderboardsTransactionDummy> listDummy =
      LeaderboardsTransactionDummy.dummy;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // extendBody: true,
        backgroundColor: Colors.white,
        body: body(),
        bottomNavigationBar: bottomNavBar(),
      ),
    );
  }

// filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
  Widget bottomNavBar() {
    return BlurryContainer(
      color: Colors.transparent,
      blur: 10,
      elevation: 0,
      height: 60,
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              right: 25,
              left: 25,
            ),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 30,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '2000',
                      style: InvestrendTheme.of(context)
                          .regular_w500_greyDarker
                          .copyWith(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                AvatarProfileButton(
                  fullname: 'Lo Kheng Hong',
                  size: 32,
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 6),
                            height: 14,
                            child: Image.asset(
                              'images/icons/person.png',
                            ),
                          ),
                          SizedBox(
                            width: 3.6,
                          ),
                          Text(
                            'Lo Kheng Hong',
                            style: InvestrendTheme.of(context)
                                .regular_w500_greyDarker
                                .copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(
                            width: 3.6,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 6),
                            height: 14,
                            child: Image.asset(
                              'images/icons/check_verified.png',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        '@kenghong',
                        style: InvestrendTheme.of(context)
                            .regular_w500_greyDarker
                            .copyWith(
                              fontSize: 13,
                              color: Color(0xff666666),
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '1.172pts',
                  style: InvestrendTheme.of(context)
                      .regular_w500_greyDarker
                      .copyWith(
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        color: Colors.white,
        margin: EdgeInsets.only(
          top: 20,
          bottom: 10,
          right: 14,
          left: 14,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 15,
                    margin: EdgeInsets.only(bottom: 30, top: 20),
                    child: Image.asset('images/icons/action_back.png'),
                  ),
                ),
                Transform.rotate(
                  angle: -math.pi / 2,
                  child: Container(
                    height: 15,
                    margin: EdgeInsets.only(bottom: 30, top: 20),
                    child: Image.asset(
                      'images/icons/menu_vertical_dots.png',
                      color: Color(0xffCCCCCC),
                    ),
                  ),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prediction',
                  style: InvestrendTheme.of(context)
                      .regular_w500_greyDarker
                      .copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Transaction will be only tracked if the user post the transaction',
                  style: InvestrendTheme.of(context)
                      .regular_w500_greyDarker
                      .copyWith(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                ),
                SizedBox(
                  height: 14,
                ),
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Icon(
                        Icons.info_outlined,
                        color: Color(0xff4462A8),
                        size: 13,
                      ),
                    ),
                    SizedBox(
                      width: 6.5,
                    ),
                    Container(
                      child: Text(
                        'Lihat detail perhitungan',
                        style: InvestrendTheme.of(context)
                            .regular_w500_greyDarker
                            .copyWith(
                              fontSize: 13,
                              color: Color(0xff4462A8),
                            ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedValue == "This Week"
                            ? '$selectedValue (Default)'
                            : selectedValue,
                        style: InvestrendTheme.of(context)
                            .regular_w500_greyDarker
                            .copyWith(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        height: 35,
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          border: Border.all(
                            color: Color(0xffDBDBDB),
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: selectedValue,
                          items: dropdownItems,
                          key: globalKey,
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                          onChanged: (String newValue) {
                            setState(() {
                              selectedValue = newValue;
                            });
                          },
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          underline: Container(),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFFDBDBDB),
                ),
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  listLeaderboards(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listLeaderboards() {
    listDummy.sort((a, b) => b.splitPoints.compareTo(a.splitPoints));
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: listDummy.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return index == 0
            ? Container(
                margin: EdgeInsets.only(
                  bottom: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 28),
                      child: AvatarProfileButton(
                        url: "https://freepngimg.com/thumb/man/22654-6-man.png",
                        fullname: ' ',
                        size: 64,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          listDummy[index]?.name != null
                              ? listDummy[index]?.name
                              : '',
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          width: 3.6,
                        ),
                        listDummy[index]?.verified == true
                            ? Container(
                                margin: EdgeInsets.only(top: 6),
                                height: 14,
                                child: Image.asset(
                                  'images/icons/check_verified.png',
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                    Text(
                      listDummy[index]?.username != null
                          ? listDummy[index]?.username
                          : '',
                      style: InvestrendTheme.of(context)
                          .regular_w500_greyDarker
                          .copyWith(
                            fontSize: 13,
                            color: Color(0xff666666),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ('${(index + 1).toString()}st'),
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 18,
                              ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 6),
                          height: 18,
                          width: 1,
                          color: Color(0xffECC249),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          listDummy[index]?.points != null
                              ? listDummy[index]?.points
                              : '',
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 18,
                              ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : Container(
                margin: EdgeInsets.only(
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        right: 10,
                        left: 10,
                      ),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                (index + 1).toString(),
                                style: InvestrendTheme.of(context)
                                    .regular_w500_greyDarker
                                    .copyWith(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          AvatarProfileButton(
                            url:
                                "https://freepngimg.com/thumb/man/22654-6-man.png",
                            fullname: ' ',
                            size: 32,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      listDummy[index]?.name != null
                                          ? listDummy[index]?.name
                                          : '',
                                      style: InvestrendTheme.of(context)
                                          .regular_w500_greyDarker
                                          .copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      width: 3.6,
                                    ),
                                    listDummy[index]?.verified == true
                                        ? Container(
                                            margin: EdgeInsets.only(top: 6),
                                            height: 14,
                                            child: Image.asset(
                                              'images/icons/check_verified.png',
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  listDummy[index]?.username != null
                                      ? listDummy[index]?.username
                                      : '',
                                  style: InvestrendTheme.of(context)
                                      .regular_w500_greyDarker
                                      .copyWith(
                                        fontSize: 13,
                                        color: Color(0xff666666),
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            listDummy[index]?.points != null
                                ? listDummy[index]?.points
                                : '',
                            style: InvestrendTheme.of(context)
                                .regular_w500_greyDarker
                                .copyWith(
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
      },
    );
    /*
    return Column(
      children: List.generate(listDummy.length, (index) {
        return Container(
          margin: EdgeInsets.only(
            bottom: 20,
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                  right: 10,
                  left: 10,
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 30,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          listDummy[index]?.rank != null
                              ? listDummy[index]?.rank
                              : '',
                          style: InvestrendTheme.of(context)
                              .regular_w500_greyDarker
                              .copyWith(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    AvatarProfileButton(
                      url: "https://freepngimg.com/thumb/man/22654-6-man.png",
                      fullname: ' ',
                      size: 32,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                listDummy[index]?.name != null
                                    ? listDummy[index]?.name
                                    : '',
                                style: InvestrendTheme.of(context)
                                    .regular_w500_greyDarker
                                    .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(
                                width: 3.6,
                              ),
                              listDummy[index]?.verified == true
                                  ? Container(
                                      margin: EdgeInsets.only(top: 6),
                                      height: 14,
                                      child: Image.asset(
                                        'images/icons/check_verified.png',
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            listDummy[index]?.username != null
                                ? listDummy[index]?.username
                                : '',
                            style: InvestrendTheme.of(context)
                                .regular_w500_greyDarker
                                .copyWith(
                                  fontSize: 13,
                                  color: Color(0xff666666),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      listDummy[index]?.points != null
                          ? listDummy[index]?.points
                          : '',
                      style: InvestrendTheme.of(context)
                          .regular_w500_greyDarker
                          .copyWith(
                            fontSize: 13,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
    */
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("This Week"), value: "This Week"),
      DropdownMenuItem(child: Text("Last Week"), value: "Last Week"),
      DropdownMenuItem(child: Text("Last Month"), value: "Last Month"),
      DropdownMenuItem(child: Text("Last 3 Month"), value: "Last 3 Month"),
    ];
    return menuItems;
  }
}

class LeaderboardsTransactionDummy {
  String image;
  String fullname;
  String name;
  bool verified;
  String points;
  String rank;
  String username;

  LeaderboardsTransactionDummy({
    this.image,
    this.fullname,
    this.name,
    this.verified,
    this.points,
    this.rank,
    this.username,
  });

  static List<LeaderboardsTransactionDummy> get dummy {
    return [
      LeaderboardsTransactionDummy(
        fullname: 'Muhammad Baresi',
        name: 'Muhammad Baresi',
        verified: true,
        rank: '1',
        username: '@webb.theresa',
        points: '800pts',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Muhammad Baresi',
        name: 'Muhammad Baresi',
        verified: false,
        rank: '2',
        points: '900pts',
        username: '@webb.theresa',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '1400pts',
        verified: true,
        rank: '2',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Muhammad Baresi',
        name: 'Muhammad Baresi',
        points: '1572pts',
        verified: true,
        rank: '3',
        username: '@webb.theresa',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Muhammad Baresi',
        name: 'Muhammad Baresi',
        points: '1132pts',
        verified: true,
        rank: '4',
        username: '@webb.theresa',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        verified: false,
        points: '1232pts',
        rank: '5',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '972pts',
        verified: false,
        rank: '6',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '894pts',
        verified: false,
        rank: '7',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '623pts',
        verified: false,
        rank: '8',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '833pts',
        verified: false,
        rank: '9',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '1292pts',
        verified: false,
        rank: '10',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Muhammad Baresi',
        name: 'Muhammad Baresi',
        points: '1354pts',
        verified: false,
        rank: '11',
        username: '@webb.theresa',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '1142pts',
        verified: false,
        rank: '12',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '1002pts',
        verified: true,
        rank: '13',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '1042pts',
        verified: false,
        rank: '14',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '1552pts',
        verified: true,
        rank: '15',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '1433pts',
        verified: false,
        rank: '16',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '1233pts',
        verified: false,
        rank: '17',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '1124pts',
        verified: false,
        rank: '18',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '1121pts',
        verified: false,
        rank: '19',
        username: '@khenghong',
      ),
      LeaderboardsTransactionDummy(
        fullname: 'Lo Kheng Hong',
        name: 'Lo Kheng Hong',
        points: '1111pts',
        verified: false,
        rank: '20',
        username: '@khenghong',
      ),
    ];
  }

  int get splitPoints {
    if (points != null && points != "") {
      return Utils.safeInt(points.split("pts")[0]);
    }
  }
}
