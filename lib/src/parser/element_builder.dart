// Copyright (c) 2020 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:meta/meta.dart';

import '../element.dart';
import '../type.dart';
import 'context.dart';
import 'type_builder.dart';

/// Builds an immutable [Element].
abstract class ElementBuilder<T extends Element> {
  /// Create an instance of [ElementBuilder] using the [context].
  ElementBuilder(this.context);

  /// The context for the builder.
  final WebIdlContext context;

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
    required this.context,
    required this.name,
    required Iterable<Object> extendedAttributes,
  }) : extendedAttributes = List<Object>.unmodifiable(extendedAttributes);

  final WebIdlContext context;

  @override
  final String name;

  @override
  final List<Object> extendedAttributes;

  @override
  late final Element? enclosingElement;

  @protected
  void enclose(Element element) {
    (element as _Element).enclosingElement = this;
  }

  @protected
  void encloseAll(Iterable<Element> elements) {
    elements.forEach(enclose);
  }
}

/// Builds a [PartiallyDefinedElement].
mixin PartiallyDefinedElementBuilder<T extends PartiallyDefinedElement>
    implements ElementBuilder<T> {
  /// Whether the [Element] being built is a partial definition.
  bool isPartial = false;
}

/// Builds a [FunctionTypedElement].
mixin FunctionTypedElementBuilder<T extends Element>
    implements ElementBuilder<T> {
  /// The return type for the operation.
  WebIdlTypeBuilder returnType = SingleTypeBuilder();

  /// The arguments for the operation.
  List<ArgumentBuilder> arguments = <ArgumentBuilder>[];
}

/// Helpers for [List]s of [ElementBuilder]s.
extension ElementBuilderList<T extends Element> on List<ElementBuilder<T>> {
  /// Iterates through the [List] calling [ElementBuilder.build] on each item.
  Iterable<T> build() => map((b) => b.build());

  /// Builds an unmodifiable [List] from the built [Element]s.
  List<T> buildList() => List.unmodifiable(build());
}

mixin _TypeDefiningElement on _Element implements TypeDefiningElement {
  @override
  late final SingleType thisType = instantiate();

  SingleType instantiate({
    Iterable<Object> extendedAttributes = const Iterable.empty(),
    bool isNullable = false,
    Iterable<WebIdlType> typeArguments = const Iterable.empty(),
  }) =>
      _SingleType(
        element: this,
        extendedAttributes: extendedAttributes,
        isNullable: isNullable,
        typeArguments: typeArguments,
      );
}

class _SingleType implements SingleType {
  _SingleType({
    required this.element,
    required Iterable<Object> extendedAttributes,
    required this.isNullable,
    required Iterable<WebIdlType> typeArguments,
  })  : typeArguments = List<WebIdlType>.unmodifiable(typeArguments),
        extendedAttributes = List<Object>.unmodifiable(extendedAttributes);

  @override
  final List<Object> extendedAttributes;

  @override
  final bool isNullable;

  @override
  String get name => element.name;

  @override
  final List<WebIdlType> typeArguments;

  final Element element;
}

//------------------------------------------------------------------
// WebIDL definition elements
//------------------------------------------------------------------

/// Builds an immutable [FragmentElement].
class FragmentBuilder extends ElementBuilder<FragmentElement> {
  /// Create an instance of [FragmentBuilder] with the context.
  FragmentBuilder(WebIdlContext context) : super(context);

  /// The [EnumElement]s defined within the [FragmentElement].
  List<EnumBuilder> enumerations = <EnumBuilder>[];

  @override
  FragmentElement build() => _FragmentElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        enumerations: enumerations.buildList(),
      );
}

@immutable
class _FragmentElement extends _Element implements FragmentElement {
  _FragmentElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.enumerations,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        ) {
    encloseAll(enumerations);
  }

  @override
  final List<EnumElement> enumerations;
}

