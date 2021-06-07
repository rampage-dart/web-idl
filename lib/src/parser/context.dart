// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import '../element.dart';

/// The context for the WebIdl parsing.
class WebIdlContext {
  final Map<String, _NamespaceDefinition> _namespaces =
      <String, _NamespaceDefinition>{};
  final Map<String, EnumElement> _enumerations = <String, EnumElement>{};

  /// Registers the [element] with the context.
  void registerNamespace(NamespaceElement element) {
    final name = element.name;
    final definition = _namespaces[name] ?? _NamespaceDefinition();

    if (!element.isPartial) {
      definition.definition = element;
    } else {
      definition.partialDefinitions.add(element);
    }

    _namespaces[name] = definition;
  }

  /// Looks up the [NamespaceElement] with the given [name].
  ///
  /// Returns `null` if the namespace is not found.
  NamespaceElement? lookupNamespace(String name) =>
      _lookupDefinition(name, _namespaces);

  /// Looks up all [NamespaceElement]s associated with the given [name].
  ///
  /// If the namespace is found the first item will be the [NamespaceElement]
  /// that is not a partial definition. Then it will retrieve all partial
  /// definitions. There is no guarantee of ordering for the partial
  /// definitions.
  Iterable<NamespaceElement> lookupNamespaceDefinitions(String name) =>
      _lookupDefinitions(name, _namespaces);

  /// Registers the [element] with the context.
  void registerEnumeration(EnumElement element) {
    final name = element.name;
    if (_enumerations.containsKey(name)) {
      throw StateError('$name is multiply defined');
    }
    _enumerations[name] = element;
  }

  /// Looks up the [EnumElement] with the given [name].
  ///
  /// Returns `null` if the namespace is not found.
  EnumElement? lookupEnumeration(String name) => _enumerations[name];

  T? _lookupDefinition<T extends PartiallyDefinedElement>(
    String name,
    Map<String, _PartiallyDefinedDefinition<T>> definitions,
  ) {
    final record = definitions[name];
    if (record == null) {
      return null;
    }

    final definition = record.definition;
    if (definition == null) {
      throw StateError('definition of `$name` not found');
    }

    return definition;
  }

  Iterable<T> _lookupDefinitions<T extends PartiallyDefinedElement>(
    String name,
    Map<String, _PartiallyDefinedDefinition<T>> definitions,
  ) sync* {
    final record = definitions[name];
    if (record != null) {
      final definition = record.definition;
      if (definition == null) {
        throw StateError('definition of `$name` not found');
      }

      yield definition;
      yield* record.partialDefinitions;
    }
  }
}

class _PartiallyDefinedDefinition<T extends PartiallyDefinedElement> {
  T? definition;

  final List<T> partialDefinitions = <T>[];
}

// \TODO Use Type Alias when Dart 2.14 is released
class _NamespaceDefinition
    extends _PartiallyDefinedDefinition<NamespaceElement> {}
