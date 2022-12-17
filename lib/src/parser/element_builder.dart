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

/// Builds a statically defined [Element].
///
/// Base class for the parser to cast to for [AttributeElement]s and
/// [OperationElement]s since they can both be declared statically but don't
/// have a common base class.
mixin StaticElementBuilder<T extends Element> implements ElementBuilder<T> {
  /// Whether the element is statically defined.
  bool isStatic = false;
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

  @override
  final TypeDefiningElement element;
}

//------------------------------------------------------------------
// WebIDL definition elements
//------------------------------------------------------------------

/// Builds an immutable [FragmentElement].
class FragmentBuilder extends ElementBuilder<FragmentElement> {
  /// Create an instance of [FragmentBuilder] with the context.
  FragmentBuilder(WebIdlContext context) : super(context);

  /// The dictionaries defined within the WebIDL fragment.
  List<DictionaryBuilder> dictionaries = <DictionaryBuilder>[];

  /// The enumerations defined within the WebIDL fragment.
  List<EnumBuilder> enumerations = <EnumBuilder>[];

  /// The function definitions within the WebIDL fragment.
  List<FunctionTypeAliasBuilder> functions = <FunctionTypeAliasBuilder>[];

  /// The includes defined within the WebIDL fragment.
  List<IncludesBuilder> includes = <IncludesBuilder>[];

  /// The interfaces defined within the WebIDL fragment.
  List<InterfaceBuilder> interfaces = <InterfaceBuilder>[];

  /// The namespaces defined within the WebIDL fragment.
  List<NamespaceBuilder> namespaces = <NamespaceBuilder>[];

  /// The type definitions within the WebIDL fragment.
  List<TypeAliasBuilder> typeDefinitions = <TypeAliasBuilder>[];

  @override
  FragmentElement build() => _FragmentElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        dictionaries: dictionaries.buildList(),
        enumerations: enumerations.buildList(),
        functions: functions.buildList(),
        includes: includes.buildList(),
        interfaces: interfaces.buildList(),
        namespaces: namespaces.buildList(),
        typeDefinitions: typeDefinitions.buildList(),
      );
}

/// Helper for adding [ElementBuilder]s to the [FragmentBuilder].
extension FragmentBuilderMembers on FragmentBuilder {
  /// Adds all [members] to the list associated with their [ElementBuilder]
  /// type.
  void addMembers(Iterable<ElementBuilder> members) {
    for (final member in members) {
      if (member is InterfaceBuilder) {
        interfaces.add(member);
      } else if (member is DictionaryBuilder) {
        dictionaries.add(member);
      } else if (member is NamespaceBuilder) {
        namespaces.add(member);
      } else if (member is FunctionTypeAliasBuilder) {
        functions.add(member);
      } else if (member is EnumBuilder) {
        enumerations.add(member);
      } else if (member is TypeAliasBuilder) {
        typeDefinitions.add(member);
      } else if (member is IncludesBuilder) {
        includes.add(member);
      }
    }
  }
}

@immutable
class _FragmentElement extends _Element implements FragmentElement {
  _FragmentElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.dictionaries,
    required this.enumerations,
    required this.functions,
    required this.includes,
    required this.interfaces,
    required this.namespaces,
    required this.typeDefinitions,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        ) {
    encloseAll(dictionaries);
    encloseAll(enumerations);
    encloseAll(functions);
    encloseAll(includes);
    encloseAll(interfaces);
    encloseAll(namespaces);
    encloseAll(typeDefinitions);
  }

  @override
  final List<DictionaryElement> dictionaries;

  @override
  final List<EnumElement> enumerations;

  @override
  final List<FunctionTypeAliasElement> functions;

  @override
  final List<IncludesElement> includes;

  @override
  final List<InterfaceElement> interfaces;

  @override
  final List<NamespaceElement> namespaces;

  @override
  final List<TypeAliasElement> typeDefinitions;
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
        supertype: supertype?.build(context),
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

    context.registerDictionary(this);
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
        returnType: returnType.build(context),
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

    context.registerFunction(this);
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
        on: on.build(context),
        mixin: mixin.build(context),
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
        ) {
    context.registerIncludes(this);
  }

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
        supertype: supertype?.build(context),
        isMixin: isMixin,
        isCallback: isCallback,
        constructors: constructors.buildList(),
        attributes: attributes.buildList(),
        operations: operations.buildList(),
        constants: constants.buildList(),
      );
}