/// Builds an immutable [DictionaryElement].
class DictionaryBuilder extends ElementBuilder<DictionaryElement>
    with PartiallyDefinedElementBuilder<DictionaryElement> {
  /// Create an instance of [DictionaryBuilder] with the context.
  DictionaryBuilder(WebIdlContext context) : super(context);

  /// The type of the inherited dictionary, or `null` if there is none.
  SingleTypeBuilder? supertype;

  /// The set of entries in the dictionary.
  List<DictionaryMemberBuilder> members = <DictionaryMemberBuilder>[];

  @override
  DictionaryElement build() => _DictionaryElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        isPartial: isPartial,
        supertype: supertype?.build(),
        members: members.buildList(),
      );
}

@immutable
class _DictionaryElement extends _Element
    with _TypeDefiningElement
    implements DictionaryElement {
  _DictionaryElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.isPartial,
    required this.supertype,
    required this.members,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        ) {
    encloseAll(members);
  }

  @override
  final bool isPartial;

  @override
  DictionaryElement get definition => context.lookupDictionary(name)!;

  @override
  Iterable<DictionaryElement> get completeDefinition =>
      context.lookupDictionaryDefinitions(name);

  @override
  final SingleType? supertype;

  @override
  final List<DictionaryMemberElement> members;
}

/// Builds an immutable [EnumElement].
class EnumBuilder extends ElementBuilder<EnumElement> {
  /// Create an instance of [EnumBuilder] with the context.
  EnumBuilder(WebIdlContext context) : super(context);

  /// The set of valid strings for the [EnumElement].
  List<String> values = <String>[];

  @override
  EnumElement build() => _EnumElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        values: values,
      );
}

@immutable
class _EnumElement extends _Element
    with _TypeDefiningElement
    implements EnumElement {
  _EnumElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required Iterable<String> values,
  })  : values = List.unmodifiable(values),
        super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        ) {
    context.registerEnumeration(this);
  }

  @override
  final List<String> values;
}

/// Builds an immutable [FunctionTypeAliasElement].
class FunctionTypeAliasBuilder extends ElementBuilder<FunctionTypeAliasElement>
    with FunctionTypedElementBuilder<FunctionTypeAliasElement> {
  /// Create an instance of [FunctionTypeAliasBuilder] with the context.
  FunctionTypeAliasBuilder(WebIdlContext context) : super(context);

  @override
  FunctionTypeAliasElement build() => _FunctionTypeAliasElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        returnType: returnType.build(),
        arguments: arguments.buildList(),
      );
}

@immutable
class _FunctionTypeAliasElement extends _Element
    implements FunctionTypeAliasElement {
  _FunctionTypeAliasElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.returnType,
    required this.arguments,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        ) {
    encloseAll(arguments);
  }

  @override
  final WebIdlType returnType;

  @override
  final List<ArgumentElement> arguments;
}

/// Builds an immutable [IncludesElement].
class IncludesBuilder extends ElementBuilder<IncludesElement> {
  /// Create an instance of [InterfaceBuilder] with the context.
  IncludesBuilder(WebIdlContext context) : super(context);

  /// The type the mixin is applied to.
  SingleTypeBuilder on = SingleTypeBuilder();

  /// The type being mixed in.
  SingleTypeBuilder mixin = SingleTypeBuilder();

  @override
  IncludesElement build() => _IncludesElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        on: on.build(),
        mixin: mixin.build(),
      );
}

class _IncludesElement extends _Element implements IncludesElement {
  _IncludesElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.on,
    required this.mixin,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        );

  @override
  final SingleType on;

  @override
  final SingleType mixin;
}

