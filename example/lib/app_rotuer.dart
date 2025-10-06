import 'package:example/pages/tabs/todos_app.dart';
import 'package:jet/jet_navigation/jet_navigation.dart';

final routes = [
  // Todos app as initial route
  JetPage(
    name: '/',
    page: () => const TodosApp(),
    transition: Transition.fadeIn,
  ),
];
