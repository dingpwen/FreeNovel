import 'package:novel/db/Novel.dart';
import 'package:novel/db/NovelDatabase.dart';
import "package:novel/utils/DioHelper.dart";
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:synchronized/synchronized.dart';
import 'dart:io';

abstract class BaseSearch {
  static const PARENT_CLASS = "parent";
  static const ITEM_CLASS = "item";
  static const ITEM_ID = "id";
  static const ITEM_PATH = "path";
  static const ITEM_URL = "url";
  static const ITEM_TITLE = "title";
  static const _FIRST_TITLE = '第一章';
  static const _FIRST_TITLE2 = '第1章';
  static const _BATCH_NUM = 60;
  final _lock = new Lock();

  dynamic getParams(String query);
  String getSearchUrl();
  static List<String> _downloadUrls = [];
  String getMethod() {
    return 'GET';
  }

  bool needGbk() {
    return false;
  }

  doSearch<T>(String query,
      {Function(T t) success, Function(int errorType) error}) async {
    DioHelper.doGet(getSearchUrl(),
        method: getMethod(),
        needGbk: needGbk(),
        params: getParams(query),
        success: success,
        error: error);
  }

  Future<dynamic> parseResult(String response);
  int _downloadState = 0; //0:下载中 1：下载完成 2：取消下载
  List<Novel> _novelList = [];
  int getSearchType() {
    return 0;
  }

  setGbk(bool isGbk) {}

  cancel() {
    _setDownloadState(2);
  }

  _setDownloadState(int state) {
    var lock = Lock();
    lock.synchronized(() {
      print("setState:$state");
      _downloadState = state;
    });
  }

  int getDownloadState() {
    return _downloadState;
  }

  Future<void> downloadItem(String url, final int novelId) async {
    if (url.isEmpty || _downloadUrls.contains(url)) {
      return;
    }
    _downloadUrls.add(url);
    _novelList.clear();
    _setDownloadState(0);
    print("downloadItem:$url");
    await DioHelper.doGet(url, params: null, needGbk: needGbk(),
        success: (response) async {
      _downloadUrls.remove(url);
      //print("flutter response:$response");
      await parseItem(response, novelId);
    }, error: (errorType) {
      print("errorType:$errorType");
      _downloadUrls.remove(url);
      _setDownloadState(1);
    });
  }

  List<Element> getTargetElement(String response, Map<String, dynamic> params) {
    var document = parse(response);
    String itemClass = params[ITEM_CLASS];
    if (itemClass != null && itemClass.length > 0) {
      return document.querySelectorAll(itemClass);
    }
    String itemId = params[ITEM_ID];
    String itemPath = params[ITEM_PATH];
    if (itemId != null && itemId.length > 0) {
      var item = document.getElementById(itemId);
      if (itemPath == null || itemPath.length == 0) {
        return [item];
      }
      return item.querySelectorAll(itemPath);
    }
    String parentClass = params[PARENT_CLASS];
    assert(parentClass != null && parentClass.length > 0);
    final parentItem = document.querySelector(".$parentClass");
    return parentItem.querySelectorAll(itemPath);
  }

  Map<String, dynamic> getItemParams();
  String getBaseUrl();

  dynamic parseItemContent(Element element) {
    String url = element.attributes['href'].trim();
    String content = element.text.trim();
    return {BaseSearch.ITEM_URL: url, BaseSearch.ITEM_TITLE: content};
  }

  Future<dynamic> parseItem(String response, final int novelId) async {
    final itemParams = getItemParams();
    List<Element> lists = getTargetElement(response, itemParams);
    List<Map<String, String>> items = [];
    items = List.generate(lists.length, (i) {
      return parseItemContent(lists[i]);
    });
    if (items.length == 0) {
      //await NovelDatabase.getInstance().deleteBook(novelId);
      if (_downloadUrls.isEmpty) {
        _setDownloadState(1);
      }
      return items;
    }
    //print("Items:$items");
    int page = 0;
    final Novel novel =
        await NovelDatabase.getInstance().getNovelMaxPage(novelId, status: 1);
    int i = 0;
    int pos = -1;
    //查找已保存的章节
    if (novel != null && (novel.url != null)) {
      i = items.length - 1;
      for (; i >= 0; --i) {
        String url = getBaseUrl() + items[i][ITEM_URL];
        if (novel.url == url) {
          pos = i + 1;
          page = novel.page + 1;
        }
      }
    }
    //查找第一章，因为有的网址可能会把最新章节放在前面
    if (pos < 0) {
      i = 0;
      for (; i < items.length; ++i) {
        String title = items[i][ITEM_TITLE];
        if (title.contains(_FIRST_TITLE) || title.contains(_FIRST_TITLE2)) {
          pos = i;
          break;
        }
      }
    }

    if (pos < 0) {
      pos = 0;
    } else if (pos == items.length) {
      print("Novel $novelId No need update.");
      _setDownloadState(1);
      return items;
    }
    for (; pos < items.length && (_downloadState != 2); ++pos) {
      final element = items[pos];
      String url = getBaseUrl() + element[ITEM_URL];
      await downloadContent(url, novelId, page++, element[ITEM_TITLE]);
      sleep(const Duration(milliseconds: 10));
    }
    /*items.forEach((element) {
      String url = getBaseUrl() + element[ITEM_URL];
      downloadContent(url, novelId, page++, element[ITEM_TITLE]);
    });*/
    final element = items[pos - 1];
    await NovelDatabase.getInstance()
        .updateBookLast(novelId, element[ITEM_TITLE], element[ITEM_URL]);
    if (_downloadState != 2) {
      _setDownloadState(1);
    }
    return items;
  }

  downloadContent(
      String url, final int novelId, final int page, final String title,
      {Function(String content) complete, Function(int errorType) fail}) async {
    if (url.isEmpty || _downloadUrls.contains(url)) {
      return;
    }
    var novel =
        Novel(id: novelId, page: page, title: title, content: "", url: url);
    _downloadUrls.add(url);
    print("downloadContent:$url");
    await DioHelper.doGet(url, params: null, needGbk: needGbk(),
        success: (response) async {
      _downloadUrls.remove(url);
      String content = parseContentResponse(response, novel);
      novel.content = content;
      novel.status = 1;
      saveNovel(novel);
      if (complete != null) {
        complete(content);
      }
    }, error: (errorType) {
      _downloadUrls.remove(url);
      if (fail != null) {
        fail(errorType);
      }
      saveNovel(novel);
    });
  }

  void saveNovel(Novel novel) async {
    await _lock.synchronized(() async {
      _novelList.add(novel);
      if (_novelList.length >= _BATCH_NUM || _downloadUrls.isEmpty) {
        await NovelDatabase.getInstance().insertNovels(_novelList);
        _novelList.clear();
      }
    });
  }

  Map<String, dynamic> getContentParams();

  dynamic parseContent(Element element) {
    String content = element.innerHtml;
    return content;
  }

  dynamic parseContentResponse(String response, Novel novel) {
    final params = getContentParams();
    Element element = getTargetElement(response, params)[0];
    if (element == null) {
      return "";
    }
    dynamic content = parseContent(element);
    return content;
  }
}
