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

part 'include.g.dart';

/// A definition specifying the usage of a mixin.
@immutable
abstract class Include implements Built<Include, IncludeBuilder>, Spec {
  factory Include([void Function(IncludeBuilder)? updates]) = _$Include;
  const Include._();

  static Serializer<Include> get serializer => _$includeSerializer;

  /// The type the mixin is applied to.
  SingleType get on;

  /// The type being mixed in.
  SingleType get mixin;
}
