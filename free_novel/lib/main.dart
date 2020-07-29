import 'package:flutter/material.dart';
import 'package:novel/pages/BaseTabBarWidget.dart';
import 'package:novel/pages/BookListPage.dart';
import 'package:novel/pages/NovelSearchPage.dart';
import 'package:novel/pages/CataloguePage.dart';
import 'package:novel/pages/SettingsPage.dart';
import 'package:novel/task/AutoRefresh.dart';
import 'package:background_fetch/background_fetch.dart';

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  DateTime timestamp = DateTime.now();
  print("[BackgroundFetch] Headless event received: $taskId@$timestamp");
  BackgroundFetch.finish(taskId);

  if (taskId == 'flutter_background_fetch') {
    await AutoRefresh.fetchAndUpdateAllBooks();
  }
}

void main() {
  runApp(MyApp());
  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

const String searchRoute = 'NovelSearch';
const String catalogueRoute = 'CataloguePage';
const String settingsRoute = 'SettingsPage';

class MyApp extends StatelessWidget {
  final routes = {
    "BookList": (buildContext) => BookListPage(),
    searchRoute: (buildContext) => NovelSearchPage(),
    catalogueRoute: (buildContext, {arguments}) => CataloguePage(arguments),
    settingsRoute: (buildContext) => SettingsPage()
  };
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BookTabBarPage(),
      routes: routes,
    );
  }
}

class BookTabBarPage extends StatefulWidget {
  @override
  createState() => BookTabBarState();
}

class BookTabBarState extends State<BookTabBarPage> {
  final List<String> tab = ["书架", "设置"];
  final PageController pageController = new PageController();

  _renderTab() {
    List<Widget> list = new List();
    for (int i = 0; i < tab.length; i++) {
      list.add(new FlatButton(
          onPressed: () {
            pageController.jumpTo(MediaQuery.of(context).size.width * i);
          },
          child: new Text(
            tab[i],
            maxLines: 1,
          )));
    }
    return list;
  }

  _renderPage() {
    return [
      new BookListPage(),
      new SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BaseTabBarWidget(
      tabViews: _renderPage(),
      tabItems: _renderTab(),
      pageController: pageController,
      backgroundColor: Colors.greenAccent,
      indicatorColor: Colors.white,
    );
  }
}


