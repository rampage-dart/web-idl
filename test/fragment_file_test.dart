// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:path/path.dart';
import 'package:test/test.dart';

import 'package:web_idl/web_idl.dart';

import 'utilities.dart';

Future<void> main() async {
  final webIdlSpecs = await findTests('test/web_idl_spec').toList();

  group('spec idls', () {
    final parser = WebIdlGrammar();

    for (final file in webIdlSpecs) {
      test(basenameWithoutExtension(file.path), () async {
        final contents = await file.readAsString();
        expect(contents, accept(parser));
      });
    }
  });
}
