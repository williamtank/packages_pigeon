// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator_tools.dart';

/// Options that control how Objective-C code will be generated.
class ObjcOptions {
  /// Parametric constructor for ObjcOptions.
  ObjcOptions({this.header, this.prefix});

  /// The path to the header that will get placed in the source filed (example:
  /// "foo.h").
  String header;

  /// Prefix that will be appended before all generated classes and protocols.
  String prefix;
}

String _className(String prefix, String className) {
  if (prefix != null) {
    return '$prefix$className';
  } else {
    return className;
  }
}

/// iOS 基本类型转换依赖函数
String _boxMethod(String type) {
  switch (type) {
    case 'bool':
      return 'numberWithBool';
    case 'int':
      return 'numberWithInt';
    case 'double':
      return 'numberWithDouble';
  }
}

String _callbackForType(String dartType, String objcType) {
  return dartType == 'void'
      ? 'void(^)(NSError* _Nullable)'
      : 'void(^)($objcType*, NSError* _Nullable)';
}

const Map<String, String> _objcTypeForDartTypeMap = <String, String>{
  'bool': 'NSNumber *',
  'int': 'NSNumber *',
  'String': 'NSString *',
  'double': 'NSNumber *',
  'Uint8List': 'FlutterStandardTypedData *',
  'Int32List': 'FlutterStandardTypedData *',
  'Int64List': 'FlutterStandardTypedData *',
  'Float64List': 'FlutterStandardTypedData *',
  'List': 'NSArray *',
  'Map': 'NSDictionary *',
};

const Map<String, String> _propertyTypeForDartTypeMap = <String, String>{
  'String': 'copy',
  'bool': 'strong',
  'int': 'strong',
  'double': 'strong',
  'Uint8List': 'strong',
  'Int32List': 'strong',
  'Int64List': 'strong',
  'Float64List': 'strong',
  'List': 'strong',
  'Map': 'strong',
};

String _objcTypeForDartType(String type) {
  return _objcTypeForDartTypeMap[type];
}

String _propertyTypeForDartType(String type) {
  final String result = _propertyTypeForDartTypeMap[type];
  if (result == null) {
    return 'assign';
  } else {
    return result;
  }
}

void _writeClassDeclarations(Indent indent, List<Class> classes, String prefix) {
  for (Class klass in classes) {
    indent.writeln('@interface ${_className(prefix, klass.name)} : NSObject');
    for (Field field in klass.fields) {
      final HostDatatype hostDatatype = getHostDatatype(
          field, classes, _objcTypeForDartType,
          customResolver: (String x) => '${_className(prefix, x)} *');
      final String propertyType = hostDatatype.isBuiltin
          ? _propertyTypeForDartType(field.dataType)
          : 'strong';
      final String nullability =
          hostDatatype.datatype.contains('*') ? ', nullable' : '';
      indent.writeln(
          '@property(nonatomic, $propertyType$nullability) ${hostDatatype.datatype} ${field.name};');
    }
    indent.writeln('@end');
    indent.writeln('');
  }
}

void _writeHostApiDeclaration(Indent indent, Api api, ObjcOptions options) {
  final String apiName = _className(options.prefix, api.name);
  indent.writeln('@protocol $apiName');
  for (Method func in api.methods) {
    String returnTypeName = func.returnType.val(Language.oc, options.prefix);
    returnTypeName = isNeedBox(func.returnType.value)
        ? returnTypeName
        : '_Nonnull $returnTypeName';
    final String argStatement = func.getArgsTemplate(Language.oc, options.prefix);

    if (func.isAsynchronous) {
      if (func.returnType.isVoid) {
        if (func.arguments.isEmpty) {
          // 入参和返回都是null
          indent.writeln(
              '-(void)${func.name}:(void(^)(FlutterError *_Nullable))completion;');
        } else {
          indent.writeln(
              '-(void)${func.name}:$argStatement completion:(void(^)(FlutterError *_Nullable))completion;');
        }
      } else {
        if (func.arguments.isEmpty) {
          indent.writeln(
              '-(void)${func.name}:(void(^)($returnTypeName _Nullable, FlutterError *_Nullable))completion;');
        } else {
          indent.writeln(
              '-(void)${func.name}:$argStatement completion:(void(^)($returnTypeName _Nullable, FlutterError *_Nullable))completion;');
        }
      }
    } else {
      final String returnType = func.returnType.isVoid ? 'void' : returnTypeName;
      if (func.arguments.isEmpty) {
        indent
            .writeln('-($returnType)${func.name}:(FlutterError *_Nullable )error;');
      } else {
        indent.writeln(
            '-($returnType)${func.name}:$argStatement error:(FlutterError *_Nullable)error;');
      }
    }
  }
  indent.writeln('@end');
  indent.writeln('');
  indent.writeln(
      'extern void ${apiName}Setup(id<FlutterBinaryMessenger> binaryMessenger, id<$apiName> _Nullable api);');
  indent.writeln('');
}

