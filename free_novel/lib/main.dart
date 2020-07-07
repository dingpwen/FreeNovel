import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:novel/db/BookDesc.dart';
import 'package:novel/db/NovelDatabase.dart';
import 'package:novel/pages/NovelSearchPage.dart';
import 'package:novel/pages/CataloguePage.dart';

void main() {
  runApp(MyApp());
}

const String searchRoute = 'NovelSearch';
const String catalogueRoute = 'CataloguePage';

class MyApp extends StatelessWidget {
  final routes = {
    "BookList":(buildContext) => BookListPage(),
    searchRoute:(buildContext) => NovelSearchPage(),
    catalogueRoute:(buildContext, {arguments}) => CataloguePage(arguments),
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

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async{
    final bookList = await NovelDatabase.getInstance().findAllBooks();
    bookList.forEach((element) {
      print("book id:${element.id}, name: ${element.bookName}");
    });
    setState(() {
      _books = bookList;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: null,),
        title: new Text("我的私人书库"), centerTitle:true,
        actions: <Widget>[IconButton(icon: Icon(Icons.search), onPressed: goSearch)],
      ),
      body: (_books.length == 0)?Center(child:Text("没有收藏任何书籍")):_buildBooksListView(context),
    );
  }

  Widget _buildBooksListView(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
          return _buildItemView(context, _books[index]);
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 2,
            color: Theme.of(context).primaryColor,
          );
        },
        itemCount: _books.length);
  }

  Widget _buildItemView(BuildContext context, BookDesc book) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(top:10, bottom: 10),
        child: Row(
          children: <Widget>[
            Container(
              height: 120,
              width: 80,
              child: CachedNetworkImage(
                  placeholder:(context, string) => Image.asset("lib/images/nopage.jpg"),
                  imageUrl: book.bookCover),
            ),
            Expanded(
              flex:3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(book.bookName),
                  Text("作者：${book.author}"),
                  Text("简介：${book.bookDesc}", maxLines: 2, overflow:TextOverflow.ellipsis),
                  Text("最新章节：${book.lastTitle}"),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: FlatButton(onPressed: () => deleteBook(book),
                    child: Icon(Icons.delete_forever, color: Colors.green,)),
              ),
            )
          ],
        ),
      ),
      onTap: () => gotoCatalogue(book),
    );
  }

  deleteBook(BookDesc book) {

  }

  goSearch() {
    Navigator.of(context).pushNamed(searchRoute).then((value){
      print("value:$value");
      if(value is List) {
        int refresh = value[0];
        print("refresh:$refresh");
        if(refresh == 1) {
          loadData();
        }
      }
    });
  }

  gotoCatalogue(BookDesc book) {
    //Navigator.of(context).pushNamed(catalogueRoute, arguments:{"id":book.id, "title":book.bookName});
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return new CataloguePage({"id":book.id, "title":book.bookName});
    }));
  }
}