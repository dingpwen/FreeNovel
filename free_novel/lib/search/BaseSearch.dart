import 'package:novel/db/Novel.dart';
import 'package:novel/db/NovelDatabase.dart';
import "package:novel/utils/DioHelper.dart";
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

abstract class BaseSearch {
  static const PARENT_CLASS = "parent";
  static const ITEM_CLASS = "item";
  static const ITEM_ID = "id";
  static const ITEM_PATH = "path";
  static const ITEM_URL = "url";
  static const ITEM_TITLE = "title";
  static const _FIRST_TITLE = '第一章';

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
  int getSearchType() {
    return 0;
  }

  downloadItem(String url, final int novelId) async {
    if (url.isEmpty || _downloadUrls.contains(url)) {
      return;
    }
    _downloadUrls.add(url);
    print("downloadItem:$url");
    DioHelper.doGet(url, params: null, needGbk: needGbk(), success: (response) {
      //print("response:$response");
      parseItem(response, novelId);
      _downloadUrls.remove(url);
    }, error: (errorType) {
      print("errorType:$errorType");
      _downloadUrls.remove(url);
    });
  }

  List<Element> _getTargetElement(
      String response, Map<String, dynamic> params) {
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
  dynamic parseItemContent(Element element);
  String getBaseUrl();

  Future<dynamic> parseItem(String response, final int novelId) async {
    final itemParams = getItemParams();
    List<Element> lists = _getTargetElement(response, itemParams);
    List<Map<String, String>> items = [];
    items = List.generate(lists.length, (i) {
      return parseItemContent(lists[i]);
    });
    if (items.length == 0) {
      return items;
    }
    print("Items:$items");
    int page = 0;
    final Novel novel =
        await NovelDatabase.getInstance().getNovelMaxPage(novelId);
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
      i = items.length - 1;
      for (; i < items.length; ++i) {
        String title = items[i][ITEM_TITLE];
        if (title.contains(_FIRST_TITLE)) {
          pos = i;
          break;
        }
      }
    }

    if (pos < 0) {
      pos = 0;
    } else if (pos == items.length) {
      print("Novel $novelId No need update.");
      return items;
    }
    for (; pos < items.length; ++pos) {
      final element = items[pos];
      String url = getBaseUrl() + element[ITEM_URL];
      downloadContent(url, novelId, page++, element[ITEM_TITLE]);
    }
    /*items.forEach((element) {
      String url = getBaseUrl() + element[ITEM_URL];
      downloadContent(url, novelId, page++, element[ITEM_TITLE]);
    });*/
    final element = items[pos - 1];
    await NovelDatabase.getInstance()
        .updateBookLast(novelId, element[ITEM_URL], element[ITEM_TITLE]);
    return items;
  }

  downloadContent(
      String url, final int novelId, final int page, final String title,
      {Function(String content) complete, Function(int errorType) fail}) async {
    if (url.isEmpty || _downloadUrls.contains(url)) {
      return;
    }
    final novel =
        Novel(id: novelId, page: page, title: title, content: "", url: url);
    await NovelDatabase.getInstance().insertNovel(novel);
    _downloadUrls.add(url);
    print("downloadContent:$url");
    DioHelper.doGet(url, params: null, needGbk: needGbk(), success: (response) async {
      String content = await parseContentResponse(response, novelId, page);
      if (complete != null) {
        complete(content);
      }
      _downloadUrls.remove(url);
    }, error: (errorType) {
      if (fail != null) {
        fail(errorType);
      }
      _downloadUrls.remove(url);
    });
  }

  Map<String, dynamic> getContentParams();
  dynamic parseContent(Element element);

  Future<dynamic> parseContentResponse(
      String response, final int novelId, final int page) async {
    final params = getContentParams();
    Element element = _getTargetElement(response, params)[0];
    dynamic content = parseContent(element);
    //print("content:$content");
    NovelDatabase.getInstance().updateNovelContent(novelId, page, content);
    return content;
  }
}
