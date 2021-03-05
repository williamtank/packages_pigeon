import 'package:pigeon/pigeon.dart';

class Person {
  String name;
  int age;
}

class Request {
  String query;
}

class Reply {
  String result;
  List<String> list;
}

@HostApi()
abstract class ExampleApi {
  void searchVoid();

  String searchArgEmpty();

  void searchReturnEmpty();

  Reply search(Request request);

  bool searchMore(int code, Person person);

  @async
  String searchMoreAsync(String name, bool needFullName);

  @async
  void searchReturnAsync(int code, Person person);

  @async
  Reply searchEmptyAsync();
}

// 配置编译输出路径，包名
void configurePigeon(PigeonOptions opts) {
  opts.dartOut = 'example/output/example.g.dart';
  opts.objcHeaderOut = 'example/output/Example.h';
  opts.objcSourceOut = 'example/output/Example.m';
  opts.objcOptions.prefix = 'FLT';
  opts.javaOut = 'example/output/Example.java';
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
