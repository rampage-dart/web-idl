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

part 'maplike.g.dart';

/// A data field with a given type and identifier whose value can be retrieved
/// and (in some cases) changed.
@immutable
abstract class Maplike
    implements Built<Maplike, MaplikeBuilder>, Spec, ReadOnlySpec {
  factory Maplike([void Function(MaplikeBuilder)? updates]) = _$Maplike;
  const Maplike._();

  static Serializer<Maplike> get serializer => _$maplikeSerializer;

  /// The key type used.
  WebIdlType get keyType;

  /// The value type contained.
  WebIdlType get valueType;
}