/// Builds an immutable [InterfaceElement].
class InterfaceBuilder extends ElementBuilder<InterfaceElement>
    with PartiallyDefinedElementBuilder<InterfaceElement> {
  /// Create an instance of [InterfaceBuilder] with the context.
  InterfaceBuilder(WebIdlContext context) : super(context);

  /// The type of the inherited interface, or `null` if there is none.
  SingleTypeBuilder? supertype;

  /// Whether the interface is a mixin.
  bool isMixin = false;

  /// Whether the interface is a callback.
  bool isCallback = false;

  /// The constructors contained
  List<ConstructorBuilder> constructors = <ConstructorBuilder>[];

  /// The attributes contained in the interface.
  List<AttributeBuilder> attributes = <AttributeBuilder>[];

  /// The operations contained in the interface.
  List<OperationBuilder> operations = <OperationBuilder>[];

  /// The constants defined in the interface.
  List<ConstantBuilder> constants = <ConstantBuilder>[];

  @override
  InterfaceElement build() => _InterfaceElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        isPartial: isPartial,
        supertype: supertype?.build(),
        isMixin: isMixin,
        isCallback: isCallback,
        constructors: constructors.build(),
        attributes: attributes.build(),
        operations: operations.build(),
        constants: constants.build(),
      );
}

class _InterfaceElement extends _Element
    with _TypeDefiningElement
    implements InterfaceElement {
  _InterfaceElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.isPartial,
    required this.supertype,
    required this.isMixin,
    required this.isCallback,
    required Iterable<OperationElement> constructors,
    required Iterable<AttributeElement> attributes,
    required Iterable<OperationElement> operations,
    required Iterable<ConstantElement> constants,
  })  : constructors = List.unmodifiable(constructors),
        attributes = List.unmodifiable(attributes),
        operations = List.unmodifiable(operations),
        constants = List.unmodifiable(constants),
        super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        );

  @override
  final bool isPartial;

  @override
  InterfaceElement get definition => context.lookupInterface(name)!;

  @override
  Iterable<InterfaceElement> get completeDefinition =>
      context.lookupInterfaceDefinitions(name);

  @override
  final SingleType? supertype;

  @override
  final bool isMixin;

  @override
  final bool isCallback;

  @override
  final List<OperationElement> constructors;

  @override
  final List<AttributeElement> attributes;

  @override
  final List<OperationElement> operations;

  @override
  final List<ConstantElement> constants;
}

/// Builds an immutable [NamespaceElement].
class NamespaceBuilder extends ElementBuilder<NamespaceElement>
    with PartiallyDefinedElementBuilder<NamespaceElement> {
  /// Create an instance of [NamespaceBuilder] with the context.
  NamespaceBuilder(WebIdlContext context) : super(context);

  /// The attributes contained in the namespace.
  List<AttributeBuilder> attributes = <AttributeBuilder>[];

  /// The operations contained in the namespace.
  List<OperationBuilder> operations = <OperationBuilder>[];

  /// The constants defined in the namespace.
  List<ConstantBuilder> constants = <ConstantBuilder>[];

  @override
  NamespaceElement build() => _NamespaceElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        isPartial: isPartial,
        attributes: attributes.buildList(),
        operations: operations.buildList(),
        constants: constants.buildList(),
      );
}

class _NamespaceElement extends _Element implements NamespaceElement {
  _NamespaceElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.isPartial,
    required this.attributes,
    required this.operations,
    required this.constants,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        ) {
    encloseAll(attributes);
    encloseAll(operations);
    encloseAll(constants);

    context.registerNamespace(this);
  }

  @override
  final bool isPartial;

  @override
  NamespaceElement get definition => context.lookupNamespace(name)!;

  @override
  Iterable<NamespaceElement> get completeDefinition =>
      context.lookupNamespaceDefinitions(name);

  @override
  final List<AttributeElement> attributes;

  @override
  final List<OperationElement> operations;

  @override
  final List<ConstantElement> constants;
}

/// Builds an immutable [TypeAliasElement].
class TypeAliasBuilder extends ElementBuilder<TypeAliasElement> {
  /// Create an instance of [TypeAliasBuilder] with the context.
  TypeAliasBuilder(WebIdlContext context) : super(context);

  /// The type being aliased.
  WebIdlTypeBuilder type = SingleTypeBuilder();

  @override
  TypeAliasElement build() => _TypeAliasElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        type: type.build(),
      );
}

@immutable
class _TypeAliasElement extends _Element
    with _TypeDefiningElement
    implements TypeAliasElement {
  _TypeAliasElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.type,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        );

  @override
  final WebIdlType type;
}

