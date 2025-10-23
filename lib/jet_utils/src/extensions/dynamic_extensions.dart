import '../jet_utils/jet_utils.dart';

extension GetDynamicUtils on dynamic {
  bool? get isBlank => JetUtils.isBlank(this);

  void printError(
          {String info = '', Function logFunction = JetUtils.printFunction}) =>
      // ignore: unnecessary_this
      logFunction('Error: ${this.runtimeType}', this, info, isError: true);

  void printInfo(
          {String info = '',
          Function printFunction = JetUtils.printFunction}) =>
      // ignore: unnecessary_this
      printFunction('Info: ${this.runtimeType}', this, info);
}
