import 'dart:math';
import 'package:Investrend/utils/string_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jiffy/jiffy.dart';
import 'package:image/image.dart' as imageTools;
import 'dart:io';

class Utils {
  static int randomNumber(int min, int max, {Random random}) {
    if (random = null) {
      random = Random();
    }
    int next = min + random.nextInt(max - min);
    return next;
  }

  static void printList(List<String> list, {String caller = ''}) {
    int count = list != null ? list.length : 0;
    for (int i = 0; i < count; i++) {
      print('$caller[$i] = ' + list.elementAt(i));
    }
  }

  static imageTools.Image resizeImage(String path, {int maxWidth = 1080}) {
    // Read a jpeg image from file.
    File file = new File(path);
    if (file != null) {
      imageTools.Image image = imageTools.decodeImage(file.readAsBytesSync());
      // Resize the image to a 2000? thumbnail (maintaining the aspect ratio).
      if (image != null) {
        //int maxWidth = 500;
        if (image.width > maxWidth) {
          print('resizeImage resize $path is performed');
          imageTools.Image resized =
              imageTools.copyResize(image, width: maxWidth);
          return resized;
        } else {
          return image;
        }
      } else {
        print('resizeImage decode $path is NULL');
      }
    } else {
      print('resizeImage readFile $path is NULL');
    }
    return null;
  }

  static imageTools.Image resizeImageFile(File file, {int maxWidth = 1080}) {
    // Read a jpeg image from file.
    //File file = new File(path);
    if (file != null) {
      imageTools.Image image = imageTools.decodeImage(file.readAsBytesSync());
      // Resize the image to a 2000? thumbnail (maintaining the aspect ratio).
      if (image != null) {
        //int maxWidth = 500;
        if (image.width > maxWidth) {
          print('resizeImage resize File is performed');
          imageTools.Image resized =
              imageTools.copyResize(image, width: maxWidth);
          return resized;
        } else {
          return image;
        }
      } else {
        print('resizeImage decode File is NULL');
      }
    } else {
      print('resizeImage readFile File is NULL');
    }
    return null;
  }
  /*

  */

  static DateFormat _sosmedFormatData =
      DateFormat('yyyy-MM-ddTHH:mm:ss.000000Z');
  //static DateFormat _sosmedFormatDataNormal = DateFormat('yyyy-MM-dd HH:mm:ss');
  static DateFormat _sosmedFormatDisplayDate = DateFormat('dd/MM/yy');
  static DateFormat _sosmedFormatDisplayTime = DateFormat('HH:mm');
  static DateFormat _sosmedFormatDate = DateFormat('yyyy-MM-dd');

  static DateFormat _orderDataFormatDate = DateFormat('yyyyMMdd');
  static DateFormat _orderDisplayFormatDate = DateFormat('dd/MM/yyyy');

  static DateFormat _orderDataFormatTime =
      DateFormat('HHmmss'); // 3 digit belakang di cut
  static DateFormat _orderDisplayFormatTime = DateFormat('HH:mm:ss');

  static String removeServerAddress(String text) {
    String errorText = text;
    const String addr = 'olt1.buanacapital.com';
    if (!StringUtils.isEmtpy(errorText) &&
        errorText.toLowerCase().contains(addr)) {
      errorText = errorText.replaceFirst(addr, '****');
    }
    return errorText;
  }

  static String formatOrderDate(String rawDate) {
    if (StringUtils.isEmtpy(rawDate)) {
      return '-';
    }
    if (rawDate.length != 8) {
      return rawDate;
    }
    String modifiedTime = rawDate.substring(0, 4) +
        '/' +
        rawDate.substring(4, 6) +
        '/' +
        rawDate.substring(6, 8);
    return modifiedTime;
    /*
    try{
      DateTime date = _orderDataFormatDate.parse(rawDate);
      if(date != null){
        return _orderDisplayFormatDate.format(date);
      }
    }catch(error){
      return '♾';
    }
    */
  }

