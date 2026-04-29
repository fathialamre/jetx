import '../jet_utils/jet_utils.dart';

extension JetDynamicUtils on dynamic {
  bool? get isBlank => JetUtils.isBlank(this);

  // NOTE: `runtimeType` below is debug-friendly; in release builds Dart may
  // return minified/obfuscated names. Acceptable for log strings — do not
  // rely on the textual form for control flow.
  void printError(
          {String info = '', Function logFunction = JetUtils.printFunction}) =>
      // ignore: unnecessary_this
      logFunction('Error: ${this.runtimeType}', this, info, isError: true);

  // NOTE: see `printError` — `runtimeType` is debug-only labelling.
  void printInfo(
          {String info = '',
          Function printFunction = JetUtils.printFunction}) =>
      // ignore: unnecessary_this
      printFunction('Info: ${this.runtimeType}', this, info);
}
