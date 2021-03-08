// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeonv2/pigeon.dart';

class Value {
  int number;
}

@HostApi()
abstract class Api2Host {
  @async
  Value calculate(Value value);
}

@FlutterApi()
abstract class Api2Flutter {
  @async
  Value calculate(Value value);
}
