import 'package:jetx/jetx_utils/src/get_utils/get_utils.dart';

extension GetStringUtils on String {
  /// Discover if the String is a valid number
  bool get isNum => JetUtils.isNum(this);

  /// Discover if the String is numeric only
  bool get isNumericOnly => JetUtils.isNumericOnly(this);

  String numericOnly({bool firstWordOnly = false}) =>
      JetUtils.numericOnly(this, firstWordOnly: firstWordOnly);

  /// Discover if the String is alphanumeric only
  bool get isAlphabetOnly => JetUtils.isAlphabetOnly(this);

  /// Discover if the String is a boolean
  bool get isBool => JetUtils.isBool(this);

  /// Discover if the String is a vector
  bool get isVectorFileName => JetUtils.isVector(this);

  /// Discover if the String is a ImageFileName
  bool get isImageFileName => JetUtils.isImage(this);

  /// Discover if the String is a AudioFileName
  bool get isAudioFileName => JetUtils.isAudio(this);

  /// Discover if the String is a VideoFileName
  bool get isVideoFileName => JetUtils.isVideo(this);

  /// Discover if the String is a TxtFileName
  bool get isTxtFileName => JetUtils.isTxt(this);

  /// Discover if the String is a Document Word
  bool get isDocumentFileName => JetUtils.isWord(this);

  /// Discover if the String is a Document Excel
  bool get isExcelFileName => JetUtils.isExcel(this);

  /// Discover if the String is a Document Powerpoint
  bool get isPPTFileName => JetUtils.isPPT(this);

  /// Discover if the String is a APK File
  bool get isAPKFileName => JetUtils.isAPK(this);

  /// Discover if the String is a PDF file
  bool get isPDFFileName => JetUtils.isPDF(this);

  /// Discover if the String is a HTML file
  bool get isHTMLFileName => JetUtils.isHTML(this);

  /// Discover if the String is a URL file
  bool get isURL => JetUtils.isURL(this);

  /// Discover if the String is a Email
  bool get isEmail => JetUtils.isEmail(this);

  /// Discover if the String is a Phone Number
  bool get isPhoneNumber => JetUtils.isPhoneNumber(this);

  /// Discover if the String is a DateTime
  bool get isDateTime => JetUtils.isDateTime(this);

  /// Discover if the String is a MD5 Hash
  bool get isMD5 => JetUtils.isMD5(this);

  /// Discover if the String is a SHA1 Hash
  bool get isSHA1 => JetUtils.isSHA1(this);

  /// Discover if the String is a SHA256 Hash
  bool get isSHA256 => JetUtils.isSHA256(this);

  /// Discover if the String is a binary value
  bool get isBinary => JetUtils.isBinary(this);

  /// Discover if the String is a ipv4
  bool get isIPv4 => JetUtils.isIPv4(this);

  bool get isIPv6 => JetUtils.isIPv6(this);

  /// Discover if the String is a Hexadecimal
  bool get isHexadecimal => JetUtils.isHexadecimal(this);

  /// Discover if the String is a palindrome
  bool get isPalindrome => JetUtils.isPalindrome(this);

  /// Discover if the String is a passport number
  bool get isPassport => JetUtils.isPassport(this);

  /// Discover if the String is a currency
  bool get isCurrency => JetUtils.isCurrency(this);

  /// Discover if the String is a CPF number
  bool get isCpf => JetUtils.isCpf(this);

  /// Discover if the String is a CNPJ number
  bool get isCnpj => JetUtils.isCnpj(this);

  /// Discover if the String is a case insensitive
  bool isCaseInsensitiveContains(String b) =>
      JetUtils.isCaseInsensitiveContains(this, b);

  /// Discover if the String is a case sensitive and contains any value
  bool isCaseInsensitiveContainsAny(String b) =>
      JetUtils.isCaseInsensitiveContainsAny(this, b);

  /// capitalize the String
  String get capitalize => JetUtils.capitalize(this);

  /// Capitalize the first letter of the String
  String get capitalizeFirst => JetUtils.capitalizeFirst(this);

  /// remove all whitespace from the String
  String get removeAllWhitespace => JetUtils.removeAllWhitespace(this);

  /// converter the String
  String? get camelCase => JetUtils.camelCase(this);

  /// Discover if the String is a valid URL
  String? get paramCase => JetUtils.paramCase(this);

  /// add segments to the String
  String createPath([Iterable? segments]) {
    final path = startsWith('/') ? this : '/$this';
    return JetUtils.createPath(path, segments);
  }

  /// capitalize only first letter in String words to upper case
  String capitalizeAllWordsFirstLetter() =>
      JetUtils.capitalizeAllWordsFirstLetter(this);
}