//------------------------------------------------------------------
// WebIDL member elements
//------------------------------------------------------------------

/// Builds an immutable [ArgumentElement].
class ArgumentBuilder extends ElementBuilder<ArgumentElement> {
  /// Create an instance of [ArgumentBuilder] with the context.
  ArgumentBuilder(WebIdlContext context) : super(context);

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
        context: context,
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
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.type,
    required this.isOptional,
    required this.isVariadic,
    required this.defaultTo,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        );

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
  /// Create an instance of [AttributeBuilder] with the context.
  AttributeBuilder(WebIdlContext context) : super(context);

  /// The type for the attribute.
  WebIdlTypeBuilder type = SingleTypeBuilder();

  /// Whether the attribute is read only.
  bool readOnly = false;

  @override
  AttributeElement build() => _AttributeElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        type: type.build(),
        readOnly: readOnly,
      );
}

@immutable
class _AttributeElement extends _Element implements AttributeElement {
  _AttributeElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.type,
    required this.readOnly,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        );

  @override
  final WebIdlType type;

  @override
  final bool readOnly;
}

/// Builds an immutable [ConstantElement].
class ConstantBuilder extends ElementBuilder<ConstantElement> {
  /// Create an instance of [ConstantBuilder] with the context.
  ConstantBuilder(WebIdlContext context) : super(context);

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
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        type: type.build(),
        value: value,
      );
}

@immutable
class _ConstantElement extends _Element implements ConstantElement {
  _ConstantElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.type,
    required this.value,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        );

  @override
  final SingleType type;

  @override
  final Object value;
}

/// Builds an immutable [DictionaryMemberElement].
class DictionaryMemberBuilder extends ElementBuilder<DictionaryMemberElement> {
  /// Create an instance of [DictionaryMemberBuilder] with the context.
  DictionaryMemberBuilder(WebIdlContext context) : super(context);

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
        context: context,
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
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.type,
    required this.isRequired,
    required this.defaultTo,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        );

  @override
  final WebIdlType type;

  @override
  final bool isRequired;

  @override
  final Object? defaultTo;
}

/// Builds an immutable [OperationElement] representing a constructor.
///
/// The return type of a constructor isn't known without knowing the enclosing
/// [Element] so a special builder is used.
class ConstructorBuilder extends ElementBuilder<OperationElement> {
  /// Create an instance of [ConstructorBuilder] with the context.
  ConstructorBuilder(WebIdlContext context) : super(context);

  /// The arguments for the operation.
  List<ArgumentBuilder> arguments = <ArgumentBuilder>[];

  @override
  OperationElement build() => _ConstructorElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        arguments: arguments.buildList(),
      );
}

@immutable
class _ConstructorElement extends _Element implements OperationElement {
  _ConstructorElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.arguments,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        ) {
    encloseAll(arguments);
  }

  @override
  WebIdlType get returnType => (enclosingElement! as InterfaceElement).thisType;

  @override
  SpecialOperation? get operationType => null;

  @override
  final List<ArgumentElement> arguments;
}

/// Builds an immutable [OperationElement].
class OperationBuilder extends ElementBuilder<OperationElement>
    with FunctionTypedElementBuilder<OperationElement> {
  /// Create an instance of [OperationBuilder] with the context.
  OperationBuilder(WebIdlContext context) : super(context);

  /// The [SpecialOperation] type; if applicable.
  SpecialOperation? operationType;

  @override
  OperationElement build() => _OperationElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        returnType: returnType.build(),
        operationType: operationType,
        arguments: arguments.buildList(),
      );
}

@immutable
class _OperationElement extends _Element implements OperationElement {
  _OperationElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.returnType,
    required this.operationType,
    required this.arguments,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        ) {
    encloseAll(arguments);
  }

  @override
  final WebIdlType returnType;

  @override
  final SpecialOperation? operationType;

  @override
  final List<ArgumentElement> arguments;
}
