// Copyright (c) 2020 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'type.dart';

/// The base class for all of the constructs within the WebIDL element model.
///
/// The element model depicts the semantics of the WebIDL format. It represents
/// things declared with a [name].
abstract class Element {
  /// The name of this element, or the empty string if the element does not have
  /// a name.
  String get name;

  /// Annotations that control how language bindings will handle the element.
  List<Object> get extendedAttributes;

  /// Return the [Element] the logically encloses this [Element].
  ///
  /// This will be `null` if the [Element] is a [FragmentElement] because
  /// fragments are the top-level elements in the model.
  Element? enclosingElement;
}

/// An [Element] that is partially defined.
///
/// WebIDL allows some [Element] definitions to be split across multiple
/// [FragmentElement]s.
abstract class PartiallyDefinedElement<T extends Element> implements Element {
  /// Whether this [Element] is a partial definition.
  bool get isPartial;

  /// Returns the [Element] definition.
  ///
  /// If [isPartial] is `false` then `this` will be returned; otherwise the
  /// [Element] with the root definition will be returned.
  T get definition;

  /// Returns the complete definition of the [Element].
  ///
  /// The non-partial definition will be enumerated first followed by any
  /// partial definitions.
  Iterable<T> get completeDefinition;
}

/// An [Element] that defines a type.
abstract class TypeDefiningElement implements Element {
  /// Return the type of this [Element].
  SingleType get thisType;
}

/// An [Element] whose type is a function.
abstract class FunctionTypedElement implements Element {
  /// The type returned by the function.
  WebIdlType get returnType;

  /// The arguments for the function.
  List<ArgumentElement> get arguments;
}

//------------------------------------------------------------------
// WebIDL definition elements
//------------------------------------------------------------------

/// Contains a group of [Element] definitions.
abstract class FragmentElement implements Element {
  /// The enumerations defined within the WebIDL fragment.
  List<EnumElement> get enumerations;
}

/// Defines an ordered map data type with a fixed, ordered set of entries,
/// termed dictionary members, where keys are strings and values are of a
/// particular type specified in the definition.
///
/// A [DictionaryElement]'s definition can be split across multiple fragments.
/// Each [DictionaryElement] only corresponds to a single definition. To access
/// members across multiple fragments use [CompleteDictionaryElement]
/// extensions.
abstract class DictionaryElement
    implements
        Element,
        PartiallyDefinedElement<DictionaryElement>,
        TypeDefiningElement {
  /// Returns the type of the inherited dictionary, or `null` if there is none.
  SingleType? get supertype;

  /// The set of entries contained in this dictionary definition.
  ///
  /// The full dictionary definition can be split across fragments. To get all
  /// members across all fragments use [allMembers].
  List<DictionaryMemberElement> get members;
}

/// Enumerates all members across the complete definition of a
/// [DictionaryElement].
extension CompleteDictionaryElement on DictionaryElement {
  /// The full listing of dictionary members contained in the namespace.
  ///
  /// Enumerates all dictionary members of the non-partial definition and any
  /// partial definitions. To retrieve only members defined on this element use
  /// [members] instead.
  ///
  /// The dictionary members on the non-partial definition will be enumerated
  /// first but there is no guaranteed ordering for members retrieved from the
  /// partial definitions.
  Iterable<DictionaryMemberElement> get allMembers =>
      completeDefinition.expand((e) => e.members);
}

/// A type whose valid [values] are a set of predefined strings.
///
/// Enumerations can be used to restrict the possible string values that can be
/// assigned to an attribute or passed to an operation.
abstract class EnumElement implements Element, TypeDefiningElement {
  /// The set of valid strings for the enumeration.
  List<String> get values;
}

/// A definition used to declare a function type.
abstract class FunctionTypeAliasElement
    implements Element, FunctionTypedElement {}

/// A definition that declares a global singleton with associated behaviors.
///
/// A [NamespaceElement]'s definition can be split across multiple fragments.
/// Each [NamespaceElement] only corresponds to a single definition. To access
/// members across multiple fragments use [CompleteNamespaceElement] extensions.
abstract class NamespaceElement
    implements Element, PartiallyDefinedElement<NamespaceElement> {
  /// The attributes contained in this namespace definition.
  ///
  /// The full namespace definition can be split across fragments. To get all
  /// attributes across all fragments use [allAttributes].
  List<AttributeElement> get attributes;

  /// The operations contained in this namespace definition.
  ///
  /// The full namespace definition can be split across fragments. To get all
  /// operations across all fragments use [allOperations].
  List<OperationElement> get operations;

  /// The constants defined in this namespace definition.
  ///
  /// The full namespace definition can be split across fragments. To get all
  /// constants across all fragments use [allConstants].
  List<ConstantElement> get constants;
}

