// Copyright (c) 2025 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

import 'dictionary.dart';
import 'enum.dart';
import 'include.dart';
import 'interface.dart';
import 'namespace.dart';
import 'specs.dart';
import 'type_alias.dart';

part 'fragment.g.dart';

/// Contains a group of [Spec] definitions.
@immutable
abstract class Fragment implements Built<Fragment, FragmentBuilder>, Spec {
  factory Fragment([void Function(FragmentBuilder)? updates]) = _$Fragment;
  const Fragment._();

  static Serializer<Fragment> get serializer => _$fragmentSerializer;

  /// The dictionaries defined within the WebIDL fragment.
  BuiltList<Dictionary> get dictionaries;

  /// The enumerations defined within the WebIDL fragment.
  BuiltList<Enum> get enumerations;

  /// The function definitions within the WebIDL fragment.
  BuiltList<Fragment> get functions;

  /// The includes defined within the WebIDL fragment.
  BuiltList<Include> get includes;

  /// The interfaces defined within the WebIDL fragment.
  BuiltList<Interface> get interfaces;

  /// The namespaces defined within the WebIDL fragment.
  BuiltList<Namespace> get namespaces;

  /// The type definitions within the WebIDL fragment.
  BuiltList<TypeAlias> get typeDefinitions;
}
