import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:novel/db/BookDesc.dart';
import 'package:novel/db/NovelDatabase.dart';
import 'package:novel/pages/ContentPage.dart';
import 'package:novel/pages/NovelSearchPage.dart';
import 'package:novel/pages/CataloguePage.dart';
import 'package:novel/task/AutoRefresh.dart';
import 'package:novel/utils/SpUtils.dart';
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

class MyApp extends StatelessWidget {
  final routes = {
    "BookList": (buildContext) => BookListPage(),
    searchRoute: (buildContext) => NovelSearchPage(),
    catalogueRoute: (buildContext, {arguments}) => CataloguePage(arguments),
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
        primarySwatch: Colors.blueGrey,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BookListPage(),
      routes: routes,
    );
  }
}

class BookListPage extends StatefulWidget {
  @override
  createState() => BookListState();
}

class BookListState extends State<BookListPage> {
  List<BookDesc> _books = [];
  int _curIndex = -1;

  @override
  void initState() {
    super.initState();
    loadData();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    BackgroundFetch.configure(BackgroundFetchConfig(
      minimumFetchInterval: 60,
      forceAlarmManager: true,
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
      requiresBatteryNotLow: true,
      requiresCharging: false,
      requiresStorageNotLow: true,
      requiresDeviceIdle: false,
      requiredNetworkType: NetworkType.UNMETERED,
    ), _onBackgroundFetch).then((int status){
      print('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });

    /*BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.customtask",
        delay: 10000,
        periodic: false,
        forceAlarmManager: true,
        stopOnTerminate: false,
        enableHeadless: true
    ));*/
  }

  void _onBackgroundFetch(String taskId) async {
    DateTime timestamp = DateTime.now();
    print("[BackgroundFetch] Event received: $taskId@$timestamp");

    if (taskId == "flutter_background_fetch") {
      // Schedule a one-shot task when fetch event received (for testing).
      BackgroundFetch.scheduleTask(TaskConfig(
          taskId: "com.transistorsoft.customtask",
          delay: 5000,
          periodic: false,
          forceAlarmManager: true,
          stopOnTerminate: false,
          enableHeadless: true
      ));
    }

    // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

  loadData() async {
    final bookList = await NovelDatabase.getInstance().findAllBooks();
    bookList.forEach((element) {
      print("book id:${element.id}, name: ${element.bookName}");
    });
    setState(() {
      _curIndex = -1;
      _books = bookList;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
/*        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: null,
        ),*/
        title: new Text("我的私人书库"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: goSearch)
        ],
      ),
      body: (_books.length == 0)
          ? Center(child: Text("没有收藏任何书籍"))
          : _buildBooksListView(context),
    );
  }

  Widget _buildBooksListView(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
          return _buildItemView(context, index);
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 2,
            color: Theme.of(context).primaryColor,
          );
        },
        itemCount: _books.length);
  }

  Widget _buildItemView(BuildContext context, int index) {
    BookDesc book = _books[index];
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  height: 120,
                  width: 80,
                  child: CachedNetworkImage(
                      placeholder: (context, string) =>
                          Image.asset("lib/images/nopage.jpg"),
                      imageUrl: book.bookCover),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(book.bookName),
                      Text("作者：${book.author}"),
                      Text("简介：${book.bookDesc}",
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text("最新章节：${book.lastTitle}"),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: FlatButton(
                        onPressed: () => readBook(book),
                        child: Text(
                          "开始阅读",
                          style: TextStyle(color: Colors.green),
                        )),
                  ),
                )
              ],
            ),
          ),
          Offstage(
            offstage: (_curIndex == index) ? false : true,
            child: Container(
              padding: EdgeInsets.only(left: 80, top: 0, right: 80, bottom: 20),
              //child: Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Text(
                      "查看目录",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: () => gotoCatalogue(book),
                    constraints: BoxConstraints(minWidth: 80),
                  ),
                  IconButton(
                    icon: Text(
                      "删除书籍",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: () => deleteBook(book),
                    constraints: BoxConstraints(minWidth: 80),
                  ),
                  IconButton(
                    icon: Text(
                      book.status == 0?"置顶书籍":"取消置顶",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: () => topBook(book),
                    constraints: BoxConstraints(minWidth: 80),
                  ),
                ],
              ),
            ), //),
          ),
        ],
      ),
      onTap: () => showOrHideMenu(index),
    );
  }

  readBook(BookDesc book) async {
    int page = await SpUtils.getSavedPage(book.id);
    if (page == null) {
      page = 0;
    }
    print("page:$page");
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ContentPage(arguments: {'id': book.id, 'page': page});
    }));
  }

  showOrHideMenu(int index) {
    int newIndex = (_curIndex == index) ? -1 : index;
    setState(() {
      _curIndex = newIndex;
    });
  }

  deleteBook(BookDesc book) async{
    await NovelDatabase.getInstance().deleteBook(book.id);
    loadData();
  }

  topBook(BookDesc book) async{
    int status = (book.status + 1)%2;
    await NovelDatabase.getInstance().updateBookStatus(book.id, status);
    loadData();
  }

  goSearch() {
    Navigator.of(context).pushNamed(searchRoute).then((value) {
      print("value:$value");
      if (value is List) {
        int refresh = value[0];
        print("refresh:$refresh");
        if (refresh == 1) {
          loadData();
        }
      }
    });
  }

  gotoCatalogue(BookDesc book) {
    //Navigator.of(context).pushNamed(catalogueRoute, arguments:{"id":book.id, "title":book.bookName});
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return new CataloguePage({"id": book.id, "title": book.bookName});
    }));
  }
}