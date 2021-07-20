// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:meta/meta.dart';

import 'element.dart';

/// An object that can be used to visit an element structure.
abstract class ElementVisitor<T> {
  /// Visits the fragment [element].
  ///
  /// The [FragmentElement] is the root for a visitor.
  T visitFragment(FragmentElement element);

  /// Visits the dictionary [element].
  T visitDictionary(DictionaryElement element);

  /// Visits the enumeration [element].
  T visitEnum(EnumElement element);

  /// Visits the function type alias [element].
  T visitFunctionTypeAlias(FunctionTypeAliasElement element);

  /// Visits the includes [element].
  T visitIncludesStatement(IncludesElement element);

  /// Visits the interface [element].
  T visitInterface(InterfaceElement element);

  /// Visits the namespace [element].
  T visitNamespace(NamespaceElement element);

  /// Visits the type alias [element].
  T visitTypeAlias(TypeAliasElement element);

  /// Visits the attribute [element].
  T visitAttribute(AttributeElement element);

  /// Visits the argument [element].
  T visitArgument(ArgumentElement element);

  /// Visits the constant [element].
  T visitConstant(ConstantElement element);

  /// Visits the dictionary member [element].
  T visitDictionaryMember(DictionaryMemberElement element);

  /// Visits the operation [element].
  T visitOperation(OperationElement element);
}

/// An AST visitor that will throw an exception if any of the visit methods that
/// are invoked have not been overridden. It is intended to be a superclass for
/// classes that implement the visitor pattern and need to (a) override all of
/// the visit methods or (b) need to override a subset of the visit method and
/// want to catch when any other visit methods have been invoked.
///
/// Clients may extend this class.
class ThrowingElementVisitor<T> implements ElementVisitor<T> {
  /// Initialize a newly created visitor.
  const ThrowingElementVisitor();

  @override
  T visitFragment(FragmentElement element) => _throw(element);

  @override
  T visitDictionary(DictionaryElement element) => _throw(element);

  @override
  T visitEnum(EnumElement element) => _throw(element);

  @override
  T visitFunctionTypeAlias(FunctionTypeAliasElement element) => _throw(element);

  @override
  T visitIncludesStatement(IncludesElement element) => _throw(element);

  @override
  T visitInterface(InterfaceElement element) => _throw(element);

  @override
  T visitNamespace(NamespaceElement element) => _throw(element);

  @override
  T visitTypeAlias(TypeAliasElement element) => _throw(element);

  @override
  T visitAttribute(AttributeElement element) => _throw(element);

  @override
  T visitArgument(ArgumentElement element) => _throw(element);

  @override
  T visitConstant(ConstantElement element) => _throw(element);

  @override
  T visitDictionaryMember(DictionaryMemberElement element) => _throw(element);

  @override
  T visitOperation(OperationElement element) => _throw(element);

  @alwaysThrows
  T _throw(Element element) {
    throw Exception('Missing implementation of visit${element.runtimeType}');
  }
}
