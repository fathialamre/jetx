import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

// import 'lang/translation_service.dart';
// import 'routes/app_pages.dart';
// import 'shared/logger/logger_utils.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return JetMaterialApp(
//       theme: ThemeData(useMaterial3: true),
//       debugShowCheckedModeBanner: false,
//       enableLog: true,
//       logWriterCallback: Logger.write,
//       initialRoute: AppPages.INITIAL,
//       getPages: AppPages.routes,
//       locale: TranslationService.locale,
//       fallbackLocale: TranslationService.fallbackLocale,
//       translations: TranslationService(),
//     );
//   }
// }

/// Nav 2 snippet
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      getPages: [
        JetPage(
            participatesInRootNavigator: true,
            name: '/first',
            page: () => const First()),
        JetPage(
          name: '/second',
          page: () => const Second(),
          transition: Transition.downToUp,
        ),
        JetPage(
          name: '/third',
          page: () => const Third(),
        ),
        JetPage(
          name: '/fourth',
          page: () => const Fourth(),
        ),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirstController extends JetxController {
  @override
  void onClose() {
    print('on close first');
    super.onClose();
  }
}

class First extends StatelessWidget {
  const First({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('First rebuild');
    Jet.put(FirstController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('page one'),
        leading: IconButton(
          icon: const Icon(Icons.more),
          onPressed: () {
            Jet.snackbar(
              'title',
              "message",
              mainButton:
                  TextButton(onPressed: () {}, child: const Text('button')),
              isDismissible: true,
              duration: Duration(seconds: 5),
              snackbarStatus: (status) => print(status),
            );
            // print('THEME CHANGED');
            // Jet.changeTheme(
            //     Jet.isDarkMode ? ThemeData.light() : ThemeData.dark());
          },
        ),
      ),
      body: Center(
        child: SizedBox(
          height: 300,
          width: 300,
          child: ElevatedButton(
            onPressed: () {
              Jet.toNamed('/second?id=123');
            },
            child: const Text('next screen'),
          ),
        ),
      ),
    );
  }
}

class SecondController extends JetxController {
  final textEdit = TextEditingController();
  @override
  void onClose() {
    print('on close second');
    textEdit.dispose();
    super.onClose();
  }
}

class Second extends StatelessWidget {
  const Second({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Jet.put(SecondController());
    print('second rebuild');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => print('pop invoked'),
      child: Scaffold(
        appBar: AppBar(
          title: Text('page two ${Jet.parameters["id"]}'),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                  child: TextField(
                controller: controller.textEdit,
              )),
              SizedBox(
                height: 300,
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    Jet.toNamed('/third');
                  },
                  child: const Text('next screen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Third extends StatelessWidget {
  const Third({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: const Text('page three'),
      ),
      body: Center(
        child: SizedBox(
          height: 300,
          width: 300,
          child: ElevatedButton(
            onPressed: () {
              Jet.offNamedUntil('/fourth', (route) {
                return Jet.currentRoute == '/first';
              });
            },
            child: const Text('go to first screen'),
          ),
        ),
      ),
    );
  }
}

class Fourth extends StatelessWidget {
  const Fourth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: const Text('page four'),
      ),
      body: Center(
        child: SizedBox(
          height: 300,
          width: 300,
          child: ElevatedButton(
            onPressed: () {
              Jet.back();
            },
            child: const Text('go to first screen'),
          ),
        ),
      ),
    );
  }
}