  static String formatOrderTime(String rawTime) {
    if (StringUtils.isEmtpy(rawTime)) {
      return '-';
    }
    String modifiedTime;
    if (rawTime.length < 6) {
      return rawTime;
    } else {
      modifiedTime = rawTime.substring(0, 2) +
          ':' +
          rawTime.substring(2, 4) +
          ':' +
          rawTime.substring(4, 6);
    }
    return modifiedTime;
    /*
    try{
      DateTime date = _orderDataFormatTime.parse(modifiedTime);
      if(date != null){
        return _orderDisplayFormatTime.format(date);
      }
    }catch(error){
      print('formatOrderTime [$modifiedTime] error '+error.toString());
      print(error);
      return '♾';
    }
    */
  }

  static String formatDate(DateTime dateTime) {
    return _sosmedFormatDate.format(dateTime);
  }

  static String formatDatabaseTime(DateTime dateTime) {
    //return _sosmedFormatData.format(dateTime);
    return dateTime.toString().replaceFirst(' ', 'T');
  }

  static double calculatePercent(int startValue, int endValue) {
    if (startValue == 0) {
      return 0.0;
    }
    return (((endValue - startValue) / startValue) * 100).toDouble();
  }

  static String displayTimingDays(String created_at, String expire_at) {
    if (StringUtils.isEmtpy(created_at)) {
      return ' ';
    }
    if (StringUtils.isEmtpy(expire_at)) {
      return ' ';
    }
    print('displayTimingDays 1');
    DateTime created = _sosmedFormatData.parseUtc(created_at);
    print('displayTimingDays 2');
    DateTime expired = _sosmedFormatData.parseUtc(expire_at);
    print('displayTimingDays 3');
    int days = expired.difference(created).inDays;
    print('displayTimingDays 4');
    if (days > 1) {
      print('displayTimingDays 5A');
      return days.toString() + 'sosmed_label_expire_days'.tr();
    }
    print('displayTimingDays 5B');
    return days.toString() + 'sosmed_label_expire_day'.tr();
  }

  static String displayPostDate(String post_created) {
    if (StringUtils.isEmtpy(post_created)) {
      return ' ';
    }

    /*
    "sosmed_label_hour_ago": " jam lalu",
    "sosmed_label_hours_ago": " jam lalu",
    "sosmed_label_minute_ago": " menit lalu",
    "sosmed_label_minutes_ago": " menit lalu",
    "sosmed_label_second_ago": " detik lalu",
    "sosmed_label_seconds_ago": " detik lalu",
    "sosmed_label_a_moment_ago": "baru saja",
    */
    DateTime created = _sosmedFormatData.parseUtc(post_created);
    DateTime now = DateTime.now().toUtc();
    print('now UTC : ' +
        now.toString() +
        '  now biasa : ' +
        DateTime.now().toString() +
        '  created : ' +
        created.toString());
    int days = now.difference(created).inDays;
    int hours = now.difference(created).inHours;
    int minutes = now.difference(created).inMinutes;
    int second = now.difference(created).inSeconds;

    print(
        'Difference  days : $days  hours : $hours  minutes : $minutes  second : $second');
    if (days > 0) {
      return _sosmedFormatDisplayDate.format(created.toLocal());
    }

    if (hours > 0) {
      //return sosmedFormatDisplayTime.format(created);
      if (hours == 1) {
        return '$hours' + 'sosmed_label_hour_ago'.tr();
      } else {
        return '$hours' + 'sosmed_label_hours_ago'.tr();
      }
    }

    if (minutes > 0) {
      if (minutes == 1) {
        return '$minutes' + 'sosmed_label_minute_ago'.tr();
      } else {
        return '$minutes' + 'sosmed_label_minutes_ago'.tr();
      }
    }

    if (second > 0) {
      if (second == 1) {
        return '$second' + 'sosmed_label_second_ago'.tr();
      } else {
        return '$second' + 'sosmed_label_seconds_ago'.tr();
      }
    }
    return 'sosmed_label_a_moment_ago'.tr();
  }

