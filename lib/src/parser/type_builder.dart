// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import '../type.dart';

/// Builds a [WebIdlType].
abstract class WebIdlTypeBuilder<T extends WebIdlType> {
  /// Annotations that control how language bindings will handle the type.
  List<Object> extendedAttributes = <Object>[];

  /// Whether the type is nullable.
  bool isNullable = false;

  /// Builds the [WebIdlType].
  T build();
}

class _WebIdlType implements WebIdlType {
  _WebIdlType({
    required Iterable<Object> extendedAttributes,
    required this.isNullable,
  }) : extendedAttributes = List<Object>.unmodifiable(extendedAttributes);

  @override
  final List<Object> extendedAttributes;

  @override
  final bool isNullable;
}

/// Builds a [UnionType].
class UnionTypeBuilder extends WebIdlTypeBuilder<UnionType> {
  /// The [WebIdlType]s that make up the [UnionType].
  List<WebIdlTypeBuilder> memberTypes = <WebIdlTypeBuilder>[];

  @override
  UnionType build() => _UnionType(
        extendedAttributes: extendedAttributes,
        isNullable: isNullable,
        memberTypes: memberTypes.map((builder) => builder.build()),
      );
}

class _UnionType extends _WebIdlType implements UnionType {
  _UnionType({
    required Iterable<Object> extendedAttributes,
    required bool isNullable,
    required Iterable<WebIdlType> memberTypes,
  })  : memberTypes = List<WebIdlType>.unmodifiable(memberTypes),
        super(
          extendedAttributes: extendedAttributes,
          isNullable: isNullable,
        );

  @override
  final List<WebIdlType> memberTypes;
}

/// Builds a [SingleType].
class SingleTypeBuilder extends WebIdlTypeBuilder<SingleType> {
  /// The name of the type.
  String name = '';

  /// The arguments for the type.
  List<WebIdlTypeBuilder> typeArguments = <WebIdlTypeBuilder>[];

  @override
  SingleType build() => _SingleType(
        extendedAttributes: extendedAttributes,
        isNullable: isNullable,
        name: name,
        typeArguments: typeArguments.map((builder) => builder.build()),
      );
}

class _SingleType extends _WebIdlType implements SingleType {
  _SingleType({
    required Iterable<Object> extendedAttributes,
    required bool isNullable,
    required this.name,
    required Iterable<WebIdlType> typeArguments,
  })  : typeArguments = List<WebIdlType>.unmodifiable(typeArguments),
        super(
          extendedAttributes: extendedAttributes,
          isNullable: isNullable,
        );

  @override
  final String name;

  @override
  final List<WebIdlType> typeArguments;
}
