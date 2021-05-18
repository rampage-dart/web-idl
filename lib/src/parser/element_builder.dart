// Copyright (c) 2020 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:meta/meta.dart';

import '../element.dart';
import '../type.dart';
import 'type_builder.dart';

/// Builds an immutable [Element].
abstract class ElementBuilder<T extends Element> {
  /// The name of the [Element].
  String name = '';

  /// Annotations that control how language bindings will handle the element.
  List<Object> extendedAttributes = <Object>[];

  /// Returns the [Element] specified by the builder.
  ///
  /// The builder returns an immutable representation of [T].
  T build();
}

@immutable
class _Element implements Element {
  _Element({
    required this.name,
    required Iterable<Object> extendedAttributes,
  }) : extendedAttributes = List<Object>.unmodifiable(extendedAttributes);

  @override
  final String name;

  @override
  final List<Object> extendedAttributes;
}

//------------------------------------------------------------------
// WebIDL definition elements
//------------------------------------------------------------------

/// Builds an immutable [FragmentElement].
class FragmentBuilder extends ElementBuilder<FragmentElement> {
  /// The [EnumElement]s defined within the [FragmentElement].
  List<EnumBuilder> enumerations = <EnumBuilder>[];

  @override
  FragmentElement build() => _FragmentElement(
        name: name,
        extendedAttributes: extendedAttributes,
        enumerations: enumerations.map((b) => b.build()),
      );
}

@immutable
class _FragmentElement extends _Element implements FragmentElement {
  _FragmentElement({
    required String name,
    required Iterable<Object> extendedAttributes,
    required Iterable<EnumElement> enumerations,
  })  : enumerations = List.unmodifiable(enumerations),
        super(name: name, extendedAttributes: extendedAttributes);

  @override
  final List<EnumElement> enumerations;
}

/// Builds an immutable [DictionaryElement].
class DictionaryBuilder extends ElementBuilder<DictionaryElement> {
  /// The type of the inherited dictionary, or `null` if there is none.
  SingleTypeBuilder? supertype;

  /// The set of entries in the dictionary.
  List<DictionaryMemberBuilder> members = <DictionaryMemberBuilder>[];

  @override
  DictionaryElement build() => _DictionaryElement(
        name: name,
        extendedAttributes: extendedAttributes,
        supertype: supertype?.build(),
        members: members.map((b) => b.build()),
      );
}

@immutable
class _DictionaryElement extends _Element implements DictionaryElement {
  _DictionaryElement({
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.supertype,
    required Iterable<DictionaryMemberElement> members,
  })  : members = List.unmodifiable(members),
        super(name: name, extendedAttributes: extendedAttributes);

  @override
  final SingleType? supertype;

  @override
  final List<DictionaryMemberElement> members;
}

/// Builds an immutable [EnumElement].
class EnumBuilder extends ElementBuilder<EnumElement> {
  /// The set of valid strings for the [EnumElement].
  List<String> values = <String>[];

  @override
  EnumElement build() => _EnumElement(
        name: name,
        extendedAttributes: extendedAttributes,
        values: values,
      );
}

@immutable
class _EnumElement extends _Element implements EnumElement {
  _EnumElement({
    required String name,
    required Iterable<Object> extendedAttributes,
    required Iterable<String> values,
  })  : values = List.unmodifiable(values),
        super(name: name, extendedAttributes: extendedAttributes);

  @override
  final List<String> values;
}

/// Builds an immutable [NamespaceElement].
class NamespaceBuilder extends ElementBuilder<NamespaceElement> {
  /// The attributes contained in the namespace.
  List<AttributeBuilder> attributes = <AttributeBuilder>[];

  /// The operations contained in the namespace.
  List<OperationBuilder> operations = <OperationBuilder>[];

  /// The constants defined in the namespace.
  List<ConstantBuilder> constants = <ConstantBuilder>[];

  @override
  NamespaceElement build() => _NamespaceElement(
        name: name,
        extendedAttributes: extendedAttributes,
        attributes: attributes.map((b) => b.build()),
        operations: operations.map((b) => b.build()),
        constants: constants.map((b) => b.build()),
      );
}

class _NamespaceElement extends _Element implements NamespaceElement {
  _NamespaceElement({
    required String name,
    required Iterable<Object> extendedAttributes,
    required Iterable<AttributeElement> attributes,
    required Iterable<OperationElement> operations,
    required Iterable<ConstantElement> constants,
  })  : attributes = List.unmodifiable(attributes),
        operations = List.unmodifiable(operations),
        constants = List.unmodifiable(constants),
        super(name: name, extendedAttributes: extendedAttributes);

  @override
  final List<AttributeElement> attributes;

  @override
  final List<OperationElement> operations;

  @override
  final List<ConstantElement> constants;
}

/// Builds an immutable [TypeAliasElement].
class TypeAliasBuilder extends ElementBuilder<TypeAliasElement> {
  /// The type being aliased.
  WebIdlTypeBuilder type = SingleTypeBuilder();

  @override
  TypeAliasElement build() => _TypeAliasElement(
        name: name,
        extendedAttributes: extendedAttributes,
        type: type.build(),
      );
}