  static String displayPostDateDetail(String post_created) {
    if (StringUtils.isEmtpy(post_created)) {
      return ' ';
    }

    /*

    "sosmed_label_year_ago": " year ago",
    "sosmed_label_years_ago": " years ago",
    "sosmed_label_month_ago": " month ago",
    "sosmed_label_months_ago": " months ago",
    "sosmed_label_week_ago": " week ago",
    "sosmed_label_weeks_ago": " weeks ago",
    "sosmed_label_day_ago": " yesterday",
    "sosmed_label_days_ago": " days ago",


    "sosmed_label_hour_ago": " jam lalu",
    "sosmed_label_hours_ago": " jam lalu",
    "sosmed_label_minute_ago": " menit lalu",
    "sosmed_label_minutes_ago": " menit lalu",
    "sosmed_label_second_ago": " detik lalu",
    "sosmed_label_seconds_ago": " detik lalu",
    "sosmed_label_a_moment_ago": "baru saja",
    */
    DateTime created = _sosmedFormatData.parseUtc(post_created);
    DateTime now = DateTime.now().toUtc();
    print('now UTC : ' +
        now.toString() +
        '  now biasa : ' +
        DateTime.now().toString() +
        '  created : ' +
        created.toString());

    //num days = Jiffy([2018, 1, 29]).diff(Jiffy([2019, 10, 7]), Units.DAY); // -616
    int weeks = Jiffy([created.year, created.month, created.day])
        .diff(Jiffy([now.year, now.month, now.day]), Units.WEEK); // -88
    int months = Jiffy([created.year, created.month, created.day])
        .diff(Jiffy([now.year, now.month, now.day]), Units.MONTH); // -20
    int years = Jiffy([created.year, created.month, created.day])
        .diff(Jiffy([now.year, now.month, now.day]), Units.YEAR);

    int days = now.difference(created).inDays;
    int hours = now.difference(created).inHours;
    int minutes = now.difference(created).inMinutes;
    int second = now.difference(created).inSeconds;

    print(
        'Difference  years : $years  months : $months  weeks : $weeks  days : $days  hours : $hours  minutes : $minutes  second : $second');

    if (years > 0) {
      if (years == 1) {
        return '$years' + 'sosmed_label_year_ago'.tr();
      } else {
        return '$years' + 'sosmed_label_years_ago'.tr();
      }
    }

    if (months > 0) {
      if (months == 1) {
        return '$months' + 'sosmed_label_month_ago'.tr();
      } else {
        return '$months' + 'sosmed_label_months_ago'.tr();
      }
    }

    if (weeks > 0) {
      if (weeks == 1) {
        return '$weeks' + 'sosmed_label_week_ago'.tr();
      } else {
        return '$weeks' + 'sosmed_label_weeks_ago'.tr();
      }
    }

    // if(days > 0){
    //   return _sosmedFormatDisplayDate.format(created.toLocal());
    // }

    if (days > 0) {
      if (days == 1) {
        //return '$days' + 'sosmed_label_day_ago'.tr();
        return 'sosmed_label_day_ago'.tr();
      } else {
        return '$days' + 'sosmed_label_days_ago'.tr();
      }
    }

    if (hours > 0) {
      //return sosmedFormatDisplayTime.format(created);
      if (hours == 1) {
        return '$hours' + 'sosmed_label_hour_ago'.tr();
      } else {
        return '$hours' + 'sosmed_label_hours_ago'.tr();
      }
    }

    if (minutes > 0) {
      if (minutes == 1) {
        return '$minutes' + 'sosmed_label_minute_ago'.tr();
      } else {
        return '$minutes' + 'sosmed_label_minutes_ago'.tr();
      }
    }

    if (second > 0) {
      if (second == 1) {
        return '$second' + 'sosmed_label_second_ago'.tr();
      } else {
        return '$second' + 'sosmed_label_seconds_ago'.tr();
      }
    }
    return 'sosmed_label_a_moment_ago'.tr();
  }

