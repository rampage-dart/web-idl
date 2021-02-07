// Copyright (c) 2020 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:meta/meta.dart';
import 'package:web_idl/src/element.dart';

/// Builds an immutable [Element].
abstract class ElementBuilder<T extends Element> {
  /// The name of the [Element].
  String name = '';

  /// Returns the [Element] specified by the builder.
  ///
  /// The builder returns an immutable representation of [T].
  T build();
}

@immutable
class _Element implements Element {
  const _Element(this.name);

  @override
  final String name;
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
        name,
        enumerations.map((b) => b.build()),
      );
}

@immutable
class _FragmentElement extends _Element implements FragmentElement {
  _FragmentElement(String name, Iterable<EnumElement> enumerations)
      : enumerations = List.unmodifiable(enumerations),
        super(name);

  @override
  final List<EnumElement> enumerations;
}

/// Builds an immutable [EnumElement].
class EnumBuilder extends ElementBuilder<EnumElement> {
  /// The set of valid strings for the [EnumElement].
  List<String> values = <String>[];

  @override
  EnumElement build() => _EnumElement(name, values);
}

@immutable
class _EnumElement extends _Element implements EnumElement {
  _EnumElement(String name, Iterable<String> values)
      : values = List.unmodifiable(values),
        super(name);

  @override
  final List<String> values;
}
