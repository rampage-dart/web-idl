// Copyright (c) 2020 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'element.dart';

/// Represents a type defined in the WebIDL specification.
abstract class WebIdlType {
  /// Annotations that control how language bindings will handle the type.
  List<Object> get extendedAttributes;

  /// Whether the type is nullable.
  bool get isNullable;
}

/// A [WebIdlType] whose set of values is the union of those in two or more
/// other [WebIdlType]s.
abstract class UnionType implements WebIdlType {
  /// The [WebIdlType]s that make up the [UnionType].
  List<WebIdlType> get memberTypes;
}

/// A [WebIdlType] representing a singular type.
abstract class SingleType implements WebIdlType {
  /// The name of the type.
  String get name;

  /// The arguments for the type.
  List<WebIdlType> get typeArguments;

  /// The [Element] associated with this type.
  Element get element;
}