  static String displayExpireDate(String post_expired) {
    if (StringUtils.isEmtpy(post_expired)) {
      return ' ';
    }
    /*
    "sosmed_label_expire_left": " lagi",
    "sosmed_label_expire_day": " hari",
    "sosmed_label_expire_days": " hari",
    "sosmed_label_expire_hour": " jam",
    "sosmed_label_expire_hours": " jam",
    "sosmed_label_expire_minute": " menit",
    "sosmed_label_expire_minutes": " menit",
    */
    DateTime expired = _sosmedFormatData.parseUTC(post_expired);
    DateTime now = DateTime.now().toUtc();
    int days = expired.difference(now).inDays;
    if (days > 0) {
      if (days == 1) {
        return days.toString() +
            'sosmed_label_expire_day'.tr() +
            'sosmed_label_expire_left'.tr();
      } else {
        return days.toString() +
            'sosmed_label_expire_days'.tr() +
            'sosmed_label_expire_left'.tr();
      }
      //return _sosmedFormatDisplayDate.format(created);
    }
    int hours = expired.difference(now).inHours;
    int minutes = expired.difference(now).inMinutes;
    //int second = expired.difference(now).inSeconds;

    if (hours > 0) {
      String expireText;
      if (hours == 1) {
        expireText = hours.toString() + 'sosmed_label_expire_hour'.tr();
      } else {
        expireText = hours.toString() + 'sosmed_label_expire_hours'.tr();
      }
      if (minutes > 0) {
        if (minutes == 1) {
          expireText +=
              ' ' + minutes.toString() + 'sosmed_label_expire_minute'.tr();
        } else {
          expireText +=
              ' ' + minutes.toString() + 'sosmed_label_expire_minutes'.tr();
        }
      }

      expireText += 'sosmed_label_expire_left'.tr();
      return expireText;
    }

    if (minutes > 0) {
      if (minutes == 1) {
        return minutes.toString() +
            'sosmed_label_expire_minute'.tr() +
            'sosmed_label_expire_left'.tr();
      } else {
        return minutes.toString() +
            'sosmed_label_expire_minutes'.tr() +
            'sosmed_label_expire_left'.tr();
      }
    }
    /*
    if(second > 0){
      if(second == 1){
        return second.toString() + 'sosmed_label_expire_minute'.tr() + 'sosmed_label_expire_left'.tr();
      }else{
        return second.toString() + 'sosmed_label_expire_minutes'.tr() + 'sosmed_label_expire_left'.tr();
      }
    }*/
    return 'sosmed_label_expire_under_minute'.tr();
  }

  static String isPhoneNumberCompliant(String phone) {
    if (phone == null || phone.isEmpty) {
      return 'error_phone_number_empty'.tr();
    }

    final numericRegex = new RegExp(r'[0-9]');

    bool onlyNumber = numericRegex.hasMatch(phone);

    if (!onlyNumber) {
      return 'error_phone_number_invalid'.tr();
    }
    return null;
  }

  static String isEmailCompliant(String email) {
    if (email == null || email.isEmpty) {
      return 'error_email_empty'.tr();
    }
    int indexAt = email.indexOf('@');
    int indexDot = email.lastIndexOf('.');
    if (indexAt <= 0) {
      return 'error_email_invalid'.tr();
    }
    if (indexDot <= 0 || indexDot >= email.length - 1) {
      return 'error_email_invalid'.tr();
    }
    if (indexDot < indexAt) {
      return 'error_email_invalid'.tr();
    }
    return null;
  }

  static final String specialCharacters = '!-@_#%^&*(),.?":{}|<>';
  static String isPasswordCompliant(String password, int minLength) {
    if (password == null || password.isEmpty) {
      return 'error_password_empty'.tr();
    }
    bool hasMinLength = password.length >= minLength;
    if (!hasMinLength) {
      String error = 'error_password_minimum'.tr();
      return '$error $minLength';
    }

    bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
    if (!hasUppercase) {
      return 'error_password_uppercase'.tr();
    }
    bool hasDigits = password.contains(new RegExp(r'[0-9]'));
    if (!hasDigits) {
      return 'error_password_number'.tr();
    }
    bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
    if (!hasLowercase) {
      return 'error_password_lowercase'.tr();
    }
    //bool hasSpecialCharacters = password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>\\|/]'));
    bool hasSpecialCharacters =
        password.contains(new RegExp(r'[!@_#$%^&*(),.?":{}|<>]'));
    if (!hasSpecialCharacters) {
      hasSpecialCharacters = StringUtils.isContains(password, '-');
    }
    if (!hasSpecialCharacters) {
      return 'error_password_symbol'.tr() + ' ' + specialCharacters + r'$';
    }
    return null;
  }

