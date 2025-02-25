// Copyright (c) 2020 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:built_collection/built_collection.dart';

import 'argument.dart';
import 'type_system.dart';

/// The base class for all of the constructs within the WebIDL specification.
abstract class Spec {
  /// Annotations that control how language bindings will handle the element.
  //BuiltList<Object> get extendedAttributes;
}

/// A [Spec] this has a name.
abstract mixin class NamedSpec {
  /// The name for this [Spec], or the empty string if the element does not
  /// have one.
  String get name;
}

/// A [Spec] that is partially defined.
///
/// WebIDL allows some [Spec] definitions to be split across multiple
/// fragments.
abstract mixin class PartiallyDefinedSpec {
  /// Whether this [Spec] is a partial definition.
  bool get isPartial;
}

/// A [Spec] that contains a type.
abstract mixin class TypedSpec<T extends WebIdlType> {
  /// The type of this [Spec].
  T get type;
}

/// A [Spec] whose type is a function.
abstract mixin class FunctionTypedSpec {
  /// The type returned by the function.
  WebIdlType get returnType;

  /// The arguments for the function.
  BuiltList<Argument> get arguments;
}

/// A [Spec] that can be statically defined.
abstract mixin class StaticSpec {
  bool get isStatic;
}
