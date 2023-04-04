
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:xml/xml.dart';
extension BetterString on String {
  String between(String tagStart, String tagEnd){
    int indexStart = indexOf(tagStart,0);
    if(indexStart != -1){
      indexStart = indexStart + tagStart.length;
      int indexEnd = indexOf(tagEnd,indexStart);
      if(indexEnd != -1){
        return substring(indexEnd,indexEnd);
      }
    }
  }
}
class HomePortfolio extends CodePricePercent{
  HomePortfolio(String code, double price, double percentChange) : super(code, price, percentChange);
  // String code;
  // int price;
  // double percentChange;
  //
  // HomePortfolio(this.code, this.price, this.percentChange);
}
class CodePricePercent{
  String code;
  double price;
  double percentChange;

  CodePricePercent(this.code, this.price, this.percentChange);
}
class CodePriceChangePercent extends CodePricePercent{
  double change;

  CodePriceChangePercent(String code, double price, this.change, double percentChange) : super(code, price, percentChange);


}
class HomeCommodities extends CodePricePercent {
  HomeCommodities(String code, double price, double percentChange) : super(code, price, percentChange);
  // String code;
  // double price;
  // double percentChange;
  //HomeCommodities(this.code, this.price, this.percentChange);
}
class HomeCrypto extends CodePricePercent {
  HomeCrypto(String code, double price, double percentChange) : super(code, price, percentChange);
  // String code;
  // double price;
  // double percentChange;
  //
  // HomeCrypto(this.code, this.price, this.percentChange);
}

class HomeCurrencies extends CodePricePercent {
  HomeCurrencies(String code, double price, double percentChange) : super(code, price, percentChange);
  // String code;
  // double price;
  // double percentChange;
  //
  // HomeCurrencies (this.code, this.price, this.percentChange);
}

class GeneralDetailPrice {
  String group          = '';
  String code           = '';
  String name           = '';
  double open           = 0.0;
  double hi             = 0.0;
  double low            = 0.0;
  double price          = 0.0;
  double change         = 0.0;
  double percentChange  = 0.0;
  String date           = '';
  String time           = '';
  String timezone       = '';
  String updated_at     = '';

  GeneralDetailPrice(this.group, this.code, this.name, this.open, this.hi, this.low, this.price, this.change, this.percentChange, this.date, this.time,
      this.timezone, this.updated_at);


  @override
  String toString() {
    return '[GlobalPrice  group : $group, code : $code, name : $name, open : $open, '
        'hi : $hi, low : $low, price : $price, change : $change, percentChange : $percentChange,'
        ' date : $date, time : $time,  timezone : $timezone, updated_at : $updated_at]';
  }
}

class CryptoPrice {
  String group          = '';
  String code           = '';
  String name           = '';
  double price          = 0.0;
  double percent_change_1h    = 0.0;
  double percent_change_24h   = 0.0;
  double percent_change_7d    = 0.0;
  double percent_change_30d   = 0.0;
  double percent_change_60d   = 0.0;
  double percent_change_90d   = 0.0;
  double volume_24h           = 0.0;
  double market_cap           = 0.0;
  String icon_url             = '';
  String last_updated         = '';
  String updated_at           = '';

  CryptoPrice(
      this.group,
      this.code,
      this.name,
      this.price,
      this.percent_change_1h,
      this.percent_change_24h,
      this.percent_change_7d,
      this.percent_change_30d,
      this.percent_change_60d,
      this.percent_change_90d,
      this.volume_24h,
      this.market_cap,
      this.icon_url,
      this.last_updated,
      this.updated_at);

  @override
  String toString() {
    return '[CryptoPrice  group : $group, code : $code, name : $name, price : $price, '
        'percent_change_1h : $percent_change_1h, percent_change_24h : $percent_change_24h, percent_change_7d : $percent_change_7d, '
        'percent_change_30d : $percent_change_30d, percent_change_60d : $percent_change_60d, '
        'percent_change_90d : $percent_change_90d, volume_24h : $volume_24h,  market_cap : $market_cap, icon_url : $icon_url '
        'last_updated : $last_updated  updated_at : $updated_at '
        ']';
  }
}


class StringIndex {
  String text;
  int number;

  StringIndex(this.text, this.number);

