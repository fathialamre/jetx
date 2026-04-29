// ignore_for_file: non_constant_identifier_names
//
// The top-level identifier `Jet` is intentionally capitalised so call sites
// read like `Jet.toNamed(...)`, `Jet.find<T>()`, etc. — preserving the
// well-known GetX-style developer ergonomics that JetX inherits. This is a
// deliberate convention for the public API, not a typo. Renaming this symbol
// is a major breaking change for every JetX consumer, so the lint is
// suppressed file-wide.
import 'jet_interface.dart';

///Use to instead of Navigator.push, off instead of Navigator.pushReplacement,
///offAll instead of Navigator.pushAndRemoveUntil. For named routes just
///add "named" after them. Example: toNamed, offNamed, and AllNamed.
///To return to the previous screen, use back().
///No need to pass any context to Jet, just put the name of the route inside
///the parentheses and the magic will occur.
class _JetImpl extends JetInterface {}

/// The single global JetX entry point.
///
/// Capitalised by design — see file-level note above. Use `Jet.toNamed(...)`,
/// `Jet.find<T>()`, `Jet.put<T>()`, etc.
final Jet = _JetImpl();