  static String safeString(var data, {String defaultNo = ''}) {
    if (data == null) {
      return defaultNo;
    }
    if (data is String) {
      if (StringUtils.isEmtpy(data)) {
        return defaultNo;
      }
      return data.toString();
    } else if (data is int) {
      return data.toString();
    } else if (data is double) {
      return data.toString();
    } else if (data is bool) {
      return data.toString();
    }
    return defaultNo;
  }

  static int safeInt(var data, {int defaultNo = 0}) {
    if (data == null) {
      return defaultNo;
    }
    if (data is int) {
      return data;
    } else if (data is String) {
      if (StringUtils.isEmtpy(data)) {
        return defaultNo; //data = "0";
      } else if (StringUtils.equalsIgnoreCase(data, 'null')) {
        return defaultNo; //data = "0";
      }
      if (data.contains('.')) {
        try {
          double f = double.parse(data);
          return f.toInt();
        } catch (e) {
          print('safeDouble Exception : ' + data + '   ' + e.toString());
          return defaultNo;
        }
      } else {
        try {
          int f = int.parse(data);
          return f;
        } catch (e) {
          print('safeInt Exception : ' + data + '   ' + e.toString());
          return defaultNo;
        }
      }
    } else if (data is double) {
      return data.toInt();
    }
    return defaultNo;
  }

  static double absDouble(double data) {
    if (data != null) {
      if (data < 0) {
        data = data * -1;
      }
      return data;
    }
    return 0.0;
  }

  static double safeDouble(var data) {
    if (data == null) {
      return 0;
    }
    if (data is double) {
      return data;
    } else if (data is String) {
      if (StringUtils.isEmtpy(data))
        return 0; //data = "0";
      else if (StringUtils.equalsIgnoreCase(data, 'null'))
        return 0; //data = "0";
      try {
        double f = double.parse(data);
        return f;
      } catch (e) {
        print('safeDouble Exception : ' + data + '   ' + e.toString());
        return 0;
      }
    } else if (data is int) {
      return data.toDouble();
    }
    return 0;
  }

  /*
  static bool safeBool(String data,{bool defaultValue = false}) {
    if (StringUtils.isEmtpy(data))
      return defaultValue; //data = "false";
    bool f = StringUtils.equalsIgnoreCase(data, 'true');
    return f;
  }
  */
  static bool safeBool(var data, {bool defaultValue = false}) {
    if (data is bool) {
      return data;
    } else if (data is String) {
      if (StringUtils.isEmtpy(data))
        return defaultValue; //data = "false";
      else if (StringUtils.equalsIgnoreCase(data, 'null'))
        return defaultValue; //data = "false";

      try {
        bool f = StringUtils.equalsIgnoreCase(data, 'true');
        return f;
      } catch (e) {
        print('safeDouble Exception : ' + data + '   ' + e.toString());
        return defaultValue;
      }
    } else if (data is int) {
      return data == 0 ? false : true;
    }
    return defaultValue;
    // if (StringUtils.isEmtpy(data))
    //   return defaultValue; //data = "false";
    // bool f = StringUtils.equalsIgnoreCase(data, 'true');
    // return f;
  }

  static int safeLenght(List list) {
    return list == null ? 0 : list.length;
  }

  static String createRefferenceID() {
    var random = new Random();
    String reff = (random.nextInt(900000) + 100000).toString();
    return reff;
  }

  static List<int> parseListInt(String text) {
    List<int> result = List.empty(growable: true);
    //String b_multi_text = parsedJson['b_multi'];
    if (!StringUtils.isEmtpy(text)) {
      List<String> list = text.split('|');
      int count = list == null ? 0 : list.length;
      for (int i = 0; i < count; i++) {
        String intText = StringUtils.noNullString(list.elementAt(i)).trim();
        if (!StringUtils.isEmtpy(intText)) {
          int port = Utils.safeInt(intText);
          result.add(port);
        }
      }
    }
    return result;
  }

