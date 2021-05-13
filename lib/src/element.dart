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
}

//------------------------------------------------------------------
// WebIDL definition elements
//------------------------------------------------------------------

/// Contains a group of [Element] definitions.
abstract class FragmentElement implements Element {
  /// The enumerations defined within the WebIDL fragment.
  List<EnumElement> get enumerations;
}

/// A type whose valid [values] are a set of predefined strings.
///
/// Enumerations can be used to restrict the possible string values that can be
/// assigned to an attribute or passed to an operation.
abstract class EnumElement implements Element {
  /// The set of valid strings for the enumeration.
  List<String> get values;
}

/// A definition used to declare a new name for a type.
///
/// This new name is not exposed by language bindings; it is purely used as a
/// shorthand for referencing the type in the IDL.
abstract class TypeAliasElement implements Element {
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
