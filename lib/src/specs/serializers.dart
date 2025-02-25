// Copyright (c) 2025 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

import 'argument.dart';
import 'attribute.dart';
import 'constant.dart';
import 'dictionary.dart';
import 'enum.dart';
import 'fragment.dart';
import 'function_type_alias.dart';
import 'include.dart';
import 'interface.dart';
import 'namespace.dart';
import 'operation.dart';
import 'type_alias.dart';
import 'type_system.dart';

part 'serializers.g.dart';

/// Collection of generated serializers for the WebIdl specification.
@SerializersFor([
  Argument,
  Attribute,
  Constant,
  Dictionary,
  DictionaryMember,
  Enum,
  Fragment,
  FunctionTypeAlias,
  Include,
  Interface,
  Namespace,
  Operation,
  TypeAlias,
  SingleType,
  UnionType,
])
final Serializers serializers = _$serializers;