/// Enumerates all members across the complete definition of a
/// [NamespaceElement].
extension CompleteNamespaceElement on NamespaceElement {
  /// The full listing of attributes contained in the namespace.
  ///
  /// Enumerates all operations of the non-partial definition and any partial
  /// definitions. To retrieve only operations defined on this element use
  /// [attributes] instead.
  ///
  /// The attributes on the non-partial definition will be enumerated first but
  /// there is no guaranteed ordering for attributes retrieved from the partial
  /// definitions.
  Iterable<AttributeElement> get allAttributes =>
      completeDefinition.expand((e) => e.attributes);

  /// The full listing of operations contained in the namespace.
  ///
  /// Enumerates all operations of the non-partial definition and any partial
  /// definitions. To retrieve only operations defined on this element use
  /// [operations] instead.
  ///
  /// The operations on the non-partial definition will be enumerated first but
  /// there is no guaranteed ordering for operations retrieved from the partial
  /// definitions.
  Iterable<OperationElement> get allOperations =>
      completeDefinition.expand((e) => e.operations);

  /// The full listing of constants contained in the namespace.
  ///
  /// Enumerates all constants of the non-partial definition and any partial
  /// definitions. To retrieve only constants defined on this element use
  /// [constants] instead.
  ///
  /// The constants on the non-partial definition will be enumerated first but
  /// there is no guaranteed ordering for constants retrieved from the partial
  /// definitions.
  Iterable<ConstantElement> get allConstants =>
      completeDefinition.expand((e) => e.constants);
}

/// A definition specifying the usage of a mixin.
abstract class IncludesElement implements Element {
  /// The type the mixin is applied to.
  SingleType get on;

  /// The type being mixed in.
  SingleType get mixin;
}

/// A definition that declares some state and behavior that an object
/// implementing that interface will expose.
///
/// An [InterfaceElement]'s definition can be split across multiple fragments.
/// Each [InterfaceElement] only corresponds to a single definition. To access
/// members across multiple fragments use [CompleteInterfaceElement] extensions.
abstract class InterfaceElement
    implements
        Element,
        PartiallyDefinedElement<InterfaceElement>,
        TypeDefiningElement {
  /// Returns the type of the inherited interface, or `null` if there is none.
  SingleType? get supertype;

  /// Whether the interface is a mixin.
  ///
  /// An interface mixin declares state and behavior that can be included by one
  /// or more interfaces, and that are exposed by objects that implement an
  /// interface that includes the interface mixin.
  bool get isMixin;

  /// Whether the interface is a callback.
  ///
  /// _A callback interface is not an interface. The name and syntax are left
  /// over from earlier versions of this standard, where these concepts had more
  /// in common._
  bool get isCallback;

  /// The constructors for the interface.
  List<OperationElement> get constructors;

  /// The attributes exposed on the interface.
  List<AttributeElement> get attributes;

  /// The operations available for the interface.
  List<OperationElement> get operations;

  /// The constants defined on the interface.
  List<ConstantElement> get constants;
}

/// Enumerates all members across the complete definition of a
/// [InterfaceElement].
extension CompleteInterfaceElement on InterfaceElement {
  /// The full listing of constructors contained in the interface.
  ///
  /// Enumerates all constructors of the non-partial definition and any partial
  /// definitions. To retrieve only constructors defined on this element use
  /// [constructors] instead.
  ///
  /// The constructors on the non-partial definition will be enumerated first
  /// but there is no guaranteed ordering for constructors retrieved from the
  /// partial definitions.
  Iterable<OperationElement> get allConstructors =>
      completeDefinition.expand((e) => e.constructors);

  /// The full listing of attributes contained in the interface.
  ///
  /// Enumerates all attributes of the non-partial definition and any partial
  /// definitions. To retrieve only attributes defined on this element use
  /// [attributes] instead.
  ///
  /// The attributes on the non-partial definition will be enumerated first but
  /// there is no guaranteed ordering for attributes retrieved from the partial
  /// definitions.
  Iterable<AttributeElement> get allAttributes =>
      completeDefinition.expand((e) => e.attributes);

