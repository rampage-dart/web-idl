// Copyright (c) 2025 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

import 'argument.dart';
import 'specs.dart';
import 'type_system.dart';

part 'function_type_alias.g.dart';

/// A definition used to declare a function type.
@immutable
abstract class FunctionTypeAlias
    implements
        Built<FunctionTypeAlias, FunctionTypeAliasBuilder>,
        Spec,
        NamedSpec,
        FunctionTypedSpec {
  factory FunctionTypeAlias([
    void Function(FunctionTypeAliasBuilder)? updates,
  ]) = _$FunctionTypeAlias;
  const FunctionTypeAlias._();

  static Serializer<FunctionTypeAlias> get serializer =>
      _$functionTypeAliasSerializer;
}
