// Copyright (c) 2019 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'src/element.dart';
import 'src/parser/element_builder.dart';
import 'src/parser/parser.dart';

export 'src/element.dart';
export 'src/type.dart';
export 'src/types.dart';
export 'src/visitor.dart';

/// Parse the fragment defined in the [value].
///
/// This is a way to quickly parse a single fragment.
FragmentElement parseFragment(String value) =>
    _parser.parse(value).value.build();

late final _parser = WebIdlParserDefinition().build<FragmentBuilder>();