  @override
  String toString() {
    return '[StringIndex  text : $text  number : $number]';
  }
}
class GroupedData{
  List<StringIndex> datas = List.empty(growable: true);
  List<String> keysIndex = List.empty(growable: true);
  //Map<String, List<GlobalPrice>> map = Map<String, List<GlobalPrice>>();
  Map<String, List> map = Map<String, List>();
  bool loaded = false;
  void copyValueFrom(GroupedData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if(newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }

      this.map.clear();
      if(newValue.map != null) {
        this.map.addAll(newValue.map);
      }
      this.keysIndex.clear();
      if(newValue.keysIndex != null) {
        this.keysIndex.addAll(newValue.keysIndex);
      }
    } else {
      this.datas.clear();
      this.map.clear();
      this.keysIndex.clear();
    }
  }
  
  void addData(String group, var data){
    if(map.containsKey(group)){
      map[group].add(data);
    }else{
      keysIndex.add(group);
      //List <GlobalPrice> list = List.empty(growable: true);
      //map[group] = list;
      map[group] = List.empty(growable: true);
      map[group].add(data);
    }
  }
  int groupSize(){
    return map.keys.length;
  }
  bool isEmpty(){
    return groupSize() == 0;
  }



  int datasSize(){
    // int count = 0;
    // map.values.forEach((list) {
    //   count += list.length;
    // });
    // return count;
    return datas.length;
  }
  void constructAsList({bool withGroup=true}){
    datas.clear();
    keysIndex.forEach((group) {
      if(withGroup){
        datas.add(StringIndex(group, -1));
      }
      int count = map[group].length;
      for(int i = 0; i < count; i++){
        datas.add(StringIndex(group, i));
      }
    });
  }


  StringIndex elementAt(int index){
    if(index >= 0 && index < datas.length){
      return datas.elementAt(index);
    }
    return null;
  }
  
}
class HomeData{
  List <HomeCurrencies> listCurrencies    = List.empty(growable: true);
  List <HomeWorldIndices> listIndices     = List.empty(growable: true);
  List <HomeCommodities> listCommodities  = List.empty(growable: true);
  List <HomeCrypto> listCrypto            = List.empty(growable: true);

  bool validCrypto(){
    return listCrypto != null && listCrypto.isNotEmpty;
  }
  bool validCurrencies(){
    return listCurrencies != null && listCurrencies.isNotEmpty;
  }
  bool validCommodities(){
    return listCommodities != null && listCommodities.isNotEmpty;
  }
  bool validIndices(){
    return listIndices != null && listIndices.isNotEmpty;
  }

  void addCrypto(HomeCrypto crypto){
    if(crypto != null){
      listCrypto.add(crypto);
    }
  }

  void addCurrencies(HomeCurrencies currencies){
    if(currencies != null){
      listCurrencies.add(currencies);
    }
  }

  void addCommodities(HomeCommodities commodities){
    if(commodities != null) {
      listCommodities.add(commodities);
    }
  }

  void addIndices(HomeWorldIndices indices){
    if(indices != null){
      listIndices.add(indices);
    }
  }
}
class HomeWorldIndices extends CodePriceChangePercent{
  //String code;
  String name;

  HomeWorldIndices(String code, this.name, double price, double change, double percentChange) : super(code, price, change, percentChange);
  // double price;
  // double change;
  // double percentChange;

  //HomeWorldIndices(this.code, this.name,this.change, this.percentChange, this.price);

  factory HomeWorldIndices.fromXml(XmlElement element) {
    String code = StringUtils.noNullString(element.getAttribute('code'));
    String name = StringUtils.noNullString(element.getAttribute('name'));
    double last = Utils.safeDouble(element.getAttribute('last'));
    double change = Utils.safeDouble(element.getAttribute('change'));
    double percentChange = Utils.safeDouble(element.getAttribute('percentChange'));
    return HomeWorldIndices(code, name,last, change, percentChange );
  }

  factory HomeWorldIndices.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['code']);
    String name = StringUtils.noNullString(parsedJson['name']);
    double last = Utils.safeDouble(parsedJson['last']);
    double change = Utils.safeDouble(parsedJson['change']);
    double percentChange = Utils.safeDouble(parsedJson['percentChange']);
    return HomeWorldIndices(code, name,last, change, percentChange );
  }

}

class HomeCompetition {
  String name;
  int rank;
  int participant_size;
  String url_background;
  List <String> participants_avatar;

