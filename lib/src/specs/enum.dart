// Copyright (c) 2025 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

import 'specs.dart';

part 'enum.g.dart';

/// A type whose valid [values] are a set of predefined strings.
///
/// Enumerations can be used to restrict the possible string values that can be
/// assigned to an attribute or passed to an operation.
@immutable
abstract class Enum implements Built<Enum, EnumBuilder>, Spec, NamedSpec {
  factory Enum([void Function(EnumBuilder)? updates]) = _$Enum;
  const Enum._();

  static Serializer<Enum> get serializer => _$enumSerializer;

  /// The set of valid strings for the enumeration.
  BuiltSet<String> get values;
}