/// Helper for adding [ElementBuilder]s to the [InterfaceBuilder].
extension InterfaceBuilderMembers on InterfaceBuilder {
  /// Adds all [members] to the list associated with their [ElementBuilder]
  /// type.
  void addMembers(Iterable<ElementBuilder> members) {
    for (final member in members) {
      if (member is AttributeBuilder) {
        attributes.add(member);
      } else if (member is OperationBuilder) {
        operations.add(member);
      } else if (member is ConstructorBuilder) {
        constructors.add(member);
      } else if (member is ConstantBuilder) {
        constants.add(member);
      }
    }
  }
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
    required this.constructors,
    required this.attributes,
    required this.operations,
    required this.constants,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        ) {
    encloseAll(constructors);
    encloseAll(attributes);
    encloseAll(operations);
    encloseAll(constants);

    context.registerInterface(this);
  }

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

/// Helper for adding [ElementBuilder]s to the [NamespaceBuilder].
extension NamespaceBuilderMembers on NamespaceBuilder {
  /// Adds all [members] to the list associated with their [ElementBuilder]
  /// type.
  void addMembers(Iterable<ElementBuilder> members) {
    for (final member in members) {
      if (member is AttributeBuilder) {
        attributes.add(member);
      } else if (member is OperationBuilder) {
        operations.add(member);
      } else if (member is ConstantBuilder) {
        constants.add(member);
      }
    }
  }
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
        type: type.build(context),
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
        ) {
    context.registerTypeDefinition(this);
  }

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
        type: type.build(context),
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
class AttributeBuilder extends ElementBuilder<AttributeElement>
    with StaticElementBuilder<AttributeElement> {
  /// Create an instance of [AttributeBuilder] with the context.
  AttributeBuilder(WebIdlContext context) : super(context);

  /// The type for the attribute.
  WebIdlTypeBuilder type = SingleTypeBuilder();

  /// Whether the attribute is a stringifier.
  bool isStringifier = false;

  /// Whether the attribute is read only.
  bool readOnly = false;

  @override
  AttributeElement build() => _AttributeElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        type: type.build(context),
        isStringifier: isStringifier,
        isStatic: isStatic,
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
    required this.isStringifier,
    required this.isStatic,
    required this.readOnly,
  }) : super(
          context: context,
          name: name,
          extendedAttributes: extendedAttributes,
        );

  @override
  final WebIdlType type;

  @override
  final bool isStringifier;

  @override
  final bool isStatic;

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
        type: type.build(context),
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
        type: type.build(context),
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
  final List<ArgumentElement> arguments;

  @override
  bool get isStatic => false;

  @override
  SpecialOperation? get operationType => null;
}

/// Builds an immutable [OperationElement].
class OperationBuilder extends ElementBuilder<OperationElement>
    with
        FunctionTypedElementBuilder<OperationElement>,
        StaticElementBuilder<OperationElement> {
  /// Create an instance of [OperationBuilder] with the context.
  OperationBuilder(WebIdlContext context) : super(context);

  /// The [SpecialOperation] type; if applicable.
  SpecialOperation? operationType;

  @override
  OperationElement build() => _OperationElement(
        context: context,
        name: name,
        extendedAttributes: extendedAttributes,
        returnType: returnType.build(context),
        arguments: arguments.buildList(),
        isStatic: isStatic,
        operationType: operationType,
      );
}

@immutable
class _OperationElement extends _Element implements OperationElement {
  _OperationElement({
    required WebIdlContext context,
    required String name,
    required Iterable<Object> extendedAttributes,
    required this.returnType,
    required this.arguments,
    required this.isStatic,
    required this.operationType,
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

  @override
  final bool isStatic;

  @override
  final SpecialOperation? operationType;
}