  HomeCompetition(this.name, this.rank, this.participant_size, this.url_background, this.participants_avatar);
}
/*
class HomeEIPO {
  String url_icon;
  String code;
  String name;
  String sector;
  String subsector;
  String companyDescription;
  String companyAddress;
  String companyWebsite;
  int offeringShare;
  double percentageTotalShare;
  String adminParticipant;
  String underwriter;



  String bookbuildingDateStart;
  String bookbuildingDateEnd;
  int bookbuildingPriceStart;
  int bookbuildingPriceEnd;

  String offeringDateStart;
  String offeringDateEnd;
  int offeringPrice;

  String allotmnentDate; // closing
  String distributionDate;
  String listingDate;

  String prospectusUrl_1;
  String prospectusUrl_2;
  String additionalInformationUrl;

  HomeEIPO(
      this.url_icon,
      this.code,
      this.name,
      this.sector,
      this.subsector,
      this.companyDescription,
      this.companyAddress,
      this.companyWebsite,
      this.offeringShare,
      this.percentageTotalShare,
      this.adminParticipant,
      this.underwriter,
      this.bookbuildingDateStart,
      this.bookbuildingDateEnd,
      this.bookbuildingPriceStart,
      this.bookbuildingPriceEnd,
      this.offeringDateStart,
      this.offeringDateEnd,
      this.offeringPrice,
      this.allotmnentDate,
      this.distributionDate,
      this.listingDate,
      this.prospectusUrl_1,
      this.prospectusUrl_2,
      this.additionalInformationUrl);

//HomeEIPO(this.name, this.offeringEnd, this.url_icon);
}
*/
class HomeThemes {
  String name;
  String description;
  String url_background;


  HomeThemes(this.name, this.description, this.url_background);
}
class HomeProfiles {
  String name;
  String description;
  String url_background;


  HomeProfiles(this.name, this.description, this.url_background);
}

class HomeNews {
  String title;
  String description;
  String url_tumbnail;
  String url_news;
  String time;
  String category;
  int commentCount;
  int likedCount;

  String toString(){
    return '[title=$title] [time=$time] [url_tumbnail=$url_tumbnail] [description=$description] [url_news=$url_news] [category=$category] ';
  }
  HomeNews(this.title, this.description,this.url_news, this.url_tumbnail, this.time, this.category, this.commentCount, this.likedCount);
  /*
  <item>
    <title>Apple akan hadirkan kembali platform media sosial Parler ke App Store</title>
    <link>https://www.antaranews.com/berita/2110802/apple-akan-hadirkan-kembali-platform-media-sosial-parler-ke-app-store</link>
    <pubDate>Tue, 20 Apr 2021 13:37:35 +0700</pubDate>
    <description>
    <![CDATA[ <img src="https://img.antaranews.com/cache/800x533/2021/02/17/2021-01-14T000000Z_1937767962_MT1SIPA0006PHF5M_RTRMADP_3_SIPA-USA.jpg" align="left" border="0">Apple Inc akan kembali menghadirkan aplikasi media sosial Parler, yang disukai oleh kaum konservatif di Amerika Serikat, di&nbsp;App Store setelah sempat ditarik menyusul kerusuhan Capitol yang mematikan pada 6 Januari ... ]]>
    </description>
    <guid isPermaLink="false">https://www.antaranews.com/berita/2110802/apple-akan-hadirkan-kembali-platform-media-sosial-parler-ke-app-store</guid>
  </item>
  */
  factory HomeNews.fromXml(XmlElement element) {
     String title = element.findElements('title').single.text;
     String description = element.findElements('description').single.text;
     String url_tumbnail = StringUtils.between(description, '<img src=\"', '\"');

     String url_news = element.findElements('link').single.text;
     String time = element.findElements('pubDate').single.text;
     
     int indexStart = description.indexOf('>');
     if(indexStart > -1){
       description = description.substring(indexStart+1);
     }
     
     // description = StringUtils.between(description,'>', ']]>');
     //String url_tumbnail = 'aa';
         String category = 'general';
     int commentCount = 3;
     int likedCount = 6;
    return HomeNews(title, description,url_news, url_tumbnail, time, category, commentCount, likedCount);
  }


