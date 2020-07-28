class SearchDesc {
  int id;
  final String pid;
  final String path;
  final String myid;

  SearchDesc({this.pid, this.path, this.myid});

  factory SearchDesc.fromJson(Map<String, dynamic> parsedJson) {
    SearchDesc search = SearchDesc(
      pid: parsedJson['pid'],
      path: parsedJson['path'],
      myid: parsedJson['myid'],
    );
    search.id = parsedJson['id'];
    return search;
  }

  Map<String, dynamic> toJson() {
    return {'pid': pid, 'path': path, 'myid': myid};
  }
}
