// ignore_for_file: unused_field, unused_local_variable, unnecessary_null_comparison, non_constant_identifier_names

import 'dart:async';
import 'dart:math';

import 'package:Investrend/component/button_account.dart';
import 'package:Investrend/component/button_banner_open_account.dart';
import 'package:Investrend/component/button_tab_switch.dart';
import 'package:Investrend/component/cards/card_ipo.dart';
import 'package:Investrend/component/cards/card_news.dart';
import 'package:Investrend/component/cards/card_stock_themes.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/grid_tiles.dart';
import 'package:Investrend/component/text_button_retry.dart';
import 'package:Investrend/component/text_colapsed.dart';
import 'package:Investrend/component/tile_price.dart';
import 'package:Investrend/component/widget_buying_power.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// import 'package:http/http.dart' as http;
// import 'package:xml/xml.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class WrapperHomeNotifier {
  StockThemeNotifier themeNotifier = StockThemeNotifier(new StockThemesData());
  BriefingNotifier briefingNotifier = BriefingNotifier(Briefing.createBasic());

  HomeIndicesNotifier indicesNotifier = HomeIndicesNotifier(HomeIndicesData());
  HomeCommoditiesNotifier commoditiesNotifier =
      HomeCommoditiesNotifier(HomeCommoditiesData());
  HomeCurrenciesNotifier currenciesNotifier =
      HomeCurrenciesNotifier(HomeCurrenciesData());
  HomeCryptoNotifier cryptoNotifier = HomeCryptoNotifier(HomeCryptoData());

  StockPositionNotifier stockPositionNotifier = StockPositionNotifier(
      new StockPosition('', 0, 0, 0, 0, 0, 0, List.empty(growable: true)));
  ValueNotifier<int> buttonPortfolioRankNotifier = ValueNotifier<int>(0);
  ValueNotifier<bool> returnNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> accountNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> hidePortfolioNotifier = ValueNotifier<bool>(false);

  void dispose() {
    indicesNotifier.dispose();
    commoditiesNotifier.dispose();
    currenciesNotifier.dispose();
    cryptoNotifier.dispose();
    buttonPortfolioRankNotifier.dispose();
    stockPositionNotifier.dispose();
    returnNotifier.dispose();
    accountNotifier.dispose();
    themeNotifier.dispose();
    briefingNotifier.dispose();
    hidePortfolioNotifier.dispose();
  }
}

class ScreenHome extends StatefulWidget {
  final WrapperHomeNotifier wrapperHomeNotifier;
  final BaseValueNotifier<bool>? visibilityNotifier;

  const ScreenHome(this.wrapperHomeNotifier,
      {Key? key, this.visibilityNotifier})
      : super(key: key);

  @override
  _ScreenHomeState createState() => _ScreenHomeState(this.wrapperHomeNotifier,
      visibilityNotifier: visibilityNotifier!);
}

class _ScreenHomeState extends BaseStateNoTabs<ScreenHome> {
  final WrapperHomeNotifier wrapper;

  // StockThemeNotifier wrapper.themeNotifier = StockThemeNotifier(new StockThemesData());
  // BriefingNotifier wrapper.briefingNotifier = BriefingNotifier(Briefing.createBasic());

  // HomeIndicesNotifier wrapper.indicesNotifier = HomeIndicesNotifier(HomeIndicesData());
  // HomeCommoditiesNotifier wrapper.commoditiesNotifier = HomeCommoditiesNotifier(HomeCommoditiesData());
  // HomeCurrenciesNotifier _currenciesNotifier = HomeCurrenciesNotifier(HomeCurrenciesData());
  // HomeCryptoNotifier wrapper.cryptoNotifier = HomeCryptoNotifier(HomeCryptoData());

  // StockPositionNotifier wrapper.stockPositionNotifier = StockPositionNotifier(new StockPosition('', 0, 0, 0, 0, 0, 0, List.empty(growable: true)));
  // final ValueNotifier<int> wrapper.buttonPortfolioRankNotifier = ValueNotifier<int>(0);
  // final ValueNotifier<bool> _returnNotifier = ValueNotifier<bool>(false);
  // final ValueNotifier<bool> wrapper.accountNotifier = ValueNotifier<bool>(false);

  //OfferingEIPONotifier _ipoNotifier = OfferingEIPONotifier(OfferingEIPOData());

  Timer? _timer;
  static const Duration _durationUpdate = Duration(milliseconds: 1000);
  bool _selectedHighest = true;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  _ScreenHomeState(this.wrapper, {BaseValueNotifier<bool>? visibilityNotifier})
      : super('/home', visibilityNotifier: visibilityNotifier!);

  //ValueNotifier<String> wrapper.accountNotifier = ValueNotifier('Ackerman - Reguler');
  /*
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      //padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0),
      child: Column(
        children: [

          createCardPortfolio(context),
          ComponentCreator.divider(context),

          createCardBriefing(context),
          ComponentCreator.divider(context),

          CardEIPO('home_card_eipo_title'.tr(), listEIPO),
          SizedBox(height: InvestrendTheme.cardPadding,),

          //createCardCompetition(context),
          CardCompetitions('home_card_competition_title'.tr(), listCompetition),
          SizedBox(height: InvestrendTheme.cardPadding,),
          ComponentCreator.divider(context),
          //createCardThemes(context),
          CardStockThemes('home_card_themes_title'.tr(), wrapper.themeNotifier),

          ComponentCreator.divider(context),
          //createCardProfiles(context),
          CardProfiles('home_card_profiles_title'.tr(), listProfiles),
          SizedBox(height: InvestrendTheme.cardPadding,),
          ComponentCreator.divider(context),

          CardNews('home_card_news_title'.tr(),),
          SizedBox(height: InvestrendTheme.cardPadding,),


          ComponentCreator.divider(context),
        ],
      ),
    );
  }
  */
  final List<String> button_portfolio_rank = [
    'home_card_portfolio_button_highest'.tr(),
    'home_card_portfolio_button_lowest'.tr(),
  ];

  //Future<List<HomeWorldIndices>> worldIndices;
  //Future<List<HomeNews>> news;

  @override
  void initState() {
    super.initState();

    print(routeName + ' initState aaaa');
    wrapper.buttonPortfolioRankNotifier.addListener(() {
      wrapper.returnNotifier.value = !wrapper.returnNotifier.value;
    });
    wrapper.stockPositionNotifier.addListener(() {
      wrapper.returnNotifier.value = !wrapper.returnNotifier.value;
    });
    wrapper.hidePortfolioNotifier.addListener(() {
      if (mounted) {
        context.read(propertiesNotifier).properties.saveBool(routeName,
            PROP_HIDE_PORTFOLIO, wrapper.hidePortfolioNotifier.value);
        wrapper.accountNotifier.value = !wrapper.accountNotifier.value;
      }
    });
    runPostFrame(() {
      if (!active) {
        active = true;
      }
      doUpdate(pullToRefresh: true);

      // scroll to Briefing
      /*
      Future.delayed(Duration(milliseconds: 500), () {
        bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
        int scrollToIndex = hasAccount ? 2 : 1;

        itemScrollController.scrollTo(
            index: scrollToIndex,
            duration: Duration(seconds: 1),
            curve: Curves.easeInOutCubic);
      });
      */

      // #1 get properties
      bool hidePortfolio = context
          .read(propertiesNotifier)
          .properties
          .getBool(routeName, PROP_HIDE_PORTFOLIO, false);

      // #2 use properties
      wrapper.hidePortfolioNotifier.value = hidePortfolio;

      // #3 check properties if changed, then save again
      //if(selectedSort != _sortNotifier.value){
      //context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_SORT, _sortNotifier.value);
      //}
    });

    // Future.delayed(Duration(milliseconds: 700), () {
    //   doUpdate(pullToRefresh: true);
    // });
    // Future.delayed(Duration(milliseconds: 500), () {
    //   Future<List<StockThemes>> themes = HttpSSI.fetchThemes();
    //   themes.then((value) {
    //     StockThemesData dataTheme = StockThemesData();
    //     if (value != null) {
    //       value.forEach((theme) {
    //         dataTheme.datas.add(theme);
    //       });
    //     }
    //     wrapper.themeNotifier.setValue(dataTheme);
    //   }).onError((error, stackTrace) {});
    //
    //
    //   /*
    //   StockThemesData dataTheme = StockThemesData();
    //   dataTheme.datas.add(HomeThemes('Digital Bank', 'Disrupting the financial sector at crazy valuations',
    //       'https://www.investrend.co.id/mobile/assets/themes/background_1.png'));
    //   dataTheme.datas.add(HomeThemes('Creative Economy', 'Companies recognaized for their creative contributions to indonesia',
    //       'https://www.investrend.co.id/mobile/assets/themes/background_2.png'));
    //   dataTheme.datas.add(HomeThemes('Work from Home', 'Companies that are making social distancing possible',
    //       'https://www.investrend.co.id/mobile/assets/themes/background_3.png'));
    //   dataTheme.datas.add(HomeThemes('Focus on Diversity', 'Companies with the most diverse and inclusive composition',
    //       'https://www.investrend.co.id/mobile/assets/themes/background_4.png'));
    //   dataTheme.datas.add(HomeThemes(
    //       'Sports and Beyond', 'Companies in the bussiness of sports', 'https://www.investrend.co.id/mobile/assets/themes/background_5.png'));
    //   dataTheme.datas.add(HomeThemes('Digital Bank', 'Disrupting the financial sector at crazy valuations',
    //       'https://www.investrend.co.id/mobile/assets/themes/background_1.png'));
    //   dataTheme.datas.add(HomeThemes('Creative Economy', 'Companies recognaized for their creative contributions to indonesia',
    //       'https://www.investrend.co.id/mobile/assets/themes/background_2.png'));
    //   dataTheme.datas.add(HomeThemes('Work from Home', 'Companies that are making social distancing possible',
    //       'https://www.investrend.co.id/mobile/assets/themes/background_3.png'));
    //
    //
    //   wrapper.themeNotifier.setValue(dataTheme);
    //   */
    // });
    // //worldIndices = HttpSSI.fetchWorldIndices();
    // news = HttpSSI.fetchNews();
    //
    // //Future<FetchPost> fetchPost = InvestrendTheme.sosMedHttp.fetch_post('123', InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
    // //Future<FetchPost> fetchPost = SosMedHttp.fetch_post('123', 'iOS', '1.0');
  }

  VoidCallback? onAccountChange;
  VoidCallback? onAccountData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('ScreenHome.didChangeDependencies ');

    // print('ScreenHome.didChangeDependencies ' + InvestrendTheme
    //     .of(context)
    //     .user
    //     .toString());
    DebugWriter.info('ScreenHome.didChangeDependencies ' +
        context.read(dataHolderChangeNotifier).user.toString());

    if (onAccountChange != null) {
      context.read(accountChangeNotifier).removeListener(onAccountChange!);
    } else {
      onAccountChange = () {
        if (mounted) {
          wrapper.accountNotifier.value = !wrapper.accountNotifier.value;
          doUpdate();
        }
      };
    }
    context.read(accountChangeNotifier).addListener(onAccountChange!);

