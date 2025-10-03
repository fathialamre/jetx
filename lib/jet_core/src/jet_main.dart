import 'jet_interface.dart';

///Use to instead of Navigator.push, off instead of Navigator.pushReplacement,
///offAll instead of Navigator.pushAndRemoveUntil. For named routes just
///add "named" after them. Example: toNamed, offNamed, and AllNamed.
///To return to the previous screen, use back().
///No need to pass any context to Jet, just put the name of the route inside
///the parentheses and the magic will occur.
class _JetImpl extends JetInterface {}

// ignore: non_constant_identifier_names
final Jet = _JetImpl();