void _writeFlutterApiDeclaration(Indent indent, Api api, ObjcOptions options) {
  final String apiName = _className(options.prefix, api.name);
  indent.writeln('@interface $apiName : NSObject');
  indent.writeln(
      '- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;');
  for (Method func in api.methods) {
    final String returnType =
        _className(options.prefix, func.returnType.val(Language.oc));
    final String callbackType = _callbackForType(func.returnType.value, returnType);
    if (func.arguments.isEmpty) {
      indent.writeln('- (void)${func.name}:($callbackType)completion;');
    } else {
      final String argType = _className(options.prefix, func.arguments[0].type);
      indent.writeln(
          '- (void)${func.name}:($argType*)input completion:($callbackType)completion;');
    }
  }
  indent.writeln('@end');
}

/// Generates the ".h" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateObjcHeader(ObjcOptions options, Root root, StringSink sink) {
  final Indent indent = Indent(sink);
  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.writeln('#import <Foundation/Foundation.h>');
  indent.writeln('@protocol FlutterBinaryMessenger;');
  indent.writeln('@class FlutterError;');
  indent.writeln('@class FlutterStandardTypedData;');
  indent.writeln('');

  indent.writeln('NS_ASSUME_NONNULL_BEGIN');
  indent.writeln('');

  for (Class klass in root.classes) {
    indent.writeln('@class ${_className(options.prefix, klass.name)};');
  }

  indent.writeln('');

  _writeClassDeclarations(indent, root.classes, options.prefix);

  for (Api api in root.apis) {
    if (api.location == ApiLocation.host) {
      _writeHostApiDeclaration(indent, api, options);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApiDeclaration(indent, api, options);
    }
  }

  indent.writeln('NS_ASSUME_NONNULL_END');
}

String _dictGetter(
    List<String> classnames, String dict, Field field, String prefix) {
  if (classnames.contains(field.dataType)) {
    String className = field.dataType;
    if (prefix != null) {
      className = '$prefix$className';
    }
    return '[$className fromMap:$dict[@"${field.name}"]]';
  } else {
    return '$dict[@"${field.name}"]';
  }
}

String _dictValue(List<String> classnames, Field field) {
  if (classnames.contains(field.dataType)) {
    return '(self.${field.name} ? [self.${field.name} toMap] : [NSNull null])';
  } else {
    return '(self.${field.name} ? self.${field.name} : [NSNull null])';
  }
}

