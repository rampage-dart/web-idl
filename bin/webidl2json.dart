// Copyright (c) 2024 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'dart:convert';

import 'package:web_idl/web_idl.dart';

import 'convert.dart';
import 'testidl.dart';

Future<void> main() async {
  final convertor = WebIdlToJson();
  const encoder = JsonEncoder.withIndent('  ');
  final fragment = parseFragment(idlExample);
  final converted = convertor.visitFragment(fragment);

  final formatted = encoder.convert(converted);
  print(formatted);
}
