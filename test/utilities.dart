// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'dart:io';

import 'package:petitparser/petitparser.dart';

typedef ParserTestFunction = bool Function(String input);

ParserTestFunction accept(Parser<Object?> parser) =>
    (input) => parser.parse(input) is Success;

ParserTestFunction reject(Parser<Object?> parser) =>
    (input) => parser.parse(input) is Failure;

Stream<File> findTests(
  String path, {
  bool recursive = false,
  bool followLinks = false,
  bool Function(FileSystemEntity)? isTest,
}) {
  final directory = Directory(path);

  if (!directory.existsSync()) {
    throw ArgumentError.value(path, 'path does not exist');
  }

  isTest ??= _isTest;
  return directory
      .list(recursive: recursive, followLinks: followLinks)
      .where(isTest)
      .cast<File>();
}

bool _isTest(FileSystemEntity entity) {
  if (entity is! File) {
    return false;
  }

  return entity.path.endsWith('.idl');
}
