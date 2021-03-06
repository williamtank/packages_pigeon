// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeonv2/generator_tools.dart';

/// Enum that represents where an [Api] is located, on the host or Flutter.
enum ApiLocation {
  /// The API is for calling functions defined on the host.
  host,

  /// The API is for calling functions defined in Flutter.
  flutter,
}

///
enum Language {
  /// value of dart
  dart,

  /// value of java
  java,

  /// value of Object-C
  oc
}

/// Superclass for all AST nodes.
class Node {}

/// Basic Type
class BasicType {
  /// constructor
  const BasicType({this.dart, this.java, this.oc});

  /// value of dart
  final String dart;

  /// value of java
  final String java;

  /// value of Object-C
  final String oc;

  // String kotlin;
  // String swift;

  /// toString by lanague
  String dartTo(Language lan) {
    switch (lan) {
      case Language.dart:
        return dart;
      case Language.java:
        return java;
      case Language.oc:
        return oc;
      default:
        return dart;
    }
  }
}

/// Basic Type
const List<BasicType> _basicTypes = <BasicType>[
  BasicType(dart: 'bool', java: 'boolean', oc: 'BOOL'),
  BasicType(dart: 'int', java: 'int', oc: 'int'),
  BasicType(dart: 'double', java: 'Double', oc: 'double'),
  BasicType(dart: 'String', java: 'String', oc: 'NSString *'),
  BasicType(dart: 'Uint8List', java: 'byte[]', oc: 'FlutterStandardTypedData *'),
  BasicType(dart: 'Int32List', java: 'int[]', oc: 'FlutterStandardTypedData *'),
  BasicType(dart: 'Int64List', java: 'long[]', oc: 'FlutterStandardTypedData *'),
  BasicType(dart: 'Float64List', java: 'double[]', oc: 'FlutterStandardTypedData *'),
  BasicType(dart: 'List', java: 'ArrayList', oc: 'NSArray *'),
  BasicType(dart: 'Map', java: 'HashMap', oc: 'NSDictionary *'),
];

/// for Method return Type
class ReturnType {
  /// constructor
  ReturnType(this.value);

  /// value of dart
  String value;

  /// is basic data type
  bool get isBasic => isBasicTypeStr(value);

  /// is void
  bool get isVoid => value == 'void';

  /// is not void
  bool get isNotVoid => value != 'void';

  ///from dart to java/oc
  String val(Language lan, [String prefix]) {
    if (isBasic) {
      return _basicTypes.where((BasicType t) => t.dart == value).first.dartTo(lan);
    } else if (lan == Language.java && isVoid) {
      return 'Void';
    } else {
      return lan == Language.oc ? '$prefix$value *' : value;
    }
  }

  @override
  String toString() => value;
}

/// for Method Argument
class Argument {
  /// constructor
  Argument({this.type, this.name});

  /// type of arguement
  String type;

  /// name of arguement
  String name;

  /// is basic data type
  bool get isBasic => isBasicTypeStr(type);

  /// Type to String from dart to java/oc
  String typeTo(Language lan, [String prefix]) {
    if (isBasic) {
      return _basicTypes.where((BasicType t) => t.dart == type).first.dartTo(lan);
    } else {
      return lan == Language.oc ? '$prefix$type *' : type;
    }
  }

  /// value of template
  String toTmpl(Language lan, [String prefix]) {
    if (lan == Language.oc) {
      final String nullableStr = isNeedBox(type) ? '' : '_Nonnull';
      return '($nullableStr ${typeTo(lan, prefix)})$name';
    } else {
      return '${typeTo(lan)} $name';
    }
  }
}

/// Represents a method on an [Api].
class Method extends Node {
  /// Parametric constructor for [Method].
  Method({this.name, this.returnType, this.arguments, this.isAsynchronous = false});

  /// The name of the method.
  String name;

  /// The data-type of the return value.
  ReturnType returnType; //替换为的自定义Class

  /// The data-type of the argument.
  List<Argument> arguments = <Argument>[];

  /// Whether the receiver of this method is expected to return synchronously or not.
  bool isAsynchronous;

  /// Helper Method for argments to template
  String getArgsTemplate([Language lan, String prefix]) {
    final List<String> tmpl = <String>[];

    if (arguments.isNotEmpty) {
      if (lan == Language.oc) {
        tmpl.add(arguments[0].toTmpl(Language.oc, prefix));

        for (int i = 1; i < arguments.length; i++) {
          final Argument arg = arguments[i];
          tmpl.add(arg.name + ':' + arg.toTmpl(Language.oc, prefix));
        }

        return tmpl.join(' ');
      } else {
        for (Argument arg in arguments) {
          tmpl.add(arg.toTmpl(lan ?? Language.dart));
        }
        return tmpl.join(', ');
      }
    }
    return '';
  }
}

/// Represents a collection of [Method]s that are hosted on a given [location].
class Api extends Node {
  /// Parametric constructor for [Api].
  Api({this.name, this.location, this.methods, this.dartHostTestHandler});

  /// The name of the API.
  String name;

  /// Where the API's implementation is located, host or Flutter.
  ApiLocation location;

  /// List of methods inside the API.
  List<Method> methods;

  /// The name of the Dart test interface to generate to help with testing.
  String dartHostTestHandler;
}

/// Represents a field on a [Class].
class Field extends Node {
  /// Parametric constructor for [Field].
  Field({this.name, this.dataType});

  /// The name of the field.
  String name;

  /// The data-type of the field (ex 'String' or 'int').
  String dataType;

  @override
  String toString() {
    return '(Field name:$name)';
  }
}

/// Represents a class with [Field]s.
class Class extends Node {
  /// Parametric constructor for [Class].
  Class({this.name, this.fields});

  /// The name of the class.
  String name;

  /// All the fields contained in the class.
  List<Field> fields;

  @override
  String toString() {
    return '(Class name:$name fields:$fields)';
  }
}

/// Top-level node for the AST.
class Root extends Node {
  /// Parametric constructor for [Root].
  Root({this.classes, this.apis});

  /// All the classes contained in the AST.
  List<Class> classes;

  /// All the API's contained in the AST.
  List<Api> apis;

  @override
  String toString() {
    return '(Root classes:$classes apis:$apis)';
  }
}
