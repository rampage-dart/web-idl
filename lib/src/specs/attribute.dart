// Copyright (c) 2025 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

import 'specs.dart';
import 'type_system.dart';

part 'attribute.g.dart';

/// A data field with a given type and identifier whose value can be retrieved
/// and (in some cases) changed.
@immutable
abstract class Attribute
    implements
        Built<Attribute, AttributeBuilder>,
        Spec,
        NamedSpec,
        TypedSpec<WebIdlType>,
        StaticSpec {
  factory Attribute([void Function(AttributeBuilder)? updates]) = _$Attribute;
  const Attribute._();

  static Serializer<Attribute> get serializer => _$attributeSerializer;

  @override
  WebIdlType get type;

  /// Whether the attribute is a stringifier.
  bool get isStringifier;

  /// Whether the attribute is read only.
  bool get readOnly;
}
