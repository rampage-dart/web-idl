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

part 'type_alias.g.dart';

/// A definition used to declare a new name for a type.
///
/// This new name is not exposed by language bindings; it is purely used as a
/// shorthand for referencing the type in the IDL.
@immutable
abstract class TypeAlias
    implements
        Built<TypeAlias, TypeAliasBuilder>,
        Spec,
        NamedSpec,
        TypedSpec<WebIdlType> {
  /// Create an [TypeAlias] based on result of a call to [updates].
  factory TypeAlias([void Function(TypeAliasBuilder)? updates]) = _$TypeAlias;
  const TypeAlias._();

  static Serializer<TypeAlias> get serializer => _$typeAliasSerializer;
}
