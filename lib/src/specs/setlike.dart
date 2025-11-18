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

part 'setlike.g.dart';

/// A data field with a given type and identifier whose value can be retrieved
/// and (in some cases) changed.
@immutable
abstract class Setlike
    implements Built<Setlike, SetlikeBuilder>, Spec, ReadOnlySpec {
  factory Setlike([void Function(SetlikeBuilder)? updates]) = _$Setlike;
  const Setlike._();

  static Serializer<Setlike> get serializer => _$setlikeSerializer;

  /// The value type contained.
  WebIdlType get valueType;
}