    if (onAccountData != null) {
      context.read(accountsInfosNotifier).removeListener(onAccountData!);
    } else {
      onAccountData = () {
        if (mounted) {
          wrapper.accountNotifier.value = !wrapper.accountNotifier.value;
        }
      };
    }
    context.read(accountsInfosNotifier).addListener(onAccountData!);
    /*
    context.read(accountChangeNotifier).addListener(() {
      if (mounted) {
        wrapper.accountNotifier.value = !wrapper.accountNotifier.value;
        doUpdate();
      }
    });
    context.read(accountsInfosNotifier).addListener(() {
      if (mounted) {
        wrapper.accountNotifier.value = !wrapper.accountNotifier.value;
      }
    });

     */
  }

  @override
  void dispose() {
    print(routeName + ' dispose');
    // wrapper.briefingNotifier.dispose();
    // wrapper.indicesNotifier.dispose();
    // wrapper.commoditiesNotifier.dispose();
    // _currenciesNotifier.dispose();
    // wrapper.cryptoNotifier.dispose();
    // wrapper.buttonPortfolioRankNotifier.dispose();
    // wrapper.stockPositionNotifier.dispose();
    // _returnNotifier.dispose();
    // wrapper.accountNotifier.dispose();
    // wrapper.themeNotifier.dispose();
    //_timer?.cancel();
    _stopTimer();

    final container = ProviderContainer();
    if (onAccountChange != null) {
      container.read(accountChangeNotifier).removeListener(onAccountChange!);
    }
    if (onAccountData != null) {
      container.read(accountsInfosNotifier).removeListener(onAccountData!);
    }
    super.dispose();
  }

  /*
  Future<List<HomeWorldIndices>> fetchWorldIndices() async {
    final response =
        await http.get(Uri.http('trialr1.e-samuel.com', 'm_world_indices.php'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      print(response.body);
      final document = XmlDocument.parse(response.body);

      List<HomeWorldIndices> list =
          List<HomeWorldIndices>.empty(growable: true);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          list.add(HomeWorldIndices.fromXml(element));
        });
      }
      return list;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() +
          '  ' +
          response.reasonPhrase);
    }
  }
*/
  /*
  Future<HomeWorldIndices> fetchWorldIndices() async {
    final response = await http.get(Uri.http('trialr1.e-samuel.com', 'm_world_indices.php'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      listWorldIndices.clear();
      print(response.body);
      final document = XmlDocument.parse(response.body);
      //document.findElements(name)

      final x = document.findAllElements('a');
      x.forEach((element) {
        print('code : '+element.getAttribute('code'));
        HomeWorldIndices data = HomeWorldIndices(element.getAttribute('last'), element.getAttribute('code'), double.parse(element.getAttribute('change')), double.parse(element.getAttribute('percentChange')));
        listWorldIndices.add(data);
      });

      setState(() {

      });
      //return Album.fromJson(jsonDecode(response.body));
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
  */
  // @override
  // void dispose() {
  //
  //   super.dispose();
  // }

  //
  // @override
  // Widget build2(BuildContext context) {
  //   return CustomScrollView(
  //       slivers: [
  //         createCardPortfolio(context),
  //         createCardBriefing(context),
  //       ],
  //
  //   );
  // }

  static const double cardPadding = 8.0;
  static const double cardMargin = 8.0;
  List listHighest = List.empty(growable: true);
  List listLowest = List.empty(growable: true);

  // List listHighest = <HomePortfolio>[
  //   HomePortfolio('BBCA', 8750, 10.4),
  //   HomePortfolio('ELSA', 750, 8.4),
  //   HomePortfolio('ARTO', 350, 3.4),
  // ];
  //
  // List listLowest = <HomePortfolio>[
  //   HomePortfolio('BBRI', 6750, 0.0),
  //   HomePortfolio('BNBR',50, -4.18),
  //   HomePortfolio('BUMI',400, -9.44),
  // ];
  /*
  List listEIPO = <HomeEIPO>[
    HomeEIPO(
        'https://cdn.iconscout.com/icon/free/png-256/cnbc-283625.png',
        'BMHS',
        'PT Bundamedik Tbk',
        'Healthcare',
        'Healthcare Providers',
        'Perseroan adalah penyedia layanan kesehatan khusus di Indonesia dengan rekam jejak dan keahlian yang kuat dalam perawatan premium untuk wanita dan anak-anak yang didukung oleh ekosistem layanan kesehatan yang terintegrasi. Perseroan didirikan oleh Dr. Rizal Sini, SpOG, seorang praktisi medis senior yang bercita-cita untuk melayani kebutuhan kesehatan di Indonesia. Rumah sakit Perseroan telah mendapatkan reputasi yang baik dalam industri kesehatan baik di dalam dan maupun di luar Indonesia. Dr. Ivan Sini, SpOG (penerus dan putra tertua dari Dr. Rizal Sini) adalah salah satu manajemen kunci dan juga seorang ahli kebidanan dan ginekologi terkemuka di Indonesia dan menjadi pembicara terkemuka di forum-forum dan simposium in-vitro fertilization (IVF).\n\nPerseroan membuka rumah sakit pertamanya pada tahun 1973, dengan nama Rumah Sakit Ibu dan Anak Bunda Jakarta. Sejak itu Perseroan terus berkembang melalui pendirian rumah sakit baru maupun akuisisi rumah sakit yang sudah berdiri. Per tanggal 31 Desember 2020, Perseroan telah mengoperasikan 5 rumah sakit yang terdiri dari 2 rumah sakit ibu dan anak dan 3 rumah sakit umum. Selain itu Perseroan juga mengoperasikan 2 klinik yang berada di wilayah Jabodetabek.\n\nPerseroan menawarkan layanan kesehatan spesialis yang lengkap seperti prosedur bedah kompleks, layanan laboratorium, fasilitas radiologi dan imaging, layanan kesehatan umum dan layanan diagnostik dan darurat di Indonesia. Pada tanggal 31 Desember 2020, Perseroan memiliki kapasitas sekitar 336 jumlah tempat tidur dan mempekerjakan lebih dari 56 dokter umum dan 389 spesialis yang menawarkan layanan ke pasien Perseroan dan sekitar 1.643 perawat dan staf pendukung lainnya. Perseroan berencana untuk mengembangkan usahanya melalui pendirian rumah sakit baru, pengembangan rumah sakit Perseroan yang sudah berdiri dan akuisisi rumah sakit yang berpotensi baik.\n\nDalam perjalanannya, Perseroan terus berupaya untuk mengembangkan usahanya dengan tujuan untuk membentuk platform kesehatan yang terintegrasi. Di samping bisnis rumah sakit dan klinik, Perseroan memiliki jaringan klinik bayi tabung di bawah brand Morula IVF yang bertujuan untuk memberikan solusi bagi pasangan-pasangan yang memiliki masalah ketidaksuburan (infertility), jaringan laboratorium diagnostik di bawah brand Diagnos (DGNS) yang mengkhususkan diri dalam pengembangan tes genomic, serta perusahaan farmasi yang bertujuan untuk mengintegrasikan pembelian obat-obatan dan pengembangan produk-produk baru di dalam grup Perseroan. Pada tanggal 31 Desember 2020, Perseroan memiliki 10 klinik IVF dan 14 laboratorium diagnostik yang tersebar di berbagai wilayah di Indonesia.\n\nPerseroan bermaksud untuk melakukan penawaran umum perdana dalam rangka memperkuat permodalan seiring rencana Perseroan untuk terus mengembangkan jaringan layanan kesehatan Perseroan di masa yang akan datang dengan harapan agar Perseroan dapat tetap tumbuh dan menjadi salah satu grup penyedia layanan kesehatan paling terkemuka di Indonesia.',
        'Jl. Teuku Cik Ditiro No. 28, Menteng Jakarta 10350 - Indonesia',
        'https://www.bmhs.co.id',
        6200000,
        7.26,
        'KI - CIPTADANA SEKURITAS ASIA',
        'KI - CIPTADANA SEKURITAS ASIA',
        '17 Jun 2021',
        '22 Jun 2021',
        300,
        350,
        '30 Jun 2021',
        '02 Jun 2021',
        340,
        '02 Jul 2021',
        '05 Jul 2021',
        '06 Jul 2021',
        'http://www.africau.edu/images/default/sample.pdf',
        'http://www.africau.edu/images/default/sample.pdf',
        'http://www.africau.edu/images/default/sample.pdf'),
    HomeEIPO(
        'https://cdn.iconscout.com/icon/free/png-256/cnbc-283625.png',
        'BMHS',
        'PT Bundamedik Tbk',
        'Healthcare',
        'Healthcare Providers',
        'Perseroan adalah penyedia layanan kesehatan khusus di Indonesia dengan rekam jejak dan keahlian yang kuat dalam perawatan premium untuk wanita dan anak-anak yang didukung oleh ekosistem layanan kesehatan yang terintegrasi. Perseroan didirikan oleh Dr. Rizal Sini, SpOG, seorang praktisi medis senior yang bercita-cita untuk melayani kebutuhan kesehatan di Indonesia. Rumah sakit Perseroan telah mendapatkan reputasi yang baik dalam industri kesehatan baik di dalam dan maupun di luar Indonesia. Dr. Ivan Sini, SpOG (penerus dan putra tertua dari Dr. Rizal Sini) adalah salah satu manajemen kunci dan juga seorang ahli kebidanan dan ginekologi terkemuka di Indonesia dan menjadi pembicara terkemuka di forum-forum dan simposium in-vitro fertilization (IVF).\n\nPerseroan membuka rumah sakit pertamanya pada tahun 1973, dengan nama Rumah Sakit Ibu dan Anak Bunda Jakarta. Sejak itu Perseroan terus berkembang melalui pendirian rumah sakit baru maupun akuisisi rumah sakit yang sudah berdiri. Per tanggal 31 Desember 2020, Perseroan telah mengoperasikan 5 rumah sakit yang terdiri dari 2 rumah sakit ibu dan anak dan 3 rumah sakit umum. Selain itu Perseroan juga mengoperasikan 2 klinik yang berada di wilayah Jabodetabek.\n\nPerseroan menawarkan layanan kesehatan spesialis yang lengkap seperti prosedur bedah kompleks, layanan laboratorium, fasilitas radiologi dan imaging, layanan kesehatan umum dan layanan diagnostik dan darurat di Indonesia. Pada tanggal 31 Desember 2020, Perseroan memiliki kapasitas sekitar 336 jumlah tempat tidur dan mempekerjakan lebih dari 56 dokter umum dan 389 spesialis yang menawarkan layanan ke pasien Perseroan dan sekitar 1.643 perawat dan staf pendukung lainnya. Perseroan berencana untuk mengembangkan usahanya melalui pendirian rumah sakit baru, pengembangan rumah sakit Perseroan yang sudah berdiri dan akuisisi rumah sakit yang berpotensi baik.\n\nDalam perjalanannya, Perseroan terus berupaya untuk mengembangkan usahanya dengan tujuan untuk membentuk platform kesehatan yang terintegrasi. Di samping bisnis rumah sakit dan klinik, Perseroan memiliki jaringan klinik bayi tabung di bawah brand Morula IVF yang bertujuan untuk memberikan solusi bagi pasangan-pasangan yang memiliki masalah ketidaksuburan (infertility), jaringan laboratorium diagnostik di bawah brand Diagnos (DGNS) yang mengkhususkan diri dalam pengembangan tes genomic, serta perusahaan farmasi yang bertujuan untuk mengintegrasikan pembelian obat-obatan dan pengembangan produk-produk baru di dalam grup Perseroan. Pada tanggal 31 Desember 2020, Perseroan memiliki 10 klinik IVF dan 14 laboratorium diagnostik yang tersebar di berbagai wilayah di Indonesia.\n\nPerseroan bermaksud untuk melakukan penawaran umum perdana dalam rangka memperkuat permodalan seiring rencana Perseroan untuk terus mengembangkan jaringan layanan kesehatan Perseroan di masa yang akan datang dengan harapan agar Perseroan dapat tetap tumbuh dan menjadi salah satu grup penyedia layanan kesehatan paling terkemuka di Indonesia.',
        'Jl. Teuku Cik Ditiro No. 28, Menteng Jakarta 10350 - Indonesia',
        'https://www.bmhs.co.id',
        6200000,
        7.26,
        'KI - CIPTADANA SEKURITAS ASIA',
        'KI - CIPTADANA SEKURITAS ASIA',
        '17 Jun 2021',
        '22 Jun 2021',
        300,
        350,
        '30 Jun 2021',
        '02 Jun 2021',
        340,
        '02 Jul 2021',
        '05 Jul 2021',
        '06 Jul 2021',
        'http://www.africau.edu/images/default/sample.pdf',
        'http://www.africau.edu/images/default/sample.pdf',
        'http://www.africau.edu/images/default/sample.pdf'),
    HomeEIPO(
        'https://cdn.iconscout.com/icon/free/png-256/cnbc-283625.png',
        'BMHS',
        'PT Bundamedik Tbk',
        'Healthcare',
        'Healthcare Providers',
        'Perseroan adalah penyedia layanan kesehatan khusus di Indonesia dengan rekam jejak dan keahlian yang kuat dalam perawatan premium untuk wanita dan anak-anak yang didukung oleh ekosistem layanan kesehatan yang terintegrasi. Perseroan didirikan oleh Dr. Rizal Sini, SpOG, seorang praktisi medis senior yang bercita-cita untuk melayani kebutuhan kesehatan di Indonesia. Rumah sakit Perseroan telah mendapatkan reputasi yang baik dalam industri kesehatan baik di dalam dan maupun di luar Indonesia. Dr. Ivan Sini, SpOG (penerus dan putra tertua dari Dr. Rizal Sini) adalah salah satu manajemen kunci dan juga seorang ahli kebidanan dan ginekologi terkemuka di Indonesia dan menjadi pembicara terkemuka di forum-forum dan simposium in-vitro fertilization (IVF).\n\nPerseroan membuka rumah sakit pertamanya pada tahun 1973, dengan nama Rumah Sakit Ibu dan Anak Bunda Jakarta. Sejak itu Perseroan terus berkembang melalui pendirian rumah sakit baru maupun akuisisi rumah sakit yang sudah berdiri. Per tanggal 31 Desember 2020, Perseroan telah mengoperasikan 5 rumah sakit yang terdiri dari 2 rumah sakit ibu dan anak dan 3 rumah sakit umum. Selain itu Perseroan juga mengoperasikan 2 klinik yang berada di wilayah Jabodetabek.\n\nPerseroan menawarkan layanan kesehatan spesialis yang lengkap seperti prosedur bedah kompleks, layanan laboratorium, fasilitas radiologi dan imaging, layanan kesehatan umum dan layanan diagnostik dan darurat di Indonesia. Pada tanggal 31 Desember 2020, Perseroan memiliki kapasitas sekitar 336 jumlah tempat tidur dan mempekerjakan lebih dari 56 dokter umum dan 389 spesialis yang menawarkan layanan ke pasien Perseroan dan sekitar 1.643 perawat dan staf pendukung lainnya. Perseroan berencana untuk mengembangkan usahanya melalui pendirian rumah sakit baru, pengembangan rumah sakit Perseroan yang sudah berdiri dan akuisisi rumah sakit yang berpotensi baik.\n\nDalam perjalanannya, Perseroan terus berupaya untuk mengembangkan usahanya dengan tujuan untuk membentuk platform kesehatan yang terintegrasi. Di samping bisnis rumah sakit dan klinik, Perseroan memiliki jaringan klinik bayi tabung di bawah brand Morula IVF yang bertujuan untuk memberikan solusi bagi pasangan-pasangan yang memiliki masalah ketidaksuburan (infertility), jaringan laboratorium diagnostik di bawah brand Diagnos (DGNS) yang mengkhususkan diri dalam pengembangan tes genomic, serta perusahaan farmasi yang bertujuan untuk mengintegrasikan pembelian obat-obatan dan pengembangan produk-produk baru di dalam grup Perseroan. Pada tanggal 31 Desember 2020, Perseroan memiliki 10 klinik IVF dan 14 laboratorium diagnostik yang tersebar di berbagai wilayah di Indonesia.\n\nPerseroan bermaksud untuk melakukan penawaran umum perdana dalam rangka memperkuat permodalan seiring rencana Perseroan untuk terus mengembangkan jaringan layanan kesehatan Perseroan di masa yang akan datang dengan harapan agar Perseroan dapat tetap tumbuh dan menjadi salah satu grup penyedia layanan kesehatan paling terkemuka di Indonesia.',
        'Jl. Teuku Cik Ditiro No. 28, Menteng Jakarta 10350 - Indonesia',
        'https://www.bmhs.co.id',
        6200000,
        7.26,
        'KI - CIPTADANA SEKURITAS ASIA',
        'KI - CIPTADANA SEKURITAS ASIA',
        '17 Jun 2021',
        '22 Jun 2021',
        300,
        350,
        '30 Jun 2021',
        '02 Jun 2021',
        340,
        '02 Jul 2021',
        '05 Jul 2021',
        '06 Jul 2021',
        'http://www.africau.edu/images/default/sample.pdf',
        'http://www.africau.edu/images/default/sample.pdf',
        'http://www.africau.edu/images/default/sample.pdf'),
  ];
  */
  /*
  List<HomeWorldIndices> listWorldIndices = <HomeWorldIndices>[
    HomeWorldIndices('DJIA', 'Dow Jones', -200, -0.33, 100),
    HomeWorldIndices('DJIF', 'Dow Fut', 200, 0.33, 900),
    HomeWorldIndices('N225', 'NIKKEI', 200, 0.33, 800),
    HomeWorldIndices('HSI', 'Hang Seng', -200, -0.33, 500),
    HomeWorldIndices('IHSG', 'Composite', -200, -0.33, 700),
  ];

  List<HomeCommodities> listCommodities = <HomeCommodities>[
    HomeCommodities('Oil', 63.44, -0.33),
    HomeCommodities('Coal', 78.70, 0.33),
    HomeCommodities('Nat Gas', 2.95, -0.33),
    HomeCommodities('CPO', 3540, -0.33),
    HomeCommodities('Gold', 1807, -0.33),
    HomeCommodities('Silver', 28.30, 0.33),
    HomeCommodities('Copper', 412.90, -0.33),
    HomeCommodities('Platinum', 0, 0.0),
    HomeCommodities('Tin', 26840, 0.33),
    HomeCommodities('Nickel', 1274, -0.33),
    HomeCommodities('Zinc', 2890, 0.33),
    HomeCommodities('Alumunium', 2174, -0.33),
  ];
  List<HomeCurrencies> listCurrencies = <HomeCurrencies>[
    HomeCurrencies('USD/IDR', 14013, 3.33),
    HomeCurrencies('SGD/IDR', 63.70, -0.14),
    HomeCurrencies('NZD/IDR', 775032102, 12.33),
  ];

  List<HomeCurrencies> listCrytoCurrencies = <HomeCurrencies>[
    HomeCurrencies('DOGE/IDR', 14013, 3.33),
    HomeCurrencies('ETH/IDR', 63.70, -0.14),
    HomeCurrencies('BTC/IDR', 775032102, 12.33),
  ];

  List<HomeNews> listNews = <HomeNews>[
    HomeNews(
        'Apple akan hadirkan kembali platform media sosial Parler ke App Store',
        'Apple Inc akan kembali menghadirkan aplikasi media sosial Parler, yang disukai oleh kaum konservatif di Amerika Serikat, di&nbsp;App Store setelah sempat ditarik menyusul kerusuhan Capitol yang mematikan pada 6 Januari ...',
        'https://www.antaranews.com/berita/2110802/apple-akan-hadirkan-kembali-platform-media-sosial-parler-ke-app-store',
        'https://img.antaranews.com/cache/800x533/2021/02/17/2021-01-14T000000Z_1937767962_MT1SIPA0006PHF5M_RTRMADP_3_SIPA-USA.jpg',
        'Tue, 20 Apr 2021 13:37:35 +0700',
        'Techno',
        4,
        10),
    HomeNews(
        'Jokic pimpin Nuggets libas Grizzlies lewat dua kali overtime',
        'Nikola Jokic mencetak 47 poin termasuk sebuah lemparan tiga poin yang menentukan pada overtime kedua yang membawa Denver Nuggets menghempaskan Memphis Grizzlies 139-137 di Ball Arena, Denver, Colorado, Senin (Selasa ...',
        'https://www.antaranews.com/berita/2110798/jokic-pimpin-nuggets-libas-grizzlies-lewat-dua-kali-overtime',
        'https://img.antaranews.com/cache/800x533/2021/04/20/Screenshot_3.jpg',
        'Tue, 20 Apr 2021 13:37:02 +0700',
        'Sports',
        10,
        2),
    HomeNews(
        'Pameran Auto Shanghai 2021',
        'A staff member cleans a Volvo S90 sedan displayed during a media day for the Auto Shanghai show in Shanghai, China April 20, 2021. REUTERS/Aly Song',
        'https://otomotif.antaranews.com/foto/2110790/pameran-auto-shanghai-2021',
        'https://img.antaranews.com/cache/800x533/2021/04/20/2021-04-20T051706Z_1324204388_RC2HZM9XL9HD_RTRMADP_3_AUTOSHOW-SHANGHAI-VOLVO.jpg',
        'Tue, 20 Apr 2021 13:29:01 +0700',
        'Auto',
        11,
        22),
  ];
  */
  //String name;
  //int rank;
  //int participant_size;
  //List participants_avatar;
  List<HomeProfiles> listProfiles = <HomeProfiles>[
    HomeProfiles(
        'Belvin Tannadi',
        'Owner @belvinvvip, komunitas saham retail terbesar di indonesia',
        'https://www.investrend.co.id/mobile/assets/profiles/profile_1.png'),
    HomeProfiles(
        'Lo Kheng Hong',
        'Lo Kheng Hong sebagai investor saham disebut sebut sebagai Warren Buffet-nya Indonesia.',
        'https://www.investrend.co.id/mobile/assets/profiles/profile_2.png'),
  ];
  List<HomeThemes>? listThemes = <HomeThemes>[
    HomeThemes(
        'Digital Bank',
        'Disrupting the financial sector at crazy valuations',
        'https://www.investrend.co.id/mobile/assets/themes/background_1.png'),
    HomeThemes(
        'Creative Economy',
        'Companies recognaized for their creative contributions to indonesia',
        'https://www.investrend.co.id/mobile/assets/themes/background_2.png'),
    HomeThemes(
        'Work from Home',
        'Companies that are making social distancing possible',
        'https://www.investrend.co.id/mobile/assets/themes/background_3.png'),
    HomeThemes(
        'Focus on Diversity',
        'Companies with the most diverse and inclusive composition',
        'https://www.investrend.co.id/mobile/assets/themes/background_4.png'),
    HomeThemes('Sports and Beyond', 'Companies in the bussiness of sports',
        'https://www.investrend.co.id/mobile/assets/themes/background_5.png'),
    HomeThemes(
        'Digital Bank',
        'Disrupting the financial sector at crazy valuations',
        'https://www.investrend.co.id/mobile/assets/themes/background_1.png'),
    HomeThemes(
        'Creative Economy',
        'Companies recognaized for their creative contributions to indonesia',
        'https://www.investrend.co.id/mobile/assets/themes/background_2.png'),
    HomeThemes(
        'Work from Home',
        'Companies that are making social distancing possible',
        'https://www.investrend.co.id/mobile/assets/themes/background_3.png'),
  ];
  List<HomeCompetition> listCompetition = <HomeCompetition>[
    HomeCompetition(
        'Kompetisi Keren',
        4,
        12,
        'https://www.investrend.co.id/mobile/assets/competition/background_1.png',
        <String>[
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmJaEK71AwtaHZvhvBQioHWW2MGi4ukH1_9w&usqp=CAU',
          'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSiJinli8IBVIpd5Un3l2uUuMb9iIXihrGobg&usqp=CAU',
        ]),
    HomeCompetition(
        'Best of the Best',
        3,
        15,
        'https://www.investrend.co.id/mobile/assets/competition/background_2.png',
        <String>[
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU',
          'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmJaEK71AwtaHZvhvBQioHWW2MGi4ukH1_9w&usqp=CAU',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU',
        ]),
  ];

  // void showSnackBar(BuildContext context, String text) {
  //   final snackBar = SnackBar(content: Text(text), duration: Duration(seconds: 1),);
  //
  //   // Find the ScaffoldMessenger in the widget tree
  //   // and use it to show a SnackBar.
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }
  /*
  Widget createCardThemes(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(cardMargin),
      child: Padding(
        padding: const EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ComponentCreator.subtitleButtonMore(
              context,
              'home_card_themes_title'.tr(),
              () {
                InvestrendTheme.of(context).showSnackBar(context, "Action Themes More");
              },
            ),
            gridThemes(context),
          ],
        ),
      ),
    );
  }
  */
  /*
  Widget tileNews(BuildContext context, HomeNews news) {

    return Padding(
      padding: const EdgeInsets.only(top: cardPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(InvestrendTheme.of(context).tileRoundedRadius),
        child: Container(
          // decoration: BoxDecoration(
          //   color: InvestrendTheme.of(context).tileBackground,
          //   // borderRadius: BorderRadius.circular(
          //   //     InvestrendTheme.of(context).tileRoundedRadius),
          // ),
          color: InvestrendTheme.of(context).tileBackground,
          //margin: const EdgeInsets.only(top: cardMargin),
          //padding: const EdgeInsets.only( left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
          //color: InvestrendTheme.of(context).tileBackground,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                InvestrendTheme.of(context).showSnackBar(context, 'Action news');
              },
              child: Padding(
                padding: EdgeInsets.only(
                    left: InvestrendTheme.of(context).tileRoundedRadius,
                    right: InvestrendTheme.of(context).tileRoundedRadius,
                    top: InvestrendTheme.of(context).tileSmallRoundedRadius,
                    bottom: InvestrendTheme.of(context).tileSmallRoundedRadius),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(InvestrendTheme.of(context).tileSmallRoundedRadius),
                            child: ComponentCreator.imageNetwork(news.url_tumbnail, width: 60, height: 60, fit: BoxFit.fill)),
                        SizedBox(
                          width: cardMargin,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.title,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 18.0),
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                news.time + '  |  ' + news.category,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.overline.copyWith(letterSpacing: 0.1),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: cardMargin,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      news.description,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(color: InvestrendTheme.of(context).textGrey, height: 1.5),
                      maxLines: 2,
                    ),
                    Row(
                      children: [
                        IconButton(
                            icon: Image.asset('images/icons/comment.png'),
                            onPressed: () {
                              InvestrendTheme.of(context).showSnackBar(context, 'Action Comment ');
                            }),
                        Text(news.commentCount.toString()),
                        IconButton(
                            icon: Image.asset('images/icons/like.png'),
                            onPressed: () {
                              InvestrendTheme.of(context).showSnackBar(context, 'Action Like ');
                            }),
                        Text(news.likedCount.toString()),
                        Spacer(
                          flex: 1,
                        ),
                        IconButton(
                            icon: Image.asset('images/icons/share.png'),
                            onPressed: () {
                              InvestrendTheme.of(context).showSnackBar(context, 'Action Share ');
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  */
  /*
  Widget createCardNews(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(cardMargin),
      child: Padding(
        padding: const EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ComponentCreator.subtitleButtonMore(
              context,
              'home_card_news_title'.tr(),
              () {
                InvestrendTheme.of(context).showSnackBar(context, "Action News More");
              },
            ),
            // tileNews(context, listNews[0]),
            // tileNews(context, listNews[1]),
            // tileNews(context, listNews[2]),

            FutureBuilder<List<HomeNews>>(
              future: news,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //return Text(snapshot.data.length.toString(), style: Theme.of(context).textTheme.bodyText2,);
                  if (snapshot.data.length > 0) {
                    List<Widget> list = List.empty(growable: true);
                    int maxCount = snapshot.data.length > 3 ? 3 : snapshot.data.length;
                    for (int i = 0; i < maxCount; i++) {
                      //list.add(tileNews(context, snapshot.data[i]));
                      list.add(ComponentCreator.tileNews(
                        context,
                        snapshot.data[i],
                        commentClick: () {
                          InvestrendTheme.of(context).showSnackBar(context, 'commentClick');
                        },
                        likeClick: () {
                          InvestrendTheme.of(context).showSnackBar(context, 'likeClick');
                        },
                        shareClick: () {
                          InvestrendTheme.of(context).showSnackBar(context, 'shareClick');
                        },
                      ));
                    }

                    return Column(
                      children: list,
                    );
                    //return gridWorldIndices(context, snapshot.data);
                  } else {
                    return Center(
                        child: Text(
                      'No Data',
                      style: Theme.of(context).textTheme.bodyText2,
                    ));
                  }
                } else if (snapshot.hasError) {
                  return Center(
                      child: Column(
                        children: [
                          Text("${snapshot.error}",
                              maxLines: 10, style: Theme.of(context).textTheme.bodyText2.copyWith(color: Theme.of(context).errorColor)),
                          OutlinedButton(
                              onPressed: () {
                                news = HttpSSI.fetchNews();
                              },
                              child: Text('button_retry'.tr())),
                        ],
                      ));
                  // return Center(
                  //     child:
                  //         Text("${snapshot.error}", style: Theme.of(context).textTheme.bodyText2.copyWith(color: Theme.of(context).errorColor)));
                }

                // By default, show a loading spinner.
                return Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget createCardProfiles(BuildContext context) {
    //double width = MediaQuery.of(context).size.width;
    //double tileWidth = width * 0.8;
    return Card(
      margin: const EdgeInsets.all(cardMargin),
      child: Padding(
          padding: const EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ComponentCreator.subtitle(
                context,
                'home_card_profiles_title'.tr(),
              ),
              SizedBox(
                height: cardMargin,
              ),
              LayoutBuilder(builder: (context, constrains) {
                print('constrains ' + constrains.maxWidth.toString());
                double tileWidth = constrains.maxWidth * 0.8;
                //double height = 200.0;
                double height = tileWidth * 0.687;
                return SizedBox(
                  height: height,
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: listProfiles.length,
                    itemBuilder: (BuildContext context, int index) {
                      double left = index == 0 ? 0 : 10.0;
                      return tileProfile(listProfiles[index], left, tileWidth, height);
                    },
                  ),
                );
              }),
            ],
          )),
    );
  }

  Widget tileProfile(HomeProfiles profile, double leftPadding, double widthTile, double heightTile) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(InvestrendTheme.of(context).tileRoundedRadius),
        child: SizedBox(
          width: widthTile,
          height: heightTile,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ComponentCreator.imageNetwork(
                profile.url_background,
                fit: BoxFit.fill,
                width: widthTile,
                height: heightTile,
              ),
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.center,
                  colors: [
                    Colors.black87,
                    Colors.black12,
                  ],
                )),
              ),
              Positioned.fill(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        splashColor: Theme.of(context).accentColor,
                        onTap: () {
                          InvestrendTheme.of(context).showSnackBar(context, 'Action Profile detail');
                        })),
              ),
              IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: widthTile / 2,
                        child: Text(
                          profile.name,
                          style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: cardPadding,
                      ),
                      SizedBox(
                        width: widthTile / 2,
                        child: Text(
                          profile.description,
                          maxLines: 5,
                          //overflow: TextOverflow.ellipsis,
                          //style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.white),
                          style: InvestrendTheme.of(context).support_w400.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    /*
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: [
              Image.network(
                profile.url_background,
                fit: BoxFit.fill,
                width: widthTile,
                height: heightTile,
              ),
              Positioned.fill(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        splashColor: Theme.of(context).accentColor,
                        onTap: () {
                          showSnackBar(context, 'Action Competition detail');
                        })),
              ),
              IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          profile.name,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      FittedBox(
                        child: Text(
                          profile.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

     */
  }

  Widget createCardCompetition(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double tileWidth = width * 0.7;
    return Card(
      margin: const EdgeInsets.all(cardMargin),
      child: Padding(
          padding: const EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ComponentCreator.subtitleButtonMore(context, 'home_card_competition_title'.tr(), () {
                InvestrendTheme.of(context).showSnackBar(context, "Action Competition More");
              }),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     ComponentCreator.subtitle(context, 'home_card_competition_title'.tr()),
              //     getButtonIconHorizontal(
              //         context,
              //         'images/icons/arrow_forward.png',
              //         'button_more'.tr(),
              //         Theme.of(context).accentColor,
              //         () {}),
              //   ],
              // ),

              LayoutBuilder(builder: (context, constrains) {
                print('constrains ' + constrains.maxWidth.toString());
                double tileWidth = constrains.maxWidth * 0.8;
                //double height = 180.0;
                double height = tileWidth * 0.6;
                return SizedBox(
                  height: height,
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: listCompetition.length,
                    itemBuilder: (BuildContext context, int index) {
                      double left = index == 0 ? 0 : 10.0;
                      return tileCompetition(listCompetition[index], left, tileWidth, height);
                    },
                  ),
                );
              }),

              // SizedBox(
              //   height: 180.0,
              //   child: ListView.builder(
              //     physics: ClampingScrollPhysics(),
              //     shrinkWrap: true,
              //     scrollDirection: Axis.horizontal,
              //     itemCount: listCompetition.length,
              //     itemBuilder: (BuildContext context, int index) {
              //       double left = index == 0 ? 0 : 10.0;
              //       return tileCompetition(listCompetition[index], left);
              //     },
              //   ),
              // ),
            ],
          )),
    );
  }


  Widget tileCompetition(HomeCompetition competition, double leftPadding, double widthTile, double heightTile) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: ClipRRect(
        //borderRadius: BorderRadius.circular(InvestrendTheme.of(context).tileRoundedRadius),
        borderRadius: BorderRadius.circular(14.0),
        child: SizedBox(
          width: widthTile,
          height: heightTile,
          child: Stack(
            children: [
              ComponentCreator.imageNetwork(
                competition.url_background,
                fit: BoxFit.fill,
                width: widthTile,
                height: heightTile,
              ),
              /*
              Image.network(
                competition.url_background,
                fit: BoxFit.fill,
                width: widthTile,
                height: heightTile,
                // loadingBuilder: (context, child, loadingProgress) {
                //   if (loadingProgress == null) return child;
                //
                //   return Center(child: CircularProgressIndicator());
                //   // You can use LinearProgressIndicator or CircularProgressIndicator instead
                // },
                // errorBuilder: (context, error, stackTrace) =>
                //     Text('Some errors occurred!'),

              ),

               */
              Positioned.fill(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        splashColor: Theme.of(context).accentColor,
                        onTap: () {
                          InvestrendTheme.of(context).showSnackBar(context, 'Action Competition detail');
                        })),
              ),
              IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        competition.name,
                        style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('images/icons/trophy.png'),
                          Text(
                            'Rank #' + competition.rank.toString(),
                            style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Text(
                        competition.participant_size.toString() + ' Partisipan',
                        style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.white),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      AvatarListCompetition(
                        size: 25,
                        participants_avatar: competition.participants_avatar,
                        total_participant: competition.participant_size,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    /*
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Stack(
        children: [
          Image.network(
            competition.url_background,
            fit: BoxFit.fitWidth,
          ),
          Positioned.fill(
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    splashColor: Theme.of(context).accentColor,
                    onTap: () {
                      InvestrendTheme.of(context).showSnackBar(context, 'Action Competition detail');
                    })),
          ),
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition.name,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: Colors.white),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('images/icons/trophy.png'),
                      Text(
                        'Rank #' + competition.rank.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Text(
                    competition.participant_size.toString() + ' Partisipan',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: Colors.white),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  AvatarListCompetition(
                    size: 25,
                    participants_avatar: competition.participants_avatar,
                    total_participant: competition.participant_size,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

     */
  }
  */
  void updateStockPositionActiveAccount() async {
    if (!mounted) {
      return;
    }
    int selected = context.read(accountChangeNotifier).index;
    //Account account = InvestrendTheme.of(context).user.getAccount(selected);
    Account? account =
        context.read(dataHolderChangeNotifier).user.getAccount(selected);

    if (account == null) {
      //String text = 'No Account Selected. accountSize : ' + InvestrendTheme.of(context).user.accountSize().toString();

      //String text = routeName + ' No Account Selected. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
      String errorNoAccount = 'error_no_account_selected'.tr();
      String text = routeName +
          ' $errorNoAccount. accountSize : ' +
          context.read(dataHolderChangeNotifier).user.accountSize().toString();

      InvestrendTheme.of(context).showSnackBar(context, text);
      return;
    } else {
      try {
        print(routeName + ' try stockPosition');
        final stockPosition = await InvestrendTheme.tradingHttp.stock_position(
            account.brokercode,
            account.accountcode,
            context.read(dataHolderChangeNotifier).user.username!,
            InvestrendTheme.of(context).applicationPlatform,
            InvestrendTheme.of(context).applicationVersion);
        DebugWriter.information(routeName +
            ' Got stockPosition ' +
            stockPosition.accountcode! +
            '   stockList.size : ' +
            stockPosition.stockListSize().toString());

        wrapper.stockPositionNotifier.setValue(stockPosition);
      } catch (e) {
        DebugWriter.information(
            routeName + ' stockPosition Exception : ' + e.toString());
        print(e);
        //print(Trace.from(e));
        handleNetworkError(context, e);
        /*
        if (!mounted) {
          return;
        }
        if (e is TradingHttpException) {
          if (e.isUnauthorized()) {
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            return;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label = network_error_label.replaceFirst("#CODE#", e.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            return;
          }
        }
        */
      }
    }
  }

  final String PROP_HIDE_PORTFOLIO = 'hide_portfolio';

  Widget createCardPortfolio(BuildContext context) {
    return Container(
      // color: Theme.of(context).backgroundColor,
      // elevation: 0.0,
      // borderOnForeground: false,
      // shape: null,
      margin: EdgeInsets.only(
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical),
      padding: EdgeInsets.zero,
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral),
            //child: ComponentCreator.subtitle(context, 'portfolio_card_title'.tr()),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ComponentCreator.subtitle(context, 'portfolio_card_title'.tr()),
                //Spacer(flex: 1,),
                ValueListenableBuilder<bool>(
                    valueListenable: wrapper.hidePortfolioNotifier,
                    builder: (context, value, child) {
                      Icon icon;
                      if (value) {
                        icon = Icon(
                          Icons.remove_red_eye_outlined,
                          color:
                              InvestrendTheme.of(context).greyLighterTextColor,
                        );
                      } else {
                        icon = Icon(Icons.remove_red_eye,
                            color: Theme.of(context).colorScheme.secondary);
                      }
                      return IconButton(
                          padding: EdgeInsets.all(0),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            wrapper.hidePortfolioNotifier.value =
                                !wrapper.hidePortfolioNotifier.value;
                          },
                          icon: icon);
                    }),
                //SizedBox(width: InvestrendTheme.cardPadding,),
              ],
            ),
          ),
          ButtonAccount(/*wrapper.accountNotifier*/),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral),
            child: ValueListenableBuilder(
              valueListenable: wrapper.accountNotifier,
              builder: (context, data, child) {
                User user = context.read(dataHolderChangeNotifier).user;
                Account? activeAccount =
                    user.getAccount(context.read(accountChangeNotifier).index);
                String portfolioValue = ' ';
                String portfolioGainLoss = ' ';
                String portfolioGainLossPercentage = ' ';
                int gainLossIDR = 0;
                bool hasData = false;
                TextStyle styleValue = Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w600);
                TextStyle? styleGainLoss = InvestrendTheme.of(context)
                    .small_w400
                    ?.copyWith(
                        color: InvestrendTheme.priceTextColor(gainLossIDR));
                if (activeAccount != null) {
                  AccountStockPosition? accountInfo = context
                      .read(accountsInfosNotifier)
                      .getInfo(activeAccount.accountcode);
                  if (accountInfo != null) {
                    gainLossIDR = accountInfo.totalGL;
                    portfolioValue = InvestrendTheme.formatMoney(
                        accountInfo.totalMarket,
                        prefixRp: true);
                    portfolioGainLoss = InvestrendTheme.formatMoney(
                            accountInfo.totalGL,
                            prefixRp: true) +
                        ' (' +
                        InvestrendTheme.formatPercentChange(
                            accountInfo.totalGLPct,
                            sufixPercent: true) +
                        ')';

                    if (wrapper.hidePortfolioNotifier.value) {
                      portfolioValue = '* * * * * * * * * * *';
                      portfolioGainLoss =
                          '* * * * * *' + ' (' + '* * * *' + ')';
                      styleValue = styleValue.copyWith(
                          color:
                              InvestrendTheme.of(context).greyDarkerTextColor);
                      styleGainLoss = styleGainLoss?.copyWith(
                          color:
                              InvestrendTheme.of(context).greyLighterTextColor);
                    }
                    hasData = true;
                  }
                }
                if (hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        portfolioValue, //InvestrendTheme.formatMoneyDouble(moneyAccount),
                        //style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w600),
                        style: styleValue,
                      ),
                      Text(
                        portfolioGainLoss,
                        //style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.priceTextColor(gainLossIDR)),
                        style: styleGainLoss,
                      ),
                    ],
                  );
                } else {
                  return Container(
                      width: double.maxFinite,
                      height: 40.0,
                      child: Center(child: EmptyLabel()));
                }
              },
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral),
            child: WidgetBuyingPower(
              hideNotifier: wrapper.hidePortfolioNotifier,
            ),
          ),

          /*
            ComponentCreator.dividerCard(context),

          // SizedBox(
          //   height: 10.0,
          // ),

          ValueListenableBuilder(
            valueListenable: wrapper.returnNotifier,
            builder: (context, value, child) {
              bool isEmpty = listHighest.isEmpty && listLowest.isEmpty;
              if(isEmpty) {
                return SizedBox(width: 1.0,);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ButtonTabSwitch(button_portfolio_rank, wrapper.buttonPortfolioRankNotifier,),
                  Padding(
                    padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingGeneral),
                    child: ValueListenableBuilder(
                      valueListenable: wrapper.returnNotifier,
                      builder: (context, value, child) {
                        bool highest = wrapper.buttonPortfolioRankNotifier.value == 0;
                        List content = highest ? listHighest : listLowest;
                        String emptyMessage = highest ? 'return_highest_empty_label'.tr() : 'return_lowest_empty_label'.tr();
                        return GridPriceThree(content,gridCount: 3, ratioHeight: 0.8, emptyMessage: emptyMessage, showDecimalPrice: false,onSelected: (code){
                          if(!StringUtils.isEmtpy(code)){
                            Stock stock = InvestrendTheme.storedData.findStock(code);
                            if(stock != null){
                              context.read(primaryStockChangeNotifier).setStock(stock);
                              InvestrendTheme.of(context).showStockDetail(context);
                            }
                          }
                        },);
                      },
                    ),
                  ),
                ],
              );
            }
          ),
          */
          /*
          ButtonTabSwitch(button_portfolio_rank, wrapper.buttonPortfolioRankNotifier,),
          Padding(
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingGeneral),
            child: ValueListenableBuilder(
              valueListenable: _returnNotifier,
              builder: (context, value, child) {
                bool highest = wrapper.buttonPortfolioRankNotifier.value == 0;
                List content = highest ? listHighest : listLowest;
                String emptyMessage = highest ? 'return_highest_empty_label'.tr() : 'return_lowest_empty_label'.tr();
                return GridPriceThree(content,gridCount: 3, ratioHeight: 0.8, emptyMessage: emptyMessage, showDecimalPrice: false,onSelected: (code){
                  if(!StringUtils.isEmtpy(code)){
                    Stock stock = InvestrendTheme.storedData.findStock(code);
                    if(stock != null){
                      context.read(primaryStockChangeNotifier).setStock(stock);
                      InvestrendTheme.of(context).showStockDetail(context);
                    }
                  }
                },);
              },
            ),
          ),
          */
        ],
      ),
    );
  }

  Widget tilePortfolio(BuildContext context, HomePortfolio data, bool first) {
    double left = first ? 0 : 8.0;
    //double right = end ? 0 : 0.0;
    String percentText;
    Color percentChangeTextColor;
    Color percentChangeBackgroundColor;

    percentText = InvestrendTheme.formatPercentChange(data.percentChange);
    percentChangeTextColor =
        InvestrendTheme.changeTextColor(data.percentChange);
    percentChangeBackgroundColor =
        InvestrendTheme.priceBackgroundColorDouble(data.percentChange);

    return MaterialButton(
      elevation: 0.0,
      splashColor: InvestrendTheme.of(context).tileSplashColor,
      padding:
          EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
      color: InvestrendTheme.of(context).tileBackground,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
        side: BorderSide(
          color: InvestrendTheme.of(context).tileBackground!,
          width: 0.0,
        ),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              data.code!,
              style: InvestrendTheme.of(context).small_w600_compact,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              InvestrendTheme.formatPriceDouble(data.price, showDecimal: false),
              style: InvestrendTheme.of(context)
                  .more_support_w600_compact
                  ?.copyWith(color: percentChangeTextColor, fontSize: 12.0),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Container(
            padding:
                EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
            decoration: BoxDecoration(
              color: percentChangeBackgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                percentText,
                style: InvestrendTheme.of(context)
                    .more_support_w600_compact
                    ?.copyWith(color: percentChangeTextColor, fontSize: 12.0),
              ),
            ),
          ),
        ],
      ),
      onPressed: () {},
    );
  }

  Widget getButtonIconVertical(BuildContext context, String image, String text,
      Color textColor, VoidCallback onPressed) {
    return SizedBox(
      width: 55,
      height: 55,
      child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.zero,
          child: InkWell(
            child: MaterialButton(
              padding: EdgeInsets.all(2.0),
              elevation: 0,
              highlightElevation: 0,
              focusElevation: 0,

              //visualDensity: VisualDensity.compact,
              //color: Theme.of(context).accentColor,
              //color: color,
              //textColor: Theme.of(context).primaryColor,
              textColor: textColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    image,
                    width: 20,
                    height: 20,
                  ),
                  // SizedBox(
                  //   height: 5.0,
                  // ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text,
                      style: InvestrendTheme.of(context)
                          .more_support_w400_compact
                          ?.copyWith(color: textColor),
                      //style: TextStyle(fontSize: 13.0, color: textColor, fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
              onPressed: onPressed,
            ),
          )),
    );
  }

  Widget constructBriefing(BuildContext context, Briefing? value) {
    if (wrapper.briefingNotifier.currentState.notFinished()) {
      List<Widget> childs = List.empty(growable: true);
      childs.add(Padding(
        padding:
            const EdgeInsets.only(/*top: cardPadding,*/ bottom: cardPadding),
        child:
            ComponentCreator.subtitle(context, 'home_card_briefing_title'.tr()),
      ));

      if (wrapper.briefingNotifier.currentState.isError()) {
        childs.add(Center(child: TextButtonRetry(
          onPressed: () {
            doUpdate(pullToRefresh: true);
          },
        )));
      } else if (wrapper.briefingNotifier.currentState.isLoading()) {
        childs.add(Center(
          child: CircularProgressIndicator(),
        ));
      } else if (wrapper.briefingNotifier.currentState.isNoData()) {
        childs.add(Center(
          child: EmptyLabel(),
        ));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: childs,
      );
    }

    String? greeting = value?.getGreeting(
        language: EasyLocalization.of(context)!.locale.languageCode);
    greeting =
        greeting! + ' ' + context.read(dataHolderChangeNotifier).user.realname!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(/*top: cardPadding,*/ bottom: cardPadding),
          child: ComponentCreator.subtitle(
              context,
              value?.getTitle(
                  language:
                      EasyLocalization.of(context)!.locale.languageCode)!),
        ),
        Text(
          greeting,
          style: InvestrendTheme.of(context).small_w400,
        ),
        ColapsedText(
          text: value?.getDescription(
              language: EasyLocalization.of(context)!.locale.languageCode),
          maxLines: 10,
        ),
      ],
    );
  }

  Widget createCardBriefing(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPaddingVertical,
          top: InvestrendTheme.cardPaddingVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // SizedBox(
          //   height: cardMargin,
          // ),
          ValueListenableBuilder<Briefing?>(
              valueListenable: wrapper.briefingNotifier,
              builder: (context, value, child) {
                return constructBriefing(context, value);
              }),
          /*
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ComponentCreator.subtitle(context, 'home_card_briefing_title'.tr()),
              SizedBox(
                width: 4,
              ),
              Image.asset(
                'images/icons/coffee_cups.png',
                width: 30,
                height: 30,
              ),
            ],
          ),
          ColapsedText(
            text:
                'Good Morning, Ackerman\nAmerika Serikat mencatat inflasi dengan laju tertinggi sejak 2012 pada bulan Maret 2021. Kondisi ini memicu kekhawatiran naiknya yield obligasi AS sehingga kurs rupiah melemah dan berakhir flat pada penutupan Sesi I siang ini.\nMengutip data Bloomberg, Senin (19/4) pukul 12.00 WIB, kurs rupiah tengah diperdagangkan pada level Rp14.565 per dolar AS. Posisi tersebut sama persis dengan penutupan pasar spot pada akhir pekan Jumat sore kemarin (16/4). Kurs rupiah bergerak melemah dibanding tadi pagi yang masih mencatatakan penguatan terhadap dolar AS.\nHead of Economic Research Pefindo, Fikri C Permana, mengatakan bahwa kurs rupiah melemah karena perkembangan inflasi AS yang begitu kuat. Inflasi AS pada bulan lalu meningkat begitu tinggi karena aktivitas ekonomi dibuka kembali dan naiknya permintaan. "Ini memicu ekspektasi kenaikan yield obligasi AS dan indeks dolar AS. Akibatnya rupiah melemah tipis siang ini," kata Irvan saat dihubungi Ipotnews, Senin siang.\nBerdasarkan data Bloomberg pada Selasa (13/4), Departemen Tenaga Kerja AS mencatat indeks harga konsumen (consumer price index/CPI) naik 0,6 persen pada Maret dari bulan sebelumnya setelah kenaikan 0,4 persen. Ini merupakan laju tertinggi sejak Agustus 2012. Dibandingkan dengan bulan yang sama tahun 2020, CPI bulan Maret naik 2,6 persen. Adapun CPI inti naik 1,6 persen secara year-on-year (yoy).\nDari dalam negeri, kedatangan vaksin Sinovac tahap kedelapan di Indonesia pada Minggu (18/4) belum bisa menjadi sentimen positif yang menggerakkan kurs rupiah pada hari ini. Pelaku pasar melihat distribusi vaksin di Tanah Air harus dipercepat lagi. "Jadi bukan hanya sekedar pasokan vaksinnya untuk mempercepat proses vaksinasi di Indonesia," tutup Fikri.\nVaksin Covid-19 tahap delapan sudah tiba di Indonesia kemarin di Terminal Kargo, Bandara Soetta. Jenis vaksin ini sama dengan yang terakhir tiba di Indonesia yakni Sinovac. Sebanyak enam juta bahan baku vaksin covid-19 Sinovac asal Tiongkok tiba di Indonesia. Pengiriman ini merupakan kedatangan dosis vaksin tahap kedelapan.\nTotal 59,5 juta bahan baku vaksin Sinovac telah diterima Indonesia. Ketika sudah diproses, bahan baku itu bisa menjadi 46-47 juta dosis vaskin siap pakai.',
            maxLines: 10,
          ),
          */
          // Text(
          //   'Good Morning, Ackerman\nAmerika Serikat mencatat inflasi dengan laju tertinggi sejak 2012 pada bulan Maret 2021. Kondisi ini memicu kekhawatiran naiknya yield obligasi AS sehingga kurs rupiah melemah dan berakhir flat pada penutupan Sesi I siang ini.\nMengutip data Bloomberg, Senin (19/4) pukul 12.00 WIB, kurs rupiah tengah diperdagangkan pada level Rp14.565 per dolar AS. Posisi tersebut sama persis dengan penutupan pasar spot pada akhir pekan Jumat sore kemarin (16/4). Kurs rupiah bergerak melemah dibanding tadi pagi yang masih mencatatakan penguatan terhadap dolar AS.\nHead of Economic Research Pefindo, Fikri C Permana, mengatakan bahwa kurs rupiah melemah karena perkembangan inflasi AS yang begitu kuat. Inflasi AS pada bulan lalu meningkat begitu tinggi karena aktivitas ekonomi dibuka kembali dan naiknya permintaan. "Ini memicu ekspektasi kenaikan yield obligasi AS dan indeks dolar AS. Akibatnya rupiah melemah tipis siang ini," kata Irvan saat dihubungi Ipotnews, Senin siang.\nBerdasarkan data Bloomberg pada Selasa (13/4), Departemen Tenaga Kerja AS mencatat indeks harga konsumen (consumer price index/CPI) naik 0,6 persen pada Maret dari bulan sebelumnya setelah kenaikan 0,4 persen. Ini merupakan laju tertinggi sejak Agustus 2012. Dibandingkan dengan bulan yang sama tahun 2020, CPI bulan Maret naik 2,6 persen. Adapun CPI inti naik 1,6 persen secara year-on-year (yoy).\nDari dalam negeri, kedatangan vaksin Sinovac tahap kedelapan di Indonesia pada Minggu (18/4) belum bisa menjadi sentimen positif yang menggerakkan kurs rupiah pada hari ini. Pelaku pasar melihat distribusi vaksin di Tanah Air harus dipercepat lagi. "Jadi bukan hanya sekedar pasokan vaksinnya untuk mempercepat proses vaksinasi di Indonesia," tutup Fikri.\nVaksin Covid-19 tahap delapan sudah tiba di Indonesia kemarin di Terminal Kargo, Bandara Soetta. Jenis vaksin ini sama dengan yang terakhir tiba di Indonesia yakni Sinovac. Sebanyak enam juta bahan baku vaksin covid-19 Sinovac asal Tiongkok tiba di Indonesia. Pengiriman ini merupakan kedatangan dosis vaksin tahap kedelapan.\nTotal 59,5 juta bahan baku vaksin Sinovac telah diterima Indonesia. Ketika sudah diproses, bahan baku itu bisa menjadi 46-47 juta dosis vaskin siap pakai.',
          //   style:
          //       Theme.of(context).textTheme.bodyText2.copyWith(height: 2.0),
          //   maxLines: 10,
          //
          // ),
          SizedBox(
            height: 20.0,
          ),
          Text(
            'home_card_briefing_world_indices'.tr(),
            style: InvestrendTheme.of(context).small_w400_compact?.copyWith(
                color: InvestrendTheme.of(context).greyDarkerTextColor),
          ),
          SizedBox(
            height: 10.0,
          ),

          ValueListenableBuilder<HomeIndicesData?>(
              valueListenable: wrapper.indicesNotifier,
              builder: (context, value, child) {
                if (wrapper.indicesNotifier.currentState.notFinished()) {
                  if (wrapper.indicesNotifier.currentState.isError()) {
                    return Center(child: TextButtonRetry(
                      onPressed: () {
                        doUpdate(pullToRefresh: true);
                      },
                    ));
                  } else if (wrapper.indicesNotifier.currentState.isLoading()) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (wrapper.indicesNotifier.currentState.isNoData()) {
                    return Center(
                      child: EmptyLabel(),
                    );
                  }
                }
                // if (wrapper.indicesNotifier.invalid()) {
                //   return Center(
                //     child: CircularProgressIndicator(),
                //   );
                // }
                // if (value.count() == 0) {
                //   return Center(child: EmptyLabel());
                // }
                //return gridWorldIndices(context, value.datas);
                return GridPriceTwo(
                  value?.datas,
                  gridCount: 2,
                  marginTile: cardMargin,
                  ratioHeight: 0.4,
                  showDecimalPrice: true,
                );
              }),
          /*
          FutureBuilder<List<HomeWorldIndices>>(
            future: worldIndices,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //return Text(snapshot.data.length.toString(), style: Theme.of(context).textTheme.bodyText2,);
                if (snapshot.data.length > 0) {
                  return gridWorldIndices(context, snapshot.data);
                } else {
                  return Center(
                      child: Text(
                    'No Data',
                    style: Theme.of(context).textTheme.bodyText2,
                  ));
                }
              } else if (snapshot.hasError) {
                return Center(
                    child:
                        Text("${snapshot.error}", style: Theme.of(context).textTheme.bodyText2.copyWith(color: Theme.of(context).errorColor)));
              }

              // By default, show a loading spinner.
              return Center(child: CircularProgressIndicator());
            },
          ),
          */
          //gridWorldIndices(context, listWorldIndices),

          SizedBox(
            height: 20.0,
          ),
          Text(
            'home_card_briefing_commodities'.tr(),
            style: InvestrendTheme.of(context).small_w400_compact?.copyWith(
                color: InvestrendTheme.of(context).greyDarkerTextColor),
          ),
          SizedBox(
            height: 10.0,
          ),
          ValueListenableBuilder<HomeCommoditiesData?>(
              valueListenable: wrapper.commoditiesNotifier,
              builder: (context, value, child) {
                if (wrapper.commoditiesNotifier.currentState.notFinished()) {
                  if (wrapper.commoditiesNotifier.currentState.isError()) {
                    return Center(child: TextButtonRetry(
                      onPressed: () {
                        doUpdate(pullToRefresh: true);
                      },
                    ));
                  } else if (wrapper.commoditiesNotifier.currentState
                      .isLoading()) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (wrapper.commoditiesNotifier.currentState
                      .isNoData()) {
                    return Center(
                      child: EmptyLabel(),
                    );
                  }
                }

                // if (wrapper.commoditiesNotifier.invalid()) {
                //   return Center(
                //     child: CircularProgressIndicator(),
                //   );
                // }
                // if (value.count() == 0) {
                //   return Center(child: EmptyLabel());
                // }
                //return gridCommodities(context, value.datas);
                return GridPriceThree(value?.datas,
                    gridCount: 4, marginTile: cardMargin);
              }),

          //gridCommodities(context),
          //gridCommodities(context),
          SizedBox(
            height: 20.0,
          ),
          Text(
            'home_card_briefing_currencies'.tr(),
            style: InvestrendTheme.of(context).small_w400_compact?.copyWith(
                color: InvestrendTheme.of(context).greyDarkerTextColor),
          ),
          SizedBox(
            height: 10.0,
          ),
          ValueListenableBuilder<HomeCurrenciesData?>(
              valueListenable: wrapper.currenciesNotifier,
              builder: (context, value, child) {
                if (wrapper.currenciesNotifier.currentState.notFinished()) {
                  if (wrapper.currenciesNotifier.currentState.isError()) {
                    return Center(child: TextButtonRetry(
                      onPressed: () {
                        doUpdate(pullToRefresh: true);
                      },
                    ));
                  } else if (wrapper.currenciesNotifier.currentState
                      .isLoading()) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (wrapper.currenciesNotifier.currentState
                      .isNoData()) {
                    return Center(
                      child: EmptyLabel(),
                    );
                  }
                }

                // if (wrapper.currenciesNotifier.invalid()) {
                //   return Center(
                //     child: CircularProgressIndicator(),
                //   );
                // }
                // if (value.count() == 0) {
                //   return Center(child: EmptyLabel());
                // }
                //return gridCurrencies(context, value.datas);
                return GridPriceThree(
                  value?.datas,
                  gridCount: 3,
                  marginTile: cardMargin,
                  ratioHeight: 0.8,
                );
              }),

          //gridCurrencies(context),
          SizedBox(
            height: 20.0,
          ),
          Text(
            'home_card_briefing_cryptocurrencies'.tr(),
            style: InvestrendTheme.of(context).small_w400_compact?.copyWith(
                color: InvestrendTheme.of(context).greyDarkerTextColor),
          ),
          SizedBox(
            height: 10.0,
          ),
          //gridCryptoCurrencies(context),
          ValueListenableBuilder<HomeCryptoData?>(
              valueListenable: wrapper.cryptoNotifier,
              builder: (context, value, child) {
                if (wrapper.cryptoNotifier.currentState.notFinished()) {
                  if (wrapper.cryptoNotifier.currentState.isError()) {
                    return Center(child: TextButtonRetry(
                      onPressed: () {
                        doUpdate(pullToRefresh: true);
                      },
                    ));
                  } else if (wrapper.cryptoNotifier.currentState.isLoading()) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (wrapper.cryptoNotifier.currentState.isNoData()) {
                    return Center(
                      child: EmptyLabel(),
                    );
                  }
                }

                // if (wrapper.cryptoNotifier.invalid()) {
                //   return Center(
                //     child: CircularProgressIndicator(),
                //   );
                // }
                // if (value.count() == 0) {
                //   return Center(child: EmptyLabel());
                // }
                //return gridCryptoCurrencies(context, value.datas);
                return GridPriceThree(
                  value?.datas,
                  gridCount: 3,
                  marginTile: cardMargin,
                  ratioHeight: 0.8,
                );
              }),
        ],
      ),
    );
  }

  Widget gridThemes(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      print('constrains ' + constrains.maxWidth.toString());
      const int gridCount = 2;
      double availableWidth = constrains.maxWidth - cardMargin;
      double tileWidth = availableWidth / gridCount;
      double height1 = tileWidth * 1.28;
      double height2 = tileWidth * 1.5;

      if (listThemes == null || listThemes?.length == 0) {
        return Text('No Data');
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              tileThemes(listThemes?[0], tileWidth, height1, 0),
              SizedBox(
                height: cardMargin,
              ),
              tileThemes(listThemes?[2], tileWidth, height2, 0),
              SizedBox(
                height: cardMargin,
              ),
              tileThemes(listThemes?[4], tileWidth, height1, 0),
            ],
          ),
          Column(
            children: [
              tileThemes(listThemes?[1], tileWidth, height2, cardPadding),
              SizedBox(
                height: cardMargin,
              ),
              tileThemes(listThemes?[3], tileWidth, height2, cardPadding),
              SizedBox(
                height: cardMargin,
              ),
              tileThemes(listThemes?[5], tileWidth, height1, cardPadding),
            ],
          ),
        ],
      );
    });
  }

  Widget tileThemes(HomeThemes? themes, double tileWidth, double tileHeight,
      double leftPadding) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            InvestrendTheme.of(context).tileRoundedRadius),
        //clipper: ClipRect(clipper: ,),
        child: SizedBox(
          width: tileWidth,
          height: tileHeight,
          child: Stack(
            //fit: StackFit.expand,
            children: [
              ComponentCreator.imageNetwork(
                themes?.url_background,
                width: tileWidth,
                height: tileHeight,
                fit: BoxFit.fill,
              ),
              Container(
                width: double.maxFinite,
                height: double.maxFinite,
                padding: EdgeInsets.all(
                    InvestrendTheme.of(context).tileRoundedRadius),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black54,
                    Colors.black12,
                  ],
                )),
              ),
              Positioned.fill(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        splashColor: Theme.of(context).colorScheme.secondary,
                        onTap: () {
                          InvestrendTheme.of(context)
                              .showSnackBar(context, 'Action Theme detail');
                        })),
              ),
              IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.all(
                      InvestrendTheme.of(context).tileRoundedRadius),
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Spacer(
                        flex: 1,
                      ),
                      Text(
                        themes!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: InvestrendTheme.of(context)
                                .textWhite /*Colors.white*/),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        themes.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: InvestrendTheme.of(context)
                                .textWhite /*Colors.white*/),
                      ),
                      SizedBox(
                        height: cardPadding,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle useFontSize(
      BuildContext context, TextStyle? style, double width, String? text,
      {int tried = 1}) {
    print(routeName +
        '.useFontSize  try fontSize  : ' +
        style!.fontSize.toString() +
        '  width : $width  text : $text  ');
    const double font_step = 1.5;

    double widthText = UIHelper.textSize(text, style).width;
    bool reduceFont = widthText > width;
    if (reduceFont) {
      style = style.copyWith(fontSize: style.fontSize! - font_step);
      return useFontSize(context, style, width, text, tried: tried++);
    } else {
      print(routeName +
          '.useFontSize Final fontSize  : ' +
          style.fontSize.toString() +
          '  text : $text  tried : $tried');
      return style;
    }
  }

  Widget gridCommodities(
      BuildContext context, List<HomeCommodities>? listCommodities) {
    return LayoutBuilder(builder: (context, constrains) {
      print('constrains ' + constrains.maxWidth.toString());
      const int gridCount = 4;
      double availableWidth = constrains.maxWidth - (cardMargin * 3);
      print('availableWidth $availableWidth');
      double tileWidth = availableWidth / gridCount;
      print('tileWidth $tileWidth');
      List<Widget> columns = List<Widget>.empty(growable: true);

      int? countData = listCommodities?.length;
      EdgeInsets padding =
          EdgeInsets.only(left: 4.0, right: 4.0, top: 8.0, bottom: 8.0);
      EdgeInsets paddingPercent =
          EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0);
      TextStyle? codeStyle = InvestrendTheme.of(context).small_w600_compact;
      TextStyle? priceStyle = InvestrendTheme.of(context)
          .more_support_w600_compact
          ?.copyWith(fontSize: 12.0);
      TextStyle? percentStyle = InvestrendTheme.of(context)
          .more_support_w600_compact
          ?.copyWith(fontSize: 12.0);
      double availableWidthForCode = tileWidth - padding.left - padding.right;
      double availableWidthForPercent = tileWidth -
          padding.left -
          padding.right -
          paddingPercent.left -
          paddingPercent.right;

      for (int i = 0; i < countData!; i++) {
        HomeCommodities? com = listCommodities?.elementAt(i);
        if (com != null) {
          String? codeText = com.code;
          String priceText =
              InvestrendTheme.formatPriceDouble(com.price, showDecimal: true);
          String percentText =
              InvestrendTheme.formatPercentChange(com.percentChange);
          codeStyle =
              useFontSize(context, codeStyle, availableWidthForCode, codeText);
          priceStyle = useFontSize(
              context, priceStyle, availableWidthForCode, priceText);
          percentStyle = useFontSize(
              context, percentStyle, availableWidthForPercent, percentText);
        }
      }
      List<Widget> cols = List<Widget>.empty(growable: true);
      List<Widget> rows = List<Widget>.empty(growable: true);

      for (int i = 0; i < countData; i++) {
        HomeCommodities? com = listCommodities?.elementAt(i);
        if (com != null) {
          String? codeText = com.code;
          String priceText =
              InvestrendTheme.formatPriceDouble(com.price, showDecimal: false);
          String percentText =
              InvestrendTheme.formatPercentChange(com.percentChange);
          Color percentChangeTextColor =
              InvestrendTheme.changeTextColor(com.percentChange);
          Color percentChangeBackgroundColor =
              InvestrendTheme.priceBackgroundColorDouble(com.percentChange);

          rows.add(TilePriceThree(
            width: tileWidth,
            codeText: codeText,
            priceText: priceText,
            percentChangeText: percentText,
            priceColor: percentChangeTextColor,
            percentChangeBackgroundColor: percentChangeBackgroundColor,
            priceStyle: priceStyle?.copyWith(color: percentChangeTextColor),
            padding: padding,
            paddingPercent: paddingPercent,
            codeStyle: codeStyle,
            percentStyle: percentStyle?.copyWith(color: percentChangeTextColor),
            onPressed: () {},
          ));
          if (rows.length >= gridCount) {
            cols.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rows,
            ));
            cols.add(SizedBox(
              height: cardMargin,
            ));
            rows = List<Widget>.empty(growable: true);
          }
        }
      }

      return Column(
        children: cols,
      );
    });
  }

  Widget gridCommoditiesBackup(
      BuildContext context, List<HomeCommodities> listCommodities) {
    return LayoutBuilder(builder: (context, constrains) {
      print('constrains ' + constrains.maxWidth.toString());
      const int gridCount = 4;
      double availableWidth = constrains.maxWidth - (cardMargin * 3);
      print('availableWidth $availableWidth');
      double tileWidth = availableWidth / gridCount;
      print('tileWidth $tileWidth');
      List<Widget> columns = List<Widget>.empty(growable: true);

      int countData = listCommodities.length;
      for (int i = 0; i < countData; i++) {
        int iPlus3 = i + 3;
        int iPlus2 = i + 2;
        int iPlus1 = i + 1;

        List<Widget> rows = List<Widget>.empty(growable: true);
        for (int x = 0; x < 4; x++) {
          int index = x + i;
          if (x > 0) {
            rows.add(SizedBox(
              width: cardMargin,
            ));
          }
          if (index < countData) {
            rows.add(tileCommodities(
              context,
              listCommodities[index],
              true,
              tileWidth,
            ));
          } else {
            rows.add(Expanded(
              flex: 1,
              child: Center(child: Text(' ')),
            ));
          }
        }
        columns.add(Row(
          children: rows,
        ));
        columns.add(SizedBox(
          height: cardMargin,
        ));
        i += 3;
      }

      return Column(
        children: columns,
      );

      // return Container(
      //   color: Colors.red,
      //   width: double.maxFinite,
      //   height: 100,
      // );
    });
  }

  Widget gridCurrencies(BuildContext context, List<HomeCurrencies>? listData) {
    return LayoutBuilder(builder: (context, constrains) {
      print('constrains ' + constrains.maxWidth.toString());
      const int gridCount = 3;
      double availableWidth = constrains.maxWidth - (cardMargin * 2);
      print('availableWidth $availableWidth');
      double tileWidth = availableWidth / gridCount;
      double tileHeight = tileWidth * 0.8;
      print('tileWidth $tileWidth');

      int? countData = listData?.length;

      EdgeInsets padding =
          EdgeInsets.only(left: 4.0, right: 4.0, top: 8.0, bottom: 8.0);
      EdgeInsets paddingPercent =
          EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0);
      TextStyle? codeStyle = InvestrendTheme.of(context).small_w600_compact;
      TextStyle? priceStyle = InvestrendTheme.of(context)
          .more_support_w600_compact
          ?.copyWith(fontSize: 12.0);
      TextStyle? percentStyle = InvestrendTheme.of(context)
          .more_support_w600_compact
          ?.copyWith(fontSize: 12.0);
      double availableWidthForCode = tileWidth - padding.left - padding.right;
      double availableWidthForPercent = tileWidth -
          padding.left -
          padding.right -
          paddingPercent.left -
          paddingPercent.right;

      for (int i = 0; i < countData!; i++) {
        HomeCurrencies? data = listData?.elementAt(i);
        if (data != null) {
          String? codeText = data.code;
          String priceText =
              InvestrendTheme.formatPriceDouble(data.price, showDecimal: true);
          String percentText =
              InvestrendTheme.formatPercentChange(data.percentChange);
          codeStyle =
              useFontSize(context, codeStyle, availableWidthForCode, codeText);
          priceStyle = useFontSize(
              context, priceStyle, availableWidthForCode, priceText);
          percentStyle = useFontSize(
              context, percentStyle, availableWidthForPercent, percentText);
        }
      }
      List<Widget> cols = List<Widget>.empty(growable: true);
      List<Widget> rows = List<Widget>.empty(growable: true);

      double heightContent = UIHelper.textSize('Pj', codeStyle).height;
      heightContent += UIHelper.textSize('Pj', priceStyle).height;
      heightContent += UIHelper.textSize('Pj', percentStyle).height;
      heightContent += padding.top + padding.bottom;
      heightContent += paddingPercent.top + paddingPercent.bottom;

      tileHeight = max(heightContent, tileHeight);

      for (int i = 0; i < countData; i++) {
        HomeCurrencies? data = listData?.elementAt(i);
        if (data != null) {
          String? codeText = data.code;
          String priceText =
              InvestrendTheme.formatPriceDouble(data.price, showDecimal: false);
          String percentText =
              InvestrendTheme.formatPercentChange(data.percentChange);
          Color percentChangeTextColor =
              InvestrendTheme.changeTextColor(data.percentChange);
          Color percentChangeBackgroundColor =
              InvestrendTheme.priceBackgroundColorDouble(data.percentChange);

          rows.add(TilePriceThree(
            width: tileWidth,
            height: tileHeight,
            codeText: codeText,
            priceText: priceText,
            percentChangeText: percentText,
            priceColor: percentChangeTextColor,
            percentChangeBackgroundColor: percentChangeBackgroundColor,
            priceStyle: priceStyle?.copyWith(color: percentChangeTextColor),
            padding: padding,
            paddingPercent: paddingPercent,
            codeStyle: codeStyle,
            percentStyle: percentStyle?.copyWith(color: percentChangeTextColor),
            onPressed: () {},
          ));
          if (rows.length >= gridCount) {
            cols.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rows,
            ));
            cols.add(SizedBox(
              height: cardMargin,
            ));
            rows = List<Widget>.empty(growable: true);
          }
        }
      }

      return Column(
        children: cols,
      );
      /*
      List<Widget> columns = List<Widget>.empty(growable: true);
      for (int i = 0; i < countData; i++) {
        int iPlus2 = i + 2;
        int iPlus1 = i + 1;
        if (iPlus2 < countData) {
          columns.add(Row(
            children: [
              tileThreeLayers(
                context,
                listCurrencies[i].code,
                listCurrencies[i].price,
                listCurrencies[i].percentChange,
                true,
                tileWidth,
              ),
              SizedBox(
                width: cardMargin,
              ),
              tileThreeLayers(
                context,
                listCurrencies[i + 1].code,
                listCurrencies[i + 1].price,
                listCurrencies[i + 1].percentChange,
                true,
                tileWidth,
              ),
              SizedBox(
                width: cardMargin,
              ),
              tileThreeLayers(
                context,
                listCurrencies[i + 2].code,
                listCurrencies[i + 2].price,
                listCurrencies[i + 2].percentChange,
                true,
                tileWidth,
              ),
            ],
          ));
        } else if (iPlus1 < countData) {
          columns.add(Row(
            children: [
              tileThreeLayers(
                context,
                listCurrencies[i].code,
                listCurrencies[i].price,
                listCurrencies[i].percentChange,
                true,
                tileWidth,
              ),
              SizedBox(
                width: cardMargin,
              ),
              tileThreeLayers(
                context,
                listCurrencies[i + 1].code,
                listCurrencies[i + 1].price,
                listCurrencies[i + 1].percentChange,
                true,
                tileWidth,
              ),
              SizedBox(
                width: cardMargin,
              ),
              Expanded(
                flex: 1,
                child: Center(child: Text(' ')),
              ),
            ],
          ));
        } else {
          columns.add(Row(
            children: [
              tileThreeLayers(
                context,
                listCurrencies[i].code,
                listCurrencies[i].price,
                listCurrencies[i].percentChange,
                true,
                tileWidth,
              ),
              SizedBox(
                width: cardMargin,
              ),
              Expanded(
                flex: 1,
                child: Center(child: Text(' ')),
              ),
              SizedBox(
                width: cardMargin,
              ),
              Expanded(
                flex: 1,
                child: Center(child: Text(' ')),
              ),
            ],
          ));
        }
        i = i + 3;
        columns.add(SizedBox(
          height: cardMargin,
        ));
      }

      return Column(
        children: columns,
      );
      */
      // return Container(
      //   color: Colors.red,
      //   width: double.maxFinite,
      //   height: 100,
      // );
    });
  }

  Widget gridCryptoCurrencies(
      BuildContext context, List<HomeCrypto>? listData) {
    return LayoutBuilder(builder: (context, constrains) {
      print('constrains ' + constrains.maxWidth.toString());
      const int gridCount = 3;
      double availableWidth = constrains.maxWidth - (cardMargin * 2);
      print('gridCryptoCurrencies availableWidth $availableWidth');
      double tileWidth = availableWidth / gridCount;
      double tileHeight = tileWidth * 0.8;
      print(
          'gridCryptoCurrencies tileWidth $tileWidth  tileHeight $tileHeight');

      int? countData = listData?.length;

      EdgeInsets padding =
          EdgeInsets.only(left: 4.0, right: 4.0, top: 8.0, bottom: 8.0);
      EdgeInsets paddingPercent =
          EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0);
      TextStyle? codeStyle = InvestrendTheme.of(context).small_w600_compact;
      TextStyle? priceStyle = InvestrendTheme.of(context)
          .more_support_w600_compact
          ?.copyWith(fontSize: 12.0);
      TextStyle? percentStyle = InvestrendTheme.of(context)
          .more_support_w600_compact
          ?.copyWith(fontSize: 12.0);
      double availableWidthForCode = tileWidth - padding.left - padding.right;
      double availableWidthForPercent = tileWidth -
          padding.left -
          padding.right -
          paddingPercent.left -
          paddingPercent.right;

      for (int i = 0; i < countData!; i++) {
        HomeCrypto? data = listData?.elementAt(i);
        if (data != null) {
          String? codeText = data.code;
          String priceText =
              InvestrendTheme.formatPriceDouble(data.price, showDecimal: true);
          String percentText =
              InvestrendTheme.formatPercentChange(data.percentChange);
          codeStyle =
              useFontSize(context, codeStyle, availableWidthForCode, codeText);
          priceStyle = useFontSize(
              context, priceStyle, availableWidthForCode, priceText);
          percentStyle = useFontSize(
              context, percentStyle, availableWidthForPercent, percentText);
        }
      }
      List<Widget> cols = List<Widget>.empty(growable: true);
      List<Widget> rows = List<Widget>.empty(growable: true);

      double heightContent = UIHelper.textSize('Pj', codeStyle).height;
      heightContent += UIHelper.textSize('Pj', priceStyle).height;
      heightContent += UIHelper.textSize('Pj', percentStyle).height;
      heightContent += padding.top + padding.bottom;
      heightContent += paddingPercent.top + paddingPercent.bottom;

      tileHeight = max(heightContent, tileHeight);

      for (int i = 0; i < countData; i++) {
        HomeCrypto? data = listData?.elementAt(i);
        if (data != null) {
          String? codeText = data.code;
          String priceText =
              InvestrendTheme.formatPriceDouble(data.price, showDecimal: false);
          String percentText =
              InvestrendTheme.formatPercentChange(data.percentChange);
          Color percentChangeTextColor =
              InvestrendTheme.changeTextColor(data.percentChange);
          Color percentChangeBackgroundColor =
              InvestrendTheme.priceBackgroundColorDouble(data.percentChange);

          rows.add(TilePriceThree(
            width: tileWidth,
            height: tileHeight,
            codeText: codeText,
            priceText: priceText,
            percentChangeText: percentText,
            priceColor: percentChangeTextColor,
            percentChangeBackgroundColor: percentChangeBackgroundColor,
            priceStyle: priceStyle?.copyWith(color: percentChangeTextColor),
            padding: padding,
            paddingPercent: paddingPercent,
            codeStyle: codeStyle,
            percentStyle: percentStyle?.copyWith(color: percentChangeTextColor),
            onPressed: () {},
          ));
          if (rows.length >= gridCount) {
            cols.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rows,
            ));
            cols.add(SizedBox(
              height: cardMargin,
            ));
            rows = List<Widget>.empty(growable: true);
          }
        }
      }

      return Column(
        children: cols,
      );

      /*
    List<Widget> columns = List<Widget>.empty(growable: true);
      for (int i = 0; i < countData; i++) {
        int iPlus2 = i + 2;
        int iPlus1 = i + 1;
        if (iPlus2 < countData) {
          columns.add(Row(
            children: [
              tileThreeLayers(
                context,
                listData[i].code,
                listData[i].price,
                listData[i].percentChange,
                true,
                tileWidth,
              ),
              SizedBox(
                width: cardMargin,
              ),
              tileThreeLayers(
                context,
                listData[i + 1].code,
                listData[i + 1].price,
                listData[i + 1].percentChange,
                true,
                tileWidth,
              ),
              SizedBox(
                width: cardMargin,
              ),
              tileThreeLayers(
                context,
                listData[i + 2].code,
                listData[i + 2].price,
                listData[i + 2].percentChange,
                true,
                tileWidth,
              ),
            ],
          ));
        } else if (iPlus1 < countData) {
          columns.add(Row(
            children: [
              tileThreeLayers(
                context,
                listData[i].code,
                listData[i].price,
                listData[i].percentChange,
                true,
                tileWidth,
              ),
              SizedBox(
                width: cardMargin,
              ),
              tileThreeLayers(
                context,
                listData[i + 1].code,
                listData[i + 1].price,
                listData[i + 1].percentChange,
                true,
                tileWidth,
              ),
              SizedBox(
                width: cardMargin,
              ),
              Expanded(
                flex: 1,
                child: Center(child: Text(' ')),
              ),
            ],
          ));
        } else {
          columns.add(Row(
            children: [
              tileThreeLayers(
                context,
                listCurrencies[i].code,
                listCurrencies[i].price,
                listCurrencies[i].percentChange,
                true,
                tileWidth,
              ),
              SizedBox(
                width: cardMargin,
              ),
              Expanded(
                flex: 1,
                child: Center(child: Text(' ')),
              ),
              SizedBox(
                width: cardMargin,
              ),
              Expanded(
                flex: 1,
                child: Center(child: Text(' ')),
              ),
            ],
          ));
        }
        i = i + 3;
        columns.add(SizedBox(
          height: cardMargin,
        ));
      }

      return Column(
        children: columns,
      );

      // return Container(
      //   color: Colors.red,
      //   width: double.maxFinite,
      //   height: 100,
      // );
      */
    });
  }

  Widget tileWorlIndices(
      BuildContext context, HomeWorldIndices data, bool first) {
    double left = first ? 0 : 8.0;
    //double right = end ? 0 : 0.0;
    String priceText;
    String percentText;
    String changeText;
    Color percentChangeTextColor;
    Color percentChangeBackgroundColor;

    priceText = InvestrendTheme.formatPriceDouble(data.price);
    percentText = InvestrendTheme.formatPercentChange(data.percentChange);
    changeText = InvestrendTheme.formatChange(data.change);
    percentChangeTextColor = InvestrendTheme.changeTextColor(data.change);
    percentChangeBackgroundColor =
        InvestrendTheme.priceBackgroundColorDouble(data.change);
    /*
    if (data.percentChange > 0.0) {
      percentText = '+' + formatterNumber.format(data.percentChange) + '%';
      changeText = formatterNumber.format(data.change);

      percentChangeTextColor = InvestrendTheme.of(context).greenText;
      percentChangeBackgroundColor = InvestrendTheme.of(context).greenBackground;
    } else if (data.percentChange < 0.0) {
      percentText = formatterNumber.format(data.percentChange) + '%';
      changeText = formatterNumber.format(data.change);
      percentChangeTextColor = InvestrendTheme.of(context).redText;
      percentChangeBackgroundColor = InvestrendTheme.of(context).redBackground;
    } else {
      percentText = formatterNumber.format(data.percentChange) + '%';
      changeText = formatterNumber.format(data.change);
      percentChangeTextColor = InvestrendTheme.of(context).yellowText;
      percentChangeBackgroundColor = InvestrendTheme.of(context).yellowBackground;
    }
    */
    return Expanded(
      flex: 1,
      child: MaterialButton(
        height: 64.0,
        elevation: 0.0,
        splashColor: InvestrendTheme.of(context).tileSplashColor,
        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
        color: InvestrendTheme.of(context).tileBackground,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10.0),
          side: BorderSide(
            color: InvestrendTheme.of(context).tileBackground!,
            width: 0.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 48.0,
                // color: Colors.purple,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AutoSizeText(
                      data.name!,
                      minFontSize: 8.0,
                      style: InvestrendTheme.of(context).small_w600_compact,
                      maxLines: 1,
                    ),
                    AutoSizeText(
                      priceText,
                      minFontSize: 8.0,
                      style: InvestrendTheme.of(context)
                          .more_support_w600_compact
                          ?.copyWith(
                              fontSize: 12.0, color: percentChangeTextColor),
                      maxLines: 1,
                    ),

                    // FittedBox(
                    //       child: Text(data.name, style: InvestrendTheme.of(context).small_w700),
                    //   //child: Text(priceText, style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold)),
                    // ),
                    // SizedBox(
                    //   height: 5.0,
                    // ),
                    // Spacer(flex: 1,),
                    // FittedBox(
                    //   child: Text(
                    //     //data.code,
                    //     priceText,
                    //     style: InvestrendTheme.of(context).more_support_w700.copyWith(fontSize: 12.0),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                height: 48.0,
                //color: percentChangeBackgroundColor,
                margin: EdgeInsets.only(left: 8.0),
                padding: EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
                decoration: BoxDecoration(
                  color: percentChangeBackgroundColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                //constraints: BoxConstraints.expand(width: 100, height: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      changeText,
                      minFontSize: 8.0,
                      style: InvestrendTheme.of(context)
                          .more_support_w600_compact
                          ?.copyWith(
                              fontSize: 12.0, color: percentChangeTextColor),
                      maxLines: 1,
                      textAlign: TextAlign.end,
                    ),
                    AutoSizeText(
                      percentText,
                      minFontSize: 8.0,
                      style: InvestrendTheme.of(context)
                          .more_support_w600_compact
                          ?.copyWith(
                              fontSize: 12.0, color: percentChangeTextColor),
                      maxLines: 1,
                      textAlign: TextAlign.end,
                    ),

                    // ComponentCreator.textFit(context, changeText,
                    //     style: TextStyle(color: percentChangeTextColor), alignment: Alignment.centerRight),
                    // SizedBox(
                    //   height: 5.0,
                    // ),
                    // ComponentCreator.textFit(context, percentText,
                    //     style: TextStyle(color: percentChangeTextColor), alignment: Alignment.centerRight),
                  ],
                ),
              ),
            ),
          ],
        ),
        onPressed: () {},
      ),
    );
  }

  Widget tileCommodities(
      BuildContext context, HomeCommodities data, bool first, double width) {
    double left = first ? 0 : 8.0;
    //double right = end ? 0 : 0.0;
    String percentText;
    Color percentChangeTextColor;
    Color percentChangeBackgroundColor;
    percentText = InvestrendTheme.formatPercentChange(data.percentChange);
    percentChangeTextColor =
        InvestrendTheme.changeTextColor(data.percentChange);
    percentChangeBackgroundColor =
        InvestrendTheme.priceBackgroundColorDouble(data.percentChange);
    /*
    if (data.percentChange > 0) {
      percentText = '+' + formatterNumber.format(data.percentChange) + '%';
      percentChangeTextColor = InvestrendTheme.of(context).greenText;
      percentChangeBackgroundColor = InvestrendTheme.of(context).greenBackground;
    } else if (data.percentChange < 0) {
      percentText = formatterNumber.format(data.percentChange) + '%';
      percentChangeTextColor = InvestrendTheme.of(context).redText;
      percentChangeBackgroundColor = InvestrendTheme.of(context).redBackground;
    } else {
      percentText = formatterNumber.format(data.percentChange) + '%';
      percentChangeTextColor = InvestrendTheme.of(context).yellowText;
      percentChangeBackgroundColor = InvestrendTheme.of(context).yellowBackground;
    }
    */
    return SizedBox(
      width: width,
      height: width,
      child: MaterialButton(
        elevation: 0.0,
        minWidth: 50.0,
        splashColor: InvestrendTheme.of(context).tileSplashColor,
        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
        color: InvestrendTheme.of(context).tileBackground,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10.0),
          side: BorderSide(
            color: InvestrendTheme.of(context).tileBackground!,
            width: 0.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AutoSizeText(
              data.code!,
              minFontSize: 8.0,
              style: InvestrendTheme.of(context).small_w600_compact,
              maxLines: 1,
            ),
            SizedBox(
              height: 4.0,
            ),
            AutoSizeText(
              InvestrendTheme.formatPriceDouble(data.price, showDecimal: false),
              minFontSize: 8.0,
              style: InvestrendTheme.of(context)
                  .more_support_w600_compact
                  ?.copyWith(fontSize: 12.0, color: percentChangeTextColor),
              maxLines: 1,
            ),
            SizedBox(
              height: 4.0,
            ),
            // FittedBox(
            //   fit: BoxFit.scaleDown,
            //   child: Text(
            //     data.code,
            //     style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
            //   ),
            // ),
            // FittedBox(
            //   fit: BoxFit.scaleDown,
            //   child: Text(
            //     InvestrendTheme.formatPriceDouble(data.price, showDecimal: false),
            //     //formatterNumber.format(data.price),
            //     style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.w300),
            //   ),
            // ),
            // SizedBox(
            //   height: 5.0,
            // ),
            Container(
              padding:
                  EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
              decoration: BoxDecoration(
                color: percentChangeBackgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
              child: AutoSizeText(
                percentText,
                minFontSize: 8.0,
                style: InvestrendTheme.of(context)
                    .more_support_w600_compact
                    ?.copyWith(fontSize: 12.0, color: percentChangeTextColor),
                maxLines: 1,
              ),
              // child: FittedBox(
              //   fit: BoxFit.scaleDown,
              //   child: Text(
              //     percentText,
              //     style: TextStyle(color: percentChangeTextColor),
              //   ),
              // ),
            ),
          ],
        ),
        onPressed: () {},
      ),
    );
  }

  Widget tileThreeLayers(BuildContext context, String code, double price,
      double percentChange, bool first, double width) {
    double left = first ? 0 : 8.0;
    //double right = end ? 0 : 0.0;
    String percentText;
    Color percentChangeTextColor;
    Color percentChangeBackgroundColor;

    percentText = InvestrendTheme.formatPercentChange(percentChange);
    percentChangeTextColor = InvestrendTheme.changeTextColor(percentChange);
    percentChangeBackgroundColor =
        InvestrendTheme.priceBackgroundColorDouble(percentChange);

    /*
    if (percentChange > 0) {
      percentText = '+' + formatterNumber.format(percentChange) + '%';
      percentChangeTextColor = InvestrendTheme.of(context).greenText;
      percentChangeBackgroundColor = InvestrendTheme.of(context).greenBackground;
    } else if (percentChange < 0) {
      percentText = formatterNumber.format(percentChange) + '%';
      percentChangeTextColor = InvestrendTheme.of(context).redText;
      percentChangeBackgroundColor = InvestrendTheme.of(context).redBackground;
    } else {
      percentText = formatterNumber.format(percentChange) + '%';
      percentChangeTextColor = InvestrendTheme.of(context).yellowText;
      percentChangeBackgroundColor = InvestrendTheme.of(context).yellowBackground;
    }
    */
    return SizedBox(
      width: width,
      child: MaterialButton(
        elevation: 0.0,
        minWidth: 50.0,
        splashColor: InvestrendTheme.of(context).tileSplashColor,
        padding:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
        color: InvestrendTheme.of(context).tileBackground,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10.0),
          side: BorderSide(
            color: InvestrendTheme.of(context).tileBackground!,
            width: 0.0,
          ),
        ),
        child: Column(
          children: [
            AutoSizeText(
              code,
              minFontSize: 8.0,
              style: InvestrendTheme.of(context).small_w600,
              maxLines: 1,
            ),
            SizedBox(
              height: 4.0,
            ),
            AutoSizeText(
              InvestrendTheme.formatPriceDouble(price, showDecimal: false),
              minFontSize: 8.0,
              style: InvestrendTheme.of(context)
                  .more_support_w600
                  ?.copyWith(fontSize: 12.0, color: percentChangeTextColor),
              maxLines: 1,
            ),
            SizedBox(
              height: 4.0,
            ),
            // FittedBox(
            //   fit: BoxFit.scaleDown,
            //   child: Text(
            //     code,
            //     style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
            //   ),
            // ),
            // FittedBox(
            //   fit: BoxFit.scaleDown,
            //   child: Text(
            //     InvestrendTheme.formatPriceDouble(price, showDecimal: false),
            //     //formatterNumber.format(price),
            //     style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.w300),
            //   ),
            // ),
            // SizedBox(
            //   height: 5.0,
            // ),
            Container(
              padding:
                  EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
              decoration: BoxDecoration(
                color: percentChangeBackgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
              child: AutoSizeText(
                percentText,
                minFontSize: 8.0,
                style: InvestrendTheme.of(context)
                    .more_support_w600
                    ?.copyWith(fontSize: 12.0, color: percentChangeTextColor),
                maxLines: 1,
              ),
              // child: FittedBox(
              //   fit: BoxFit.scaleDown,
              //   child: Text(
              //     percentText,
              //     style: TextStyle(color: percentChangeTextColor),
              //   ),
              // ),
            ),
          ],
        ),
        onPressed: () {},
      ),
    );
  }

  Widget gridWorldIndices(BuildContext context, List<HomeWorldIndices> list) {
    List<Widget> widgets = List<Widget>.empty(growable: true);

    //int countData = list.length;
    int countData = min(list.length, 4);
    for (int i = 0; i < countData; i++) {
      int iPlus = i + 1;
      if (iPlus < countData) {
        widgets.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            tileWorlIndices(context, list[i], true),
            SizedBox(
              width: cardMargin,
            ),
            tileWorlIndices(context, list[iPlus], false)
          ],
        ));
        i = iPlus;
      } else {
        widgets.add(Row(
          children: [
            tileWorlIndices(context, list[i], true),
            SizedBox(
              width: cardMargin,
            ),
            Expanded(
              flex: 1,
              child: Center(child: Text(' ')),
            ),
          ],
        ));
      }
      widgets.add(SizedBox(
        height: cardMargin,
      ));
    }
    print('richy widgets size : ' + widgets.length.toString());

    return Column(
      children: widgets,
    );

    // return LayoutBuilder(builder: (context, constrains)
    // {
    //   print('constrains ' + constrains.maxWidth.toString());
    //   const int gridCount = 2;
    //   double availableWidth = constrains.maxWidth - cardMargin;
    //   print('availableWidth $availableWidth');
    //   double tileWidth = availableWidth / gridCount;
    //   print('tileWidth $tileWidth');
    //
    //
    //
    // });
  }

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
  }

  Future onRefresh() {
    if (!active) {
      active = true;
      _startTimer();
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));

    //
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    bool hasAccount =
        context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    List<Widget> childs = [
      hasAccount
          ? createCardPortfolio(context)
          : Container(
              margin: EdgeInsets.only(
                  top: InvestrendTheme.cardPaddingVertical,
                  bottom: InvestrendTheme.cardPaddingVertical,
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral),
              child: BannerOpenAccount(),
            ),

      ValueListenableBuilder(
          valueListenable: wrapper.returnNotifier,
          builder: (context, value, child) {
            bool hasAccount =
                context.read(dataHolderChangeNotifier).user.accountSize() > 0;
            if (!hasAccount) {
              return SizedBox(
                width: 1.0,
              );
            }
            // bool isEmpty = listHighest.isEmpty && listLowest.isEmpty;
            // if (isEmpty) {
            //   return SizedBox(
            //     width: 1.0,
            //   );
            // }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ComponentCreator.dividerCard(context),
                ButtonTabSwitch(
                  button_portfolio_rank,
                  wrapper.buttonPortfolioRankNotifier,
                  paddingButton: EdgeInsets.only(
                      left: InvestrendTheme.cardPaddingGeneral,
                      right: InvestrendTheme.cardPaddingGeneral,
                      top: InvestrendTheme.cardPaddingVertical,
                      bottom: InvestrendTheme.cardPaddingVertical),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: InvestrendTheme.cardPaddingGeneral,
                      right: InvestrendTheme.cardPaddingGeneral,
                      bottom: InvestrendTheme.cardPaddingVertical),
                  child: ValueListenableBuilder(
                    valueListenable: wrapper.returnNotifier,
                    builder: (context, value, child) {
                      bool highest =
                          wrapper.buttonPortfolioRankNotifier.value == 0;
                      List content = highest ? listHighest : listLowest;
                      String emptyMessage = highest
                          ? 'return_highest_empty_label'.tr()
                          : 'return_lowest_empty_label'.tr();
                      return GridPriceThree(
                        content,
                        gridCount: 3,
                        stylePrice:
                            InvestrendTheme.of(context).small_w600_compact,
                        ratioHeight: 0.8,
                        emptyMessage: emptyMessage,
                        showDecimalPrice: false,
                        onSelected: (code) {
                          if (!StringUtils.isEmtpy(code)) {
                            Stock? stock =
                                InvestrendTheme.storedData?.findStock(code);
                            if (stock != null) {
                              context
                                  .read(primaryStockChangeNotifier)
                                  .setStock(stock);
                              InvestrendTheme.of(context)
                                  .showStockDetail(context);
                            }
                          }
                          return '';
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }),
      ComponentCreator.dividerCard(context),
      createCardBriefing(context),
      ComponentCreator.dividerCard(context),

      CardEIPO(
        'home_card_eipo_title'.tr(),
        onRetry: () {
          //doUpdate(pullToRefresh: true);
          fetchEIPO();
        },
      ),
      // SizedBox(
      //   height: InvestrendTheme.cardPadding,
      // ),
      Consumer(builder: (context, watch, child) {
        final notifier = watch(eipoNotifier);
        if (notifier.currentState.isNoData()) {
          return SizedBox(
            width: 1.0,
          );
        }
        return ComponentCreator.dividerCard(context);
      }),

      /* di HIDE dulu, belum munculin sosmed untuk test launch
      CardCompetitions('home_card_competition_title'.tr(), listCompetition),
      ComponentCreator.dividerCard(context),
      */
      //createCardThemes(context),
      CardStockThemes(
        'home_card_themes_title'.tr(),
        wrapper.themeNotifier,
        onRetry: () {
          doUpdate(pullToRefresh: true);
        },
      ),

      ComponentCreator.dividerCard(context),

      // CardProfiles('home_card_profiles_title'.tr(), listProfiles),
      // ComponentCreator.dividerCard(context),

      CardNews(
        'home_card_news_title'.tr(),
      ),
      // SizedBox(
      //   height: InvestrendTheme.cardPadding,
      // ),

      //ComponentCreator.dividerCard(context),
    ];

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      /*
        child: ListView(
        //padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
        shrinkWrap: false,
        children: childs,
      ),
      */
      child: ScrollablePositionedList.builder(
        itemCount: childs.length,
        itemBuilder: (context, index) => childs.elementAt(index),
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
      ),
    );
  }

  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return SingleChildScrollView(
      //padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0),
      child: Column(
        children: [

          createCardPortfolio(context),
          ComponentCreator.divider(context),

          createCardBriefing(context),
          ComponentCreator.divider(context),

          CardEIPO('home_card_eipo_title'.tr(), listEIPO),
          SizedBox(height: InvestrendTheme.cardPadding,),

          //createCardCompetition(context),
          CardCompetitions('home_card_competition_title'.tr(), listCompetition),
          SizedBox(height: InvestrendTheme.cardPadding,),
          ComponentCreator.divider(context),
          //createCardThemes(context),
          CardStockThemes('home_card_themes_title'.tr(), wrapper.themeNotifier),

          ComponentCreator.divider(context),
          //createCardProfiles(context),
          CardProfiles('home_card_profiles_title'.tr(), listProfiles),
          SizedBox(height: InvestrendTheme.cardPadding,),
          ComponentCreator.divider(context),

          CardNews('home_card_news_title'.tr(),),
          SizedBox(height: InvestrendTheme.cardPadding,),


          ComponentCreator.divider(context),
        ],
      ),
    );
  }
  */
  @override
  void onActive() {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //doUpdate(pullToRefresh: true);
    // });
    doUpdate();
    _startTimer();
  }

  void _startTimer() {
    print(routeName + '._startTimer');
    if (!InvestrendTheme.DEBUG) {
      if (_timer == null || !_timer!.isActive) {
        _timer = Timer.periodic(_durationUpdate, (timer) {
          print('_timer.tick : ' + _timer!.tick.toString());
          if (active) {
            doUpdate();
          }
        });
      }
    }
  }

  void _stopTimer() {
    print(routeName + '._stopTimer');
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    if (!active) {
      print(routeName +
          ' doUpdate ignored active : $active  isVisible : ' +
          isVisible().toString());
      return false;
    }
    if (mounted && context != null) {
      bool isForeground = context.read(dataHolderChangeNotifier).isForeground;
      if (!isForeground) {
        print(routeName +
            ' doUpdate ignored isForeground : $isForeground  isVisible : ' +
            isVisible().toString());
        return false;
      }
    }
    print(routeName +
        ' doUpdate performed active : $active   pullToRefresh : $pullToRefresh  isVisible : ' +
        isVisible().toString() +
        '  ' +
        DateTime.now().toString());
    if (pullToRefresh) {
      setNotifierLoading(wrapper.briefingNotifier);
      setNotifierLoading(wrapper.themeNotifier);
      setNotifierLoading(wrapper.indicesNotifier);
      setNotifierLoading(wrapper.commoditiesNotifier);
      setNotifierLoading(wrapper.currenciesNotifier);
      setNotifierLoading(wrapper.cryptoNotifier);
      if (mounted) {
        context.read(eipoNotifier).setLoading();
      }

      // wrapper.briefingNotifier.setLoading();
      // wrapper.themeNotifier.setLoading();
      // wrapper.indicesNotifier.setLoading();
      // wrapper.commoditiesNotifier.setLoading();
      // wrapper.currenciesNotifier.setLoading();
      // wrapper.cryptoNotifier.setLoading();
      // context.read(eipoNotifier).setLoading();

      try {
        print('try fetch briefing  mounted : $mounted');
        final briefing = await InvestrendTheme.datafeedHttp.fetchBriefing();
        if (briefing != null) {
          if (mounted) {
            wrapper.briefingNotifier.setValue(briefing);
          } else {
            print('ignored briefing, mounted : $mounted');
          }
        } else {
          //wrapper.briefingNotifier.setNoData();
          setNotifierNoData(wrapper.briefingNotifier);
        }
      } catch (error) {
        //wrapper.briefingNotifier?.setError(message: error.toString());
        setNotifierError(wrapper.briefingNotifier, error.toString());
      }
    }
    Future<List<StockThemes>> themes =
        InvestrendTheme.datafeedHttp.fetchThemes();
    themes.then((List<StockThemes>? value) {
      StockThemesData dataTheme = StockThemesData();
      if (value != null) {
        value.forEach((theme) {
          dataTheme.datas?.add(theme);
        });
      }

      if (mounted) {
        wrapper.themeNotifier.setValue(dataTheme);
      } else {
        print('ignored dataTheme, mounted : $mounted');
      }
    }).onError((error, stackTrace) {
      //wrapper.themeNotifier?.setError(message: error.toString());
      setNotifierError(wrapper.themeNotifier, error.toString());
    });
    //news = HttpSSI.fetchNews();

    try {
      final HomeData? homeData =
          await InvestrendTheme.datafeedHttp.fetchHomeData();
      if (homeData != null) {
        if (homeData.validIndices()) {
          HomeIndicesData indicesData = HomeIndicesData();
          if (homeData.listIndices != null) {
            indicesData.datas?.addAll(homeData.listIndices!);
          }

          if (mounted) {
            wrapper.indicesNotifier.setValue(indicesData);
          } else {
            print('ignored indicesData, mounted : $mounted');
          }
        } else {
          //wrapper.indicesNotifier.setNoData();
          setNotifierNoData(wrapper.indicesNotifier);
        }
        if (homeData.validCommodities()) {
          HomeCommoditiesData commoditiesData = HomeCommoditiesData();
          if (homeData.listCommodities != null) {
            commoditiesData.datas?.addAll(homeData.listCommodities!);
          }
          if (mounted) {
            wrapper.commoditiesNotifier.setValue(commoditiesData);
          } else {
            print('ignored commoditiesData, mounted : $mounted');
          }
        } else {
          //wrapper.commoditiesNotifier.setNoData();
          setNotifierNoData(wrapper.commoditiesNotifier);
        }

        if (homeData.validCurrencies()) {
          HomeCurrenciesData currenciesData = HomeCurrenciesData();
          if (homeData.listCurrencies != null) {
            currenciesData.datas?.addAll(homeData.listCurrencies!);
          }
          if (mounted) {
            wrapper.currenciesNotifier.setValue(currenciesData);
          } else {
            print('ignored currenciesData, mounted : $mounted');
          }
        } else {
          //wrapper.currenciesNotifier.setNoData();
          setNotifierNoData(wrapper.currenciesNotifier);
        }

        if (homeData.validCrypto()) {
          HomeCryptoData cryptoData = HomeCryptoData();
          if (homeData.listCrypto != null) {
            cryptoData.datas?.addAll(homeData.listCrypto!);
          }
          if (mounted) {
            wrapper.cryptoNotifier.setValue(cryptoData);
          } else {
            print('ignored cryptoData, mounted : $mounted');
          }
        } else {
          //wrapper.cryptoNotifier.setNoData();
          setNotifierNoData(wrapper.cryptoNotifier);
        }
      }
    } catch (error) {
      // wrapper.indicesNotifier?.setError(message: error.toString());
      // wrapper.commoditiesNotifier?.setError(message: error.toString());
      // wrapper.currenciesNotifier?.setError(message: error.toString());
      // wrapper.cryptoNotifier?.setError(message: error.toString());

      setNotifierError(wrapper.indicesNotifier, error.toString());
      setNotifierError(wrapper.commoditiesNotifier, error.toString());
      setNotifierError(wrapper.currenciesNotifier, error.toString());
      setNotifierError(wrapper.cryptoNotifier, error.toString());
    }

    try {
      final List<ListEIPO>? eipo =
          await InvestrendTheme.datafeedHttp.fetchEIPOList();
      if (eipo != null) {
        if (mounted) {
          context.read(eipoNotifier).setValue(eipo);
        }
        // if(mounted){
        //   context.read(eipoNotifier).setValue(eipo);
        // }else{
        //   print('ignored eipo, mounted : $mounted');
        // }
      } else {
        //wrapper.briefingNotifier.setNoData();
        //setNotifierNoData(wrapper.briefingNotifier);
        if (mounted) {
          context.read(eipoNotifier).setNoData();
        }
      }
    } catch (error) {
      //wrapper.briefingNotifier?.setError(message: error.toString());
      //setNotifierError(wrapper.briefingNotifier, error.toString());
      if (mounted) {
        context.read(eipoNotifier).setError(message: error.toString());
      }
    }
    if (!mounted) {
      return false;
    }

    updateAccountCashPosition(context);
    if (!mounted) {
      return false;
    }

    bool hasAccount =
        context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    if (hasAccount) {
      //updateStockPositionActiveAccount();
      int selected = context.read(accountChangeNotifier).index;
      //Account account = InvestrendTheme.of(context).user.getAccount(selected);
      Account? account =
          context.read(dataHolderChangeNotifier).user.getAccount(selected);

      if (account == null) {
        //String text = 'No Account Selected. accountSize : ' + InvestrendTheme.of(context).user.accountSize().toString();
        //String text = routeName + ' No Account Selected. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
        String errorNoAccount = 'error_no_account_selected'.tr();
        String text = routeName +
            ' $errorNoAccount. accountSize : ' +
            context
                .read(dataHolderChangeNotifier)
                .user
                .accountSize()
                .toString();
        InvestrendTheme.of(context).showSnackBar(context, text);
        return false;
      } else {
        try {
          print(routeName + ' try stockPosition');
          final stockPosition = await InvestrendTheme.tradingHttp
              .stock_position(
                  account.brokercode,
                  account.accountcode,
                  context.read(dataHolderChangeNotifier).user.username!,
                  InvestrendTheme.of(context).applicationPlatform,
                  InvestrendTheme.of(context).applicationVersion);
          DebugWriter.information(routeName +
              ' Got stockPosition ' +
              stockPosition.accountcode! +
              '   stockList.size : ' +
              stockPosition.stockListSize().toString());
          if (mounted) {
            wrapper.stockPositionNotifier.setValue(stockPosition);
          }
        } catch (e) {
          DebugWriter.information(
              routeName + ' stockPosition Exception : ' + e.toString());

          handleNetworkError(context, e);
          return false;
          /*
        if (!mounted) {
          return;
        }
        if (e is TradingHttpException) {
          if (e.isUnauthorized()) {
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            return false;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label = network_error_label.replaceFirst("#CODE#", e.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            return false;
          }
        }
        */
        }
      }

      try {
        print('try Summarys : ' +
            wrapper.stockPositionNotifier.value!.stockListSize().toString());
        if (wrapper.stockPositionNotifier.value!.stockListSize() > 0) {
          String codes = '';
          wrapper.stockPositionNotifier.value?.stocksList?.forEach((element) {
            if (StringUtils.isEmtpy(codes)) {
              codes = element.stockCode!;
            } else {
              codes += '_' + element.stockCode!;
            }
          });

          final List<StockSummary>? stockSummarys = await InvestrendTheme
              .datafeedHttp
              .fetchStockSummaryMultiple(codes, 'RG');
          listLowest.clear();
          listHighest.clear();
          if (mounted) {
            if (stockSummarys != null && stockSummarys.isNotEmpty) {
              //print(routeName + ' Future Summary DATA : ' + stockSummary.code + '  prev : ' + stockSummary.prev.toString());
              //_summaryNotifier.setData(stockSummary);
              //context.read(stockSummaryChangeNotifier).setData(stockSummary);
              int count = stockSummarys.length;
              stockSummarys
                  .sort((a, b) => a.percentChange!.compareTo(b.percentChange!));
              int maxLoop = 3;
              for (int i = 0; i < count; i++) {
                if (i < maxLoop) {
                  StockSummary data = stockSummarys.elementAt(i);
                  if (data.change! < 0) {
                    listLowest.add(HomePortfolio(data.code!,
                        data.close!.toDouble(), data.percentChange!));
                  }
                } else {
                  break;
                }
              }
              int index = 0;
              for (int i = count - 1; i >= 0; i--) {
                if (index < maxLoop) {
                  StockSummary data = stockSummarys.elementAt(i);
                  if (data.change! > 0) {
                    listHighest.add(HomePortfolio(data.code!,
                        data.close!.toDouble(), data.percentChange!));
                  }
                  index++;
                } else {
                  break;
                }
              }
            } else {
              print(routeName + ' Future Summarys NO DATA');
            }
            wrapper.returnNotifier.value = !wrapper.returnNotifier.value;
          }
        }
      } catch (e) {
        DebugWriter.information(
            routeName + ' Summarys Exception : ' + e.toString());
        print(e);
      }
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  void fetchEIPO() async {
    try {
      final List<ListEIPO>? eipo =
          await InvestrendTheme.datafeedHttp.fetchEIPOList();
      if (eipo != null) {
        if (mounted) {
          context.read(eipoNotifier).setValue(eipo);
        }

        // if(mounted){
        //   context.read(eipoNotifier).setValue(eipo);
        // }else{
        //   print('ignored eipo, mounted : $mounted');
        // }
      } else {
        //wrapper.briefingNotifier.setNoData();
        //setNotifierNoData(wrapper.briefingNotifier);
        if (mounted) {
          context.read(eipoNotifier).setNoData();
        }
      }
    } catch (error) {
      //wrapper.briefingNotifier?.setError(message: error.toString());
      //setNotifierError(wrapper.briefingNotifier, error.toString());
      if (mounted) {
        context.read(eipoNotifier).setError(message: error.toString());
      }
    }
  }

  @override
  void onInactive() {
    _stopTimer();
  }
/*
  Widget gridCommodities(BuildContext context) {
    List<Widget> columns = List<Widget>.empty(growable: true);

    int countData = listCommodities.length;
    for (int i = 0; i < countData; i++) {
      if (i + 4 < countData) {
        columns.add(Row(
          children: [
            tileCommodities(context, listCommodities[i], true),
            SizedBox(width: cardMargin,),
            tileCommodities(context, listCommodities[i + 1], true),
            SizedBox(width: cardMargin,),
            tileCommodities(context, listCommodities[i + 2], true),
            SizedBox(width: cardMargin,),
            tileCommodities(context, listCommodities[i + 3], true),
          ],
        ));
      } else if (i + 3 < countData) {
        columns.add(Row(
          children: [
            tileCommodities(context, listCommodities[i], true),
            SizedBox(width: cardMargin,),
            tileCommodities(context, listCommodities[i + 1], true),
            SizedBox(width: cardMargin,),
            tileCommodities(context, listCommodities[i + 2], true),
            SizedBox(width: cardMargin,),
            Expanded(
              flex: 1,
              child: Center(child: Text(' ')),
            ),
          ],
        ));
      } else if (i + 2 < countData) {
        columns.add(Row(
          children: [
            tileCommodities(context, listCommodities[i], true),
            SizedBox(width: cardMargin,),
            tileCommodities(context, listCommodities[i + 1], true),
            SizedBox(width: cardMargin,),
            Expanded(
              flex: 1,
              child: Center(child: Text(' ')),
            ),
            SizedBox(width: cardMargin,),
            Expanded(
              flex: 1,
              child: Center(child: Text(' ')),
            ),
          ],
        ));
      } else if (i + 2 < countData) {
        columns.add(Row(
          children: [
            tileCommodities(context, listCommodities[i], true),
            SizedBox(width: cardMargin,),
            Expanded(
              flex: 1,
              child: Center(child: Text(' ')),
            ),
            SizedBox(width: cardMargin,),
            Expanded(
              flex: 1,
              child: Center(child: Text(' ')),
            ),
            SizedBox(width: cardMargin,),
            Expanded(
              flex: 1,
              child: Center(child: Text(' ')),
            ),
          ],
        ));
      }
      i = i + 4;
      columns.add(SizedBox(height: cardMargin,));
    }
    
    return Column(
      children: columns,
    );
  }

   */
}
