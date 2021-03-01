import 'package:pigeon/pigeon.dart';

class Person {
  String name;
  int age;
}

class SearchRequest {
  String query;
}

class SearchReply {
  String result;
  List<String> list;
}

@HostApi()
abstract class SearchApi {
  SearchReply search(SearchRequest request, Person person, int code);

  bool searchByCode(int code, Person person);

  @async
  String searchByName(String name, bool needFullName);
}

// 配置编译输出路径，包名
void configurePigeon(PigeonOptions opts) {
  opts.dartOut = 'example/output/search.g.dart';
  opts.objcHeaderOut = 'example/output/Search.h';
  opts.objcSourceOut = 'example/output/Search.m';
  opts.objcOptions.prefix = 'FLT';
  opts.javaOut = 'example/output/Search.java';
  opts.javaOptions.package = 'com.bytedance.artist.example';
}

/// 1.支持outputpath，默认使用dart文件名作为java/oc文件名
/// 2.支持批量指定输出路径 + 支持单独指定某文件输出路径
// void confgurePigeonV2(PigeonOptions opts){
//   opts.dartOut = 'example/output/';
//   opts.objcOut = 'example/output/';
//   opts.objcOptions.prefix = 'FLT';
//   opts.javaOut = 'example/output/';
//   opts.javaOptions.package = 'com.bytedance.artist.example';
// }