  /// The full listing of operations contained in the interface.
  ///
  /// Enumerates all operations of the non-partial definition and any partial
  /// definitions. To retrieve only operations defined on this element use
  /// [operations] instead.
  ///
  /// The operations on the non-partial definition will be enumerated first but
  /// there is no guaranteed ordering for operations retrieved from the partial
  /// definitions.
  Iterable<OperationElement> get allOperations =>
      completeDefinition.expand((e) => e.operations);

  /// The full listing of constants contained in the namespace.
  ///
  /// Enumerates all constants of the non-partial definition and any partial
  /// definitions. To retrieve only constants defined on this element use
  /// [constants] instead.
  ///
  /// The constants on the non-partial definition will be enumerated first but
  /// there is no guaranteed ordering for constants retrieved from the partial
  /// definitions.
  Iterable<ConstantElement> get allConstants =>
      completeDefinition.expand((e) => e.constants);
}

/// A definition used to declare a new name for a type.
///
/// This new name is not exposed by language bindings; it is purely used as a
/// shorthand for referencing the type in the IDL.
abstract class TypeAliasElement implements Element, TypeDefiningElement {
  /// The type being aliased.
  WebIdlType get type;
}

//------------------------------------------------------------------
// WebIDL member elements
//------------------------------------------------------------------

/// An argument to an operation or callback.
abstract class ArgumentElement implements Element {
  /// The type for the argument.
  WebIdlType get type;

  /// Whether the argument is optional.
  bool get isOptional;

  /// Whether the argument is variadic.
  bool get isVariadic;

  /// The default value for the argument.
  ///
  /// If the argument [isRequired] then this will be `null`. Otherwise this may
  /// be a constant.
  Object? get defaultTo;
}

/// Extension for checking if an [ArgumentElement] is required.
extension RequiredArgumentElement on ArgumentElement {
  /// Whether the argument is required.
  bool get isRequired => !isOptional;
}

/// A data field with a given type and identifier whose value can be retrieved
/// and (in some cases) changed.
abstract class AttributeElement implements Element {
  /// The type for the attribute.
  WebIdlType get type;

  /// Whether the attribute is read only.
  bool get readOnly;
}

/// Extension for whether an [AttributeElement] is writeable.
extension ReadWriteAttributeElement on AttributeElement {
  /// Whether the attribute can be read and written to.
  bool get readWrite => !readOnly;
}

/// A declaration used to bind a constant value to a name.
abstract class ConstantElement implements Element {
  /// The type for the constant.
  ///
  /// The type is limited primitive types (boolean, floating point or integer),
  /// and their type aliases.
  SingleType get type;

  /// The constant's value.
  ///
  /// The value will be a boolean, a floating point number or an integer.
  Object get value;
}

/// An entry in a [DictionaryElement].
abstract class DictionaryMemberElement implements Element {
  /// The type for the field.
  WebIdlType get type;

  /// Whether setting the field is required.
  bool get isRequired;

  /// The default value for the argument.
  ///
  /// If the argument [isRequired] then this will be `null`. Otherwise this may
  /// be a constant.
  Object? get defaultTo;
}

/// Extension for checking if an [DictionaryMemberElement] is optional.
extension OptionalDictionaryMemberElement on DictionaryMemberElement {
  /// Whether setting the field is optional.
  bool get isOptional => !isRequired;
}

/// Defines a behavior that can be invoked on objects implementing the
/// interface.
abstract class OperationElement implements Element, FunctionTypedElement {
  /// The [SpecialOperation] type; if applicable.
  SpecialOperation? get operationType;
}

/// Extension for checking if an [OperationElement] is regular.
extension OperationElementType on OperationElement {
  /// Whether the operation is regular.
  ///
  /// Returns `true` if [operationType] is `null`; `false` otherwise.
  bool get isRegular => operationType == null;

  /// Whether the operation is special.
  ///
  /// Returns `true` if [operationType] is not `null`; `false` otherwise.
  bool get isSpecial => operationType != null;
}

/// A declaration of a certain kind of special behavior on objects implementing
/// the interface on which the special operation declarations appear.
enum SpecialOperation {
  /// Defines behavior for when an object is indexed for property retrieval.
  getter,

  /// Defines behavior for when an object is indexed for property assignment or
  /// creation.
  setter,

  /// Defines behavior for when an object is indexed for property deletion.
  deleter,

  /// Defines how an object is converted into a DOMString.
  stringifier,
}
