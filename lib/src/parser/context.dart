// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import '../element.dart';

/// The context for the WebIdl parsing.
class WebIdlContext {
  final Map<String, _InterfaceDefinition> _interfaces =
      <String, _InterfaceDefinition>{};
  final Map<String, _DictionaryDefinition> _dictionaries =
      <String, _DictionaryDefinition>{};
  final Map<String, _NamespaceDefinition> _namespaces =
      <String, _NamespaceDefinition>{};
  final Map<String, EnumElement> _enumerations = <String, EnumElement>{};
  final Map<String, TypeAliasElement> _typeDefinitions =
      <String, TypeAliasElement>{};
  final Map<String, FunctionTypeAliasElement> _functions =
      <String, FunctionTypeAliasElement>{};

  /// Looks up the [Element] with the given [name].
  ///
  /// Returns `null` if the element is not found.
  Element? lookup(String name) =>
      lookupInterface(name) ??
      lookupDictionary(name) ??
      lookupEnumeration(name) ??
      lookupFunction(name) ??
      lookupTypeDefinition(name);

  /// Registers the [element] with the context.
  void registerTypeDefinition(TypeAliasElement element) {
    _typeDefinitions[element.name] = element;
  }

  /// Looks up the [TypeAliasElement] with the given [name].
  ///
  /// Returns `null` if the interface is not found.
  TypeAliasElement? lookupTypeDefinition(String name) => _typeDefinitions[name];

  /// Registers the [element] with the context.
  void registerFunction(FunctionTypeAliasElement element) {
    _functions[element.name] = element;
  }

  /// Looks up the [FunctionTypeAliasElement] with the given [name].
  ///
  /// Returns `null` if the interface is not found.
  FunctionTypeAliasElement? lookupFunction(String name) => _functions[name];

  /// Registers the [element] with the context.
  void registerIncludes(IncludesElement element) {
    final name = element.on.name;
    final definition =
        _interfaces.putIfAbsent(name, _createInterfaceDefinition);

    definition.includes.add(element);
  }

  /// Registers the [element] with the context.
  void registerInterface(InterfaceElement element) {
    _registerDefinition(element, _interfaces, _createInterfaceDefinition);
  }

  /// Looks up the [InterfaceElement] with the given [name].
  ///
  /// Returns `null` if the interface is not found.
  InterfaceElement? lookupInterface(String name) =>
      _lookupDefinition(name, _interfaces);

  /// Looks up all [InterfaceElement]s associated with the given [name].
  ///
  /// If the interface is found the first item will be the [InterfaceElement]
  /// that is not a partial definition. Then it will retrieve all partial
  /// definitions. There is no guarantee of ordering for the partial
  /// definitions.
  Iterable<InterfaceElement> lookupInterfaceDefinitions(String name) =>
      _lookupDefinitions(name, _interfaces);

  /// Registers the [element] with the context.
  void registerDictionary(DictionaryElement element) {
    _registerDefinition(element, _dictionaries, _createDictionaryDefinition);
  }

  /// Looks up the [DictionaryElement] with the given [name].
  ///
  /// Returns `null` if the dictionary is not found.
  DictionaryElement? lookupDictionary(String name) =>
      _lookupDefinition(name, _dictionaries);

  /// Looks up all [DictionaryElement]s associated with the given [name].
  ///
  /// If the dictionary is found the first item will be the [DictionaryElement]
  /// that is not a partial definition. Then it will retrieve all partial
  /// definitions. There is no guarantee of ordering for the partial
  /// definitions.
  Iterable<DictionaryElement> lookupDictionaryDefinitions(String name) =>
      _lookupDefinitions(name, _dictionaries);

  /// Registers the [element] with the context.
  void registerNamespace(NamespaceElement element) {
    _registerDefinition(element, _namespaces, _createNamespaceDefinition);
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

  void _registerDefinition<T extends PartiallyDefinedElement>(
    T element,
    Map<String, _PartiallyDefinedDefinition<T>> definitions,
    _PartiallyDefinedDefinition<T> Function() ifAbsent,
  ) {
    final name = element.name;
    final definition = definitions.putIfAbsent(name, ifAbsent);

    if (!element.isPartial) {
      definition.definition = element;
    } else {
      definition.partialDefinitions.add(element);
    }
  }

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

class _InterfaceDefinition
    extends _PartiallyDefinedDefinition<InterfaceElement> {
  final List<IncludesElement> includes = <IncludesElement>[];
}

_InterfaceDefinition _createInterfaceDefinition() => _InterfaceDefinition();

// \TODO Use Type Aliases when Dart 2.14 is released
class _DictionaryDefinition
    extends _PartiallyDefinedDefinition<DictionaryElement> {}

_DictionaryDefinition _createDictionaryDefinition() => _DictionaryDefinition();

class _NamespaceDefinition
    extends _PartiallyDefinedDefinition<NamespaceElement> {}

_NamespaceDefinition _createNamespaceDefinition() => _NamespaceDefinition();