void _writeHostApiSource(Indent indent, ObjcOptions options, Api api) {
  assert(api.location == ApiLocation.host);
  final String apiName = _className(options.prefix, api.name);
  indent.write(
      'void ${apiName}Setup(id<FlutterBinaryMessenger> binaryMessenger, id<$apiName> api) ');
  indent.scoped('{', '}', () {
    for (Method func in api.methods) {
      indent.write('');
      indent.scoped('{', '}', () {
        indent.writeln('FlutterBasicMessageChannel *channel =');
        indent.inc();
        indent.writeln('[FlutterBasicMessageChannel');
        indent.inc();
        indent.writeln('messageChannelWithName:@"${makeChannelName(api, func)}"');
        indent.writeln('binaryMessenger:binaryMessenger];');
        indent.dec();
        indent.dec();

        indent.write('if (api) ');
        indent.scoped('{', '}', () {
          indent.write(
              '[channel setMessageHandler:^(id _Nullable message, FlutterReply callback) ');
          indent.scoped('{', '}];', () {
            final String returnType =
                func.returnType.val(Language.oc, options.prefix);

            final List<String> funArgumentNames = <String>[];
            for (int i = 0; i < func.arguments.length; i++) {
              final Argument arg = func.arguments[i];
              if (i == 0) {
                funArgumentNames.add(arg.name);
              } else {
                funArgumentNames.add('${arg.name}:${arg.name}');
              }
            }

            String syncCall;
            if (func.arguments.isEmpty) {
              syncCall = '[api ${func.name}:&error]';
            } else {
              indent.writeln('NSDictionary *json = (NSDictionary *) message;');

              for (Argument arg in func.arguments) {
                if (isNeedBox(arg.type)) {
                  // NSNumber *code = json[@"code"];
                  // int codeInt = [code intvalue];
                  final String typeName = arg.typeTo(Language.oc);
                  indent.writeln('NSNumber *${arg.name} = json[@"${arg.name}"];');
                  indent.writeln('$typeName ${arg.name} = [code ${typeName}Value];');
                } else {
                  // FLTPerson *person = [FLTPerson fromMap:json[@"person"]];
                  final String typeName = _className(options.prefix, arg.type);
                  indent.writeln(
                      '$typeName *${arg.name} = [$typeName fromMap:json[@"${arg.name}"]];');
                }
              }
              syncCall =
                  '[api ${func.name}:${funArgumentNames.join(" ")} error:&error]';
            }
            if (func.isAsynchronous) {
              if (func.returnType.isVoid) {
                const String callback = 'callback(error));';
                if (func.arguments.isEmpty) {
                  indent.writeScoped(
                      '[api ${func.name}:^(FlutterError *_Nullable error) {', '}];',
                      () {
                    indent.writeln(callback);
                  });
                } else {
                  indent.writeScoped(
                      '[api ${func.name}:${funArgumentNames.join(" ")} completion:^(FlutterError *_Nullable error) {',
                      '}];', () {
                    indent.writeln(callback);
                  });
                }
              } else {
                if (func.arguments.isEmpty) {
                  indent.writeScoped(
                      '[api ${func.name}:^($returnType _Nullable output, FlutterError *_Nullable error) {',
                      '}];', () {
                    _writeCallbackStateMement(func, indent);
                  });
                } else {
                  indent.writeScoped(
                      '[api ${func.name}:${funArgumentNames.join(" ")} completion:^($returnType _Nullable output, FlutterError *_Nullable error) {',
                      '}];', () {
                    _writeCallbackStateMement(func, indent);
                  });
                }
              }
            } else {
              indent.writeln('FlutterError *error;');
              if (func.returnType.isVoid) {
                indent.writeln('$syncCall;');
                indent.writeln('callback(wrapResult(nil, error));');
              } else {
                indent.writeln('$returnType output = $syncCall;');
                _writeCallbackStateMement(func, indent);
              }
            }
          });
        });
        indent.write('else ');
        indent.scoped('{', '}', () {
          indent.writeln('[channel setMessageHandler:nil];');
        });
      });
    }
  });
}

void _writeCallbackStateMement(Method func, Indent indent) {
  if (func.returnType.isBasic) {
    if (isNeedBox(func.returnType.value)) {
      indent.writeln(
          'NSNumber *outputObj = [NSNumber ${_boxMethod(func.returnType.value)}:output]');
      indent.writeln('callback(wrapResult(outputObj, error));');
    } else {
      indent.writeln('callback(wrapResult(output, error));');
    }
  } else {
    indent.writeln('callback(wrapResult([output toMap], error));');
  }
}