  factory HomeNews.fromXmlPasarDana(XmlElement element) {
    /*
    <item>
      <title> Tekanan Jual Bayangi IHSG, Pilih Tujuh Saham Ini </title>
      <link>https://pasardana.id/news/2021/9/15/tekanan-jual-bayangi-ihsg-pilih-tujuh-saham-ini/</link>
      <guid isPermaLink="false"> https://pasardana.id/news/2021/9/15/tekanan-jual-bayangi-ihsg-pilih-tujuh-saham-ini/ </guid>
      <media:content url="https://pasardana.id/media/41084/bursa-saham-gabunganemiten1.jpg?crop=0,0,0.14250000000000004,0&cropmode=percentage&width=175&height=125&rnd=132762135520000000" medium="image" height="175" width="125"/>
      <description> &lt;p&gt;&lt;strong&gt;Pasardana.id - &lt;/strong&gt;Indeks Harga Saham Gabungan (IHSG) ditaksir akan mengalami tekanan jual pada perdagangan Kamis, 16 September 2021, setelah ditutup melemah 0,3 persen diperdagangan Rabu (15/9/2021) sore ini.&lt;/p&gt; &lt;p&gt;Menurut CEO Indosurya Bersinar Sekuritas, Wiliam Surya Wijaya, perkembangan pergerakan IHSG masih terlihat akan bergerak melemah.&lt;/p&gt; &lt;p&gt;“Hingga saat ini, IHSG terlihat masih berada dalam fase konsolidasi jangka panjang dikarenakan masih minimnya sentimen yang dapat mem-booster kenaikan IHSG,” papar William kepada media, Rabu (15/9/2021).&lt;/p&gt; &lt;p&gt;Sementara itu, lanjut dia, arus modal asing belum terlihat akan bertumbuh secara signifikan, hal ini cukup menjadi tantangan untuk dapat mendorong kenaikan IHSG.&lt;/p&gt; &lt;p&gt;“Besok (16/9), IHSG masih berpotensi terkonsolidasi,” kata dia.&lt;/p&gt; &lt;p&gt;Lebih lanjut ia menaksir, IHSG akan bergerak dari batas bawah di level 5.969 hingga batas atas pada level 6.202.&lt;/p&gt; &lt;p&gt;Adapun saham-saham yang dipatut dicermati, yakni; AALI, INDF, TLKM, ITMG, CTRA, WIKA, dan BMRI.&lt;/p&gt; &lt;p&gt; &lt;/p&gt; </description>
      <dc:creator>aziz</dc:creator>
      <pubDate>Wed, 15 Sep 2021 13:44:38 GMT</pubDate>
      <category>IHSG</category>
      <category>William Surja Wijaya</category>
      <category>AALI</category>
      <category>INDF</category>
      <category>TLKM</category>
      <category>ITMG</category>
      <category>CTRA</category>
      <category>WIKA</category>
      <category>BMRI</category>
    </item>
    */

    String title = StringUtils.noNullString(element.findElements('title').single.text);
    String description = StringUtils.noNullString(element.findElements('description').single.text);
    title = StringUtils.decodeHtmlString(title);
    title = StringUtils.removeHtml(title);
    description = StringUtils.decodeHtmlString(description);
    description = StringUtils.removeHtml(description);
    title = title.trim();
    description = description.trim();
    String marker = 'Pasardana.id';
    if(description.startsWith(marker)){
      description = description.substring(marker.length,description.length );
    }
    description = description.trim();
    if(description.startsWith('-')){
      description = description.substring(1,description.length );
    }
    description = description.trim();

    String url_tumbnail = element.findElements('media:content').toString();
    url_tumbnail = StringUtils.between(url_tumbnail, 'url=\"', '\"');
    int index = url_tumbnail.indexOf('?');
    if(index != -1){
      url_tumbnail = url_tumbnail.substring(0, index);
    }
    String url_news = element.findElements('link').single.text;
    String time = element.findElements('pubDate').single.text;

    int indexStart = description.indexOf('>');
    if(indexStart > -1){
      description = description.substring(indexStart+1);
    }

    // description = StringUtils.between(description,'>', ']]>');
    //String url_tumbnail = 'aa';
    String category = 'general';
    int commentCount = 0;
    int likedCount = 0;
    return HomeNews(title, description,url_news, url_tumbnail, time, category, commentCount, likedCount);
  }
}




