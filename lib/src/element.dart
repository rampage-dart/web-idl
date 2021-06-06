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
abstract class DictionaryElement
    implements
        Element,
        PartiallyDefinedElement<DictionaryElement>,
        TypeDefiningElement {
  /// Returns the type of the inherited dictionary, or `null` if there is none.
  SingleType? get supertype;

  /// The set of entries in the dictionary.
  List<DictionaryMemberElement> get members;
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
abstract class NamespaceElement
    implements Element, PartiallyDefinedElement<NamespaceElement> {
  /// The attributes contained in the namespace.
  List<AttributeElement> get attributes;

  /// The operations contained in the namespace.
  List<OperationElement> get operations;

  /// The constants defined in the namespace.
  List<ConstantElement> get constants;
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
