// Copyright (c) 2025 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

import 'specs.dart';
import 'type_system.dart';

part 'constant.g.dart';

/// A declaration used to bind a constant value to a name.
@immutable
abstract class Constant
    implements
        Built<Constant, ConstantBuilder>,
        Spec,
        NamedSpec,
        TypedSpec<WebIdlType> {
  /// Create a [Constant] based on result of a call to [updates].
  factory Constant([void Function(ConstantBuilder)? updates]) = _$Constant;
  const Constant._();

  static Serializer<Constant> get serializer => _$constantSerializer;

  /// The constant's value.
  ///
  /// The value will be a boolean, a floating point number or an integer.
  Object get value;
}
