// Copyright (c) 2025 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

import 'builtin_types.dart' as builtin;
import 'specs.dart';

part 'type_system.g.dart';

/// Represents a type defined in the WebIDL specification.
@immutable
abstract class WebIdlType implements Spec {
  /// Whether the type is nullable.
  bool get isNullable;
}

/// A [WebIdlType] whose set of values is the union of those in two or more
/// other [WebIdlType]s.
@immutable
abstract class UnionType
    implements Built<UnionType, UnionTypeBuilder>, WebIdlType {
  /// Create a [UnionType] based on result of a call to [updates].
  factory UnionType([void Function(UnionTypeBuilder)? updates]) = _$UnionType;
  const UnionType._();

  static Serializer<UnionType> get serializer => _$unionTypeSerializer;

  /// The [WebIdlType]s that make up the [UnionType].
  BuiltList<WebIdlType> get memberTypes;
}

/// A [WebIdlType] representing a singular type.
@immutable
abstract class SingleType
    implements Built<SingleType, SingleTypeBuilder>, WebIdlType, NamedSpec {
  /// Create a [SingleType] based on result of a call to [updates].
  factory SingleType([void Function(SingleTypeBuilder)? updates]) =
      _$SingleType;
  const SingleType._();

  static Serializer<SingleType> get serializer => _$singleTypeSerializer;

  factory SingleType.any() => _any;
  factory SingleType.undefined() => _undefined;

  /// The arguments for the type.
  BuiltList<WebIdlType> get typeArguments;

  static final _any = SingleType((b) => b..name = builtin.any);
  static final _undefined = SingleType((b) => b..name = builtin.undefined);
}
