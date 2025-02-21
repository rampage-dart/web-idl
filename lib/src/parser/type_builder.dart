// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import '../element.dart';
import '../type.dart';
import 'context.dart';

/// Builds a [WebIdlType].
abstract class WebIdlTypeBuilder<T extends WebIdlType> {
  /// Annotations that control how language bindings will handle the type.
  List<Object> extendedAttributes = <Object>[];

  /// Whether the type is nullable.
  bool isNullable = false;

  /// Builds the [WebIdlType].
  T build(WebIdlContext context);
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
  UnionType build(WebIdlContext context) => _UnionType(
    extendedAttributes: extendedAttributes,
    isNullable: isNullable,
    memberTypes: memberTypes.map((builder) => builder.build(context)),
  );
}

class _UnionType extends _WebIdlType implements UnionType {
  _UnionType({
    required super.extendedAttributes,
    required super.isNullable,
    required Iterable<WebIdlType> memberTypes,
  }) : memberTypes = List<WebIdlType>.unmodifiable(memberTypes);

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
  SingleType build(WebIdlContext context) => _SingleType(
    context: context,
    extendedAttributes: extendedAttributes,
    isNullable: isNullable,
    name: name,
    typeArguments: typeArguments.map((builder) => builder.build(context)),
  );
}

class _SingleType extends _WebIdlType implements SingleType {
  _SingleType({
    required this.context,
    required super.extendedAttributes,
    required super.isNullable,
    required this.name,
    required Iterable<WebIdlType> typeArguments,
  }) : typeArguments = List<WebIdlType>.unmodifiable(typeArguments);

  final WebIdlContext context;

  @override
  final String name;

  @override
  final List<WebIdlType> typeArguments;

  @override
  late final Element element = context.lookup(name)!;
}