void _writeFlutterApiSource(Indent indent, ObjcOptions options, Api api) {
  assert(api.location == ApiLocation.flutter);
  final String apiName = _className(options.prefix, api.name);
  indent.writeln('@interface $apiName ()');
  indent.writeln(
      '@property (nonatomic, strong) NSObject<FlutterBinaryMessenger>* binaryMessenger;');
  indent.writeln('@end');
  indent.addln('');
  indent.writeln('@implementation $apiName');
  indent.write(
      '- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger>*)binaryMessenger ');
  indent.scoped('{', '}', () {
    indent.writeln('self = [super init];');
    indent.write('if (self) ');
    indent.scoped('{', '}', () {
      indent.writeln('_binaryMessenger = binaryMessenger;');
    });
    indent.writeln('return self;');
  });
  indent.addln('');
  for (Method func in api.methods) {
    final String returnType =
        _className(options.prefix, func.returnType.val(Language.oc));
    final String callbackType = _callbackForType(func.returnType.value, returnType);

    String sendArgument;
    if (func.arguments.isEmpty) {
      indent.write('- (void)${func.name}:($callbackType)completion ');
      sendArgument = 'nil';
    } else {
      final String argType = _className(options.prefix, func.arguments[0].type);
      indent.write(
          '- (void)${func.name}:($argType*)input completion:($callbackType)completion ');
      sendArgument = 'inputMap';
    }
    indent.scoped('{', '}', () {
      indent.writeln('FlutterBasicMessageChannel *channel =');
      indent.inc();
      indent.writeln('[FlutterBasicMessageChannel');
      indent.inc();
      indent.writeln('messageChannelWithName:@"${makeChannelName(api, func)}"');
      indent.writeln('binaryMessenger:self.binaryMessenger];');
      indent.dec();
      indent.dec();
      if (func.arguments.isEmpty) {
        indent.writeln('NSDictionary* inputMap = [input toMap];');
      }
      indent.write('[channel sendMessage:$sendArgument reply:^(id reply) ');
      indent.scoped('{', '}];', () {
        if (func.returnType.isVoid) {
          indent.writeln('completion(nil);');
        } else {
          indent.writeln('NSDictionary* outputMap = reply;');
          indent.writeln('$returnType * output = [$returnType fromMap:outputMap];');
          indent.writeln('completion(output, nil);');
        }
      });
    });
  }
  indent.writeln('@end');
}

/// Generates the ".m" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateObjcSource(ObjcOptions options, Root root, StringSink sink) {
  final Indent indent = Indent(sink);
  final List<String> classnames = root.classes.map((Class x) => x.name).toList();

  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.writeln('#import "${options.header}"');
  indent.writeln('#import <Flutter/Flutter.h>');
  indent.writeln('');

  indent.writeln('#if !__has_feature(objc_arc)');
  indent.writeln('#error File requires ARC to be enabled.');
  indent.writeln('#endif');
  indent.addln('');

  indent.format(
      '''static NSDictionary<NSString*, id>* wrapResult(NSObject *result, FlutterError *error) {
\tNSDictionary *errorDict = (NSDictionary *)[NSNull null];
\tif (error) {
\t\terrorDict = @{
\t\t\t\t@"${Keys.errorCode}": (error.code ? error.code : [NSNull null]),
\t\t\t\t@"${Keys.errorMessage}": (error.message ? error.message : [NSNull null]),
\t\t\t\t@"${Keys.errorDetails}": (error.details ? error.details : [NSNull null]),
\t\t\t\t};
\t}
\treturn @{
\t\t\t@"${Keys.result}": (result ? result : [NSNull null]),
\t\t\t@"${Keys.error}": errorDict,
\t\t\t};
}''');
  indent.addln('');

  for (Class klass in root.classes) {
    final String className = _className(options.prefix, klass.name);
    indent.writeln('@interface $className ()');
    indent.writeln('+($className*)fromMap:(NSDictionary*)dict;');
    indent.writeln('-(NSDictionary*)toMap;');
    indent.writeln('@end');
  }

  indent.writeln('');

  for (Class klass in root.classes) {
    final String className = _className(options.prefix, klass.name);
    indent.writeln('@implementation $className');
    indent.write('+($className*)fromMap:(NSDictionary*)dict ');
    indent.scoped('{', '}', () {
      const String resultName = 'result';
      indent.writeln('$className* $resultName = [[$className alloc] init];');
      for (Field field in klass.fields) {
        indent.writeln(
            '$resultName.${field.name} = ${_dictGetter(classnames, 'dict', field, options.prefix)};');
        indent.write('if ((NSNull *)$resultName.${field.name} == [NSNull null]) ');
        indent.scoped('{', '}', () {
          indent.writeln('$resultName.${field.name} = nil;');
        });
      }
      indent.writeln('return $resultName;');
    });
    indent.write('-(NSDictionary*)toMap ');
    indent.scoped('{', '}', () {
      indent.write('return [NSDictionary dictionaryWithObjectsAndKeys:');
      for (Field field in klass.fields) {
        indent.add(_dictValue(classnames, field) + ', @"${field.name}", ');
      }
      indent.addln('nil];');
    });
    indent.writeln('@end');
    indent.writeln('');
  }

  for (Api api in root.apis) {
    if (api.location == ApiLocation.host) {
      _writeHostApiSource(indent, options, api);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApiSource(indent, options, api);
    }
  }
}