  static DateFormat dateFormatter =
      DateFormat('EEEE, dd/MM/yyyy HH:mm:ss', 'id');
  static DateFormat dateTimeParser = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String formatLastDataUpdate(String date, String time) {
    String displayTime = date + ' ' + time;
    DateTime dateTime = dateTimeParser.parseUtc(displayTime);
    String formatedDate = dateFormatter.format(dateTime);
    return formatedDate;
  }

  static List<int> parseMultiPort(String text) {
    return Utils.parseListInt(text);
    /*
    List<int> result = List.empty(growable: true);
    //String b_multi_text = parsedJson['b_multi'];
    if(!StringUtils.isEmtpy(text)){
      List<String> b_multi_list = text.split('|');
      int count = b_multi_list == null ? 0 : b_multi_list.length;
      for(int i = 0; i < count ; i++){
        String portText = StringUtils.noNullString(b_multi_list.elementAt(i));
        int port = Utils.safeInt(portText);
        result.add(port);
      }
    }
    return result;
    */
  }

  static bool isVersionCodeNewer(
      String existingVersionCode, String compareVersionCode) {
    if (StringUtils.isEmtpy(compareVersionCode)) {
      return false;
    }
    if (StringUtils.isEmtpy(existingVersionCode)) {
      return false;
    }
    List<String> existingList = existingVersionCode.split('.');
    List<String> compareList = compareVersionCode.split('.');
    if (existingList == null || existingList.length == 0) {
      return false;
    }
    if (compareList == null || compareList.length == 0) {
      return false;
    }
    int min = (existingList.length < compareList.length)
        ? existingList.length
        : compareList.length;

    bool flag = false;
    for (int i = 0; i < min; i++) {
      int existingSegment = Utils.safeInt(
          StringUtils.noNullString(existingList.elementAt(i)).trim());
      int compareSegment = Utils.safeInt(
          StringUtils.noNullString(compareList.elementAt(i)).trim());
      if (existingSegment == compareSegment) {
      } else if (existingSegment < compareSegment) {
        flag = true;
        break;
      } else {
        break;
      }
    }
    return flag;
    /*
    flutter: Device versionCode   : 1.0.0
    flutter: Device versionNumber : 78.0
    flutter: Server versionCode   : 1.0.0
    flutter: Server versionNumber : 70.0
    flutter: Server minimum_version_code : 1.0.0
    flutter: Server minimum_version_number : 70.0
    */
  }

  static bool isVersionCodeOlder(
      String existingVersionCode, String compareVersionCode) {
    if (StringUtils.isEmtpy(compareVersionCode)) {
      return false;
    }
    if (StringUtils.isEmtpy(existingVersionCode)) {
      return false;
    }
    List<String> existingList = existingVersionCode.split('.');
    List<String> compareList = compareVersionCode.split('.');
    if (existingList == null || existingList.length == 0) {
      return false;
    }
    if (compareList == null || compareList.length == 0) {
      return false;
    }
    int min = (existingList.length < compareList.length)
        ? existingList.length
        : compareList.length;

    bool flag = false;
    for (int i = 0; i < min; i++) {
      int existingSegment = Utils.safeInt(
          StringUtils.noNullString(existingList.elementAt(i)).trim());
      int compareSegment = Utils.safeInt(
          StringUtils.noNullString(compareList.elementAt(i)).trim());
      if (existingSegment == compareSegment) {
      } else if (existingSegment > compareSegment) {
        flag = true;
        break;
      } else {
        break;
      }
    }
    return flag;
    /*
    flutter: Device versionCode   : 1.0.0
    flutter: Device versionNumber : 78.0
    flutter: Server versionCode   : 1.0.0
    flutter: Server versionNumber : 70.0
    flutter: Server minimum_version_code : 1.0.0
    flutter: Server minimum_version_number : 70.0
    */
  }
}
