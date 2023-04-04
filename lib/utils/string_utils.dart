import 'package:html_unescape/html_unescape.dart';

class StringUtils {
  static bool equalsIgnoreCase(String text_1, String text_2) {
    if (text_1 == null || text_2 == null) {
      return false;
    }
    return text_1.toLowerCase() == text_2.toLowerCase();
  }

  static bool contains(String find, List<String> list) {
    bool contains = false;
    int count = list != null ? list.length : 0;
    for (int i = 0; i < list.length; i++) {
      String pattern = list.elementAt(i);
      if (StringUtils.equalsIgnoreCase(pattern, find)) {
        contains = true;
        break;
      }
    }
    return contains;
  }

  static bool isEmtpy(String value) {
    if ((value == null) || value.length == 0) {
      return true;
    } else {
      return false;
    }
  }

  static bool isContains(String text, String find) {
    if (StringUtils.isEmtpy(text)) {
      return false;
    }
    return text.contains(find);
  }

  static String removeHtml(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }

  static String decodeHtmlString(String encodedHtmlString) {
    return HtmlUnescape().convert(encodedHtmlString);
  }

  static String between(String text, String tagStart, String tagEnd) {
    int indexStart = text.indexOf(tagStart, 0);
    if (indexStart != -1) {
      indexStart = indexStart + tagStart.length;
      int indexEnd = text.indexOf(tagEnd, indexStart);
      if (indexEnd != -1) {
        return text.substring(indexStart, indexEnd);
      }
    }
    return '';
  }

  static String noNullString(String string) {
    if (string == null)
      return "";
    else
      return string;
  }

  static bool isNullOrEmpty(String string) {
    if (string != null && string.isNotEmpty) {
      return false;
    } else {
      return true;
    }
  }

  static String getFirstDigitNameTwo(String name) {
    if (!StringUtils.isEmtpy(name)) {
      List<String> splitted = name.split(' ');
      if (splitted == null || splitted.isEmpty) {
        return "--";
      }
      if (splitted.length == 1) {
        String firstname = splitted.elementAt(0);
        if (firstname.length >= 2) {
          String label = firstname.substring(0, 2);
          return label;
        } else if (firstname.length == 1) {
          String label = firstname.substring(0, 1);
          return label;
        } else {
          return "--";
        }
      }

      if (/*splitted != null && splitted.isNotEmpty && */ splitted.length >=
          2) {
        String firstname = splitted.elementAt(0);
        String secondname = splitted.elementAt(1);
        if (firstname.length > 0 && secondname.length > 0) {
          String label = firstname.substring(0, 1) + secondname.substring(0, 1);
          return label;
        } else if (firstname.length > 0) {
          String label = firstname.substring(0, 1);
          return label;
        } else if (secondname.length > 0) {
          String label = secondname.substring(0, 1);
          return label;
        }
      }
    }
    return "--";
  }
}