@immutable
class _TypeAliasElement extends _Element implements TypeAliasElement {
  _TypeAliasElement({
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.type,
  }) : super(name: name, extendedAttributes: extendedAttributes);

  @override
  final WebIdlType type;
}

//------------------------------------------------------------------
// WebIDL member elements
//------------------------------------------------------------------

/// Builds an immutable [ArgumentElement].
class ArgumentBuilder extends ElementBuilder<ArgumentElement> {
  /// The type for the argument.
  WebIdlTypeBuilder type = SingleTypeBuilder();

  /// Whether the argument is optional.
  bool isOptional = false;

  /// Whether the argument is variadic.
  bool isVariadic = false;

  /// The value the argument defaults to.
  Object? defaultTo;

  @override
  ArgumentElement build() => _ArgumentElement(
        name: name,
        extendedAttributes: extendedAttributes,
        type: type.build(),
        isOptional: isOptional,
        isVariadic: isVariadic,
        defaultTo: defaultTo,
      );
}

@immutable
class _ArgumentElement extends _Element implements ArgumentElement {
  _ArgumentElement({
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.type,
    required this.isOptional,
    required this.isVariadic,
    required this.defaultTo,
  }) : super(name: name, extendedAttributes: extendedAttributes);

  @override
  final WebIdlType type;

  @override
  final bool isOptional;

  @override
  final bool isVariadic;

  @override
  final Object? defaultTo;
}

/// Builds an immutable [AttributeElement].
class AttributeBuilder extends ElementBuilder<AttributeElement> {
  /// The type for the attribute.
  WebIdlTypeBuilder type = SingleTypeBuilder();

  /// Whether the attribute is read only.
  bool readOnly = false;

  @override
  AttributeElement build() => _AttributeElement(
        name: name,
        extendedAttributes: extendedAttributes,
        type: type.build(),
        readOnly: readOnly,
      );
}

@immutable
class _AttributeElement extends _Element implements AttributeElement {
  _AttributeElement({
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.type,
    required this.readOnly,
  }) : super(name: name, extendedAttributes: extendedAttributes);

  @override
  final WebIdlType type;

  @override
  final bool readOnly;
}

/// Builds an immutable [ConstantElement].
class ConstantBuilder extends ElementBuilder<ConstantElement> {
  /// The type for the constant.
  ///
  /// The type is limited primitive types (boolean, floating point or integer),
  /// and their type aliases.
  SingleTypeBuilder type = SingleTypeBuilder();

  /// The constant's value.
  ///
  /// The value will be a boolean, a floating point number or an integer.
  Object value = 0;

  @override
  ConstantElement build() => _ConstantElement(
        name: name,
        extendedAttributes: extendedAttributes,
        type: type.build(),
        value: value,
      );
}

@immutable
class _ConstantElement extends _Element implements ConstantElement {
  _ConstantElement({
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.type,
    required this.value,
  }) : super(name: name, extendedAttributes: extendedAttributes);

  @override
  final SingleType type;

  @override
  final Object value;
}

/// Builds an immutable [DictionaryMemberElement].
class DictionaryMemberBuilder extends ElementBuilder<DictionaryMemberElement> {
  /// The type for the field.
  WebIdlTypeBuilder type = SingleTypeBuilder();

  /// Whether setting the field is required.
  bool isRequired = false;

  /// The default value for the argument.
  ///
  /// If the argument [isRequired] then this will be `null`. Otherwise this may
  /// be a constant.
  Object? defaultTo;

  @override
  DictionaryMemberElement build() => _DictionaryMemberElement(
        name: name,
        extendedAttributes: extendedAttributes,
        type: type.build(),
        isRequired: isRequired,
        defaultTo: defaultTo,
      );
}

class _DictionaryMemberElement extends _Element
    implements DictionaryMemberElement {
  _DictionaryMemberElement({
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.type,
    required this.isRequired,
    required this.defaultTo,
  }) : super(name: name, extendedAttributes: extendedAttributes);

  @override
  final WebIdlType type;

  @override
  final bool isRequired;

  @override
  final Object? defaultTo;
}

/// Builds an immutable [OperationElement].
class OperationBuilder extends ElementBuilder<OperationElement> {
  /// The return type for the operation.
  WebIdlTypeBuilder returnType = SingleTypeBuilder();

  /// The [SpecialOperation] type; if applicable.
  SpecialOperation? operationType;

  /// The arguments for the operation.
  List<ArgumentBuilder> arguments = <ArgumentBuilder>[];

  @override
  OperationElement build() => _OperationElement(
        name: name,
        extendedAttributes: extendedAttributes,
        returnType: returnType.build(),
        operationType: operationType,
        arguments: arguments.map((b) => b.build()),
      );
}

@immutable
class _OperationElement extends _Element implements OperationElement {
  _OperationElement({
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.returnType,
    required this.operationType,
    required Iterable<ArgumentElement> arguments,
  })  : arguments = List.unmodifiable(arguments),
        super(name: name, extendedAttributes: extendedAttributes);

  @override
  final WebIdlType returnType;

  @override
  final SpecialOperation? operationType;

  @override
  final List<ArgumentElement> arguments;
}
