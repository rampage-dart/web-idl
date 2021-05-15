// Copyright (c) 2019 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:petitparser/petitparser.dart';

import 'keywords.dart' as keywords;

/// WebIDL grammar definition.
///
/// Implementation of the [WebIDL grammar]
/// (https://heycam.github.io/webidl/#idl-grammar).
class WebIdlGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => ref0(definitions).end();

  /// Parses the [input] token.
  Parser token(Object source, [String? message]) {
    if (source is String) {
      return source
          .toParser(message: 'expected ${message ?? source}')
          .token()
          .trim(ref0(_hidden));
    } else if (source is Parser) {
      ArgumentError.checkNotNull(message, 'message');
      return source.flatten('expected $message').token().trim(ref0(_hidden));
    }

    throw ArgumentError('unknown token type: $source');
  }

  /// Reference to a production [callback] that takes a [builtin] type name.
  ///
  /// Ensures that the whole word is matched to allow type identifiers that
  /// start with the same characters as a builtin type. As an example
  /// `ArrayBufferView` shouldn't match with `ArrayBuffer`.
  Parser refBuiltinType(
    Parser Function(Object, String?) callback,
    String builtin,
  ) =>
      _refWholeWord(callback, builtin);

  /// Reference to a production [callback] that takes a [keyword].
  ///
  /// Ensures that the whole keyword is matched.
  Parser refKeyword(
    Parser Function(Object, String?) callback,
    keywords.Keyword keyword,
  ) =>
      _refWholeWord(callback, keyword.token);

  Parser _refWholeWord(
    Parser Function(Object, String?) callback,
    String value,
  ) =>
      ref2(callback, value.toParser() & word().not(), value);

  //------------------------------------------------------------------
  // Grammar definition
  //
  // Implementation of the definition in grammar.txt.
  //------------------------------------------------------------------

  /// The `Definitions` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Definitions).
  ///
  /// This is the root of the grammar.
  Parser definitions() =>
      (ref0(extendedAttributeList) & ref0(definition) & ref0(definitions))
          .optional();

  /// A `Definition` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Definition).
  Parser definition() =>
      ref0(callbackOrInterfaceOrMixin) |
      ref0(namespace) |
      ref0(partial) |
      ref0(dictionary) |
      ref0(enumeration) |
      ref0(typeDefinition) |
      ref0(includesStatement);

  /// An `ArgumentNameKeyword` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ArgumentNameKeyword).
  Parser argumentNameKeyword() =>
      ref0(asyncKeyword) |
      ref0(attributeKeyword) |
      ref0(callbackKeyword) |
      ref0(constructorKeyword) |
      ref0(constKeyword) | // Needs to come after constructor
      ref0(deleterKeyword) |
      ref0(dictionaryKeyword) |
      ref0(enumKeyword) |
      ref0(getterKeyword) |
      ref0(includesKeyword) |
      ref0(inheritKeyword) |
      ref0(interfaceKeyword) |
      ref0(iterableKeyword) |
      ref0(maplikeKeyword) |
      ref0(mixinKeyword) |
      ref0(namespaceKeyword) |
      ref0(partialKeyword) |
      ref0(readonlyKeyword) |
      ref0(requiredKeyword) |
      ref0(setlikeKeyword) |
      ref0(setterKeyword) |
      ref0(staticKeyword) |
      ref0(stringifierKeyword) |
      ref0(typedefKeyword) |
      ref0(unrestrictedKeyword);

  /// A `CallbackOrInterfaceOrMixin` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-CallbackOrInterfaceOrMixin).
  Parser callbackOrInterfaceOrMixin() =>
      (ref0(callbackKeyword) & ref0(callbackRestOrInterface)) |
      (ref0(interfaceKeyword) & ref0(interfaceOrMixin));

  /// An `InterfaceOrMixin` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-InterfaceOrMixin).
  Parser interfaceOrMixin() => ref0(interfaceRest) | ref0(mixinRest);

  /// An `InterfaceRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-InterfaceRest).
  Parser interfaceRest() =>
      ref0(identifier) &
      ref0(inheritance) &
      ref1(token, '{') &
      ref0(interfaceMembers) &
      ref1(token, '}') &
      ref1(token, ';');

  /// A `Partial` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Partial).
  Parser partial() => ref0(partialKeyword) & ref0(partialDefinition);

  /// A `PartialDefinition` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PartialDefinition).
  Parser partialDefinition() {
    final interface =
        ref0(interfaceKeyword) & ref0(partialInterfaceOrPartialMixin);

    return interface | ref0(partialDictionary) | ref0(namespace);
  }

  /// A `PartialInterfaceOrPartialMixin` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PartialInterfaceOrPartialMixin).
  Parser partialInterfaceOrPartialMixin() =>
      ref0(partialInterfaceRest) | ref0(mixinRest);

  /// A `PartialInterfaceRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PartialInterfaceRest).
  Parser partialInterfaceRest() =>
      ref0(identifier) &
      ref1(token, '{') &
      ref0(partialInterfaceMembers) &
      ref1(token, '}') &
      ref1(token, ';');

  /// An `InterfaceMembers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-InterfaceMembers).
  Parser interfaceMembers() {
    final members = ref0(extendedAttributeList) &
        ref0(interfaceMember) &
        ref0(interfaceMembers);

    return members.optional();
  }

  /// An `InterfaceMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-InterfaceMember).
  Parser interfaceMember() => ref0(partialInterfaceMember) | ref0(constructor);

  /// A `PartialInterfaceMembers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PartialInterfaceMembers).
  Parser partialInterfaceMembers() {
    final members = ref0(extendedAttributeList) &
        ref0(partialInterfaceMember) &
        ref0(partialInterfaceMembers);

    return members.optional();
  }

  /// A `PartialInterfaceMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PartialInterfaceMember).
  Parser partialInterfaceMember() =>
      ref0(constant) |
      ref0(stringifier) |
      ref0(staticMember) |
      ref0(iterable) |
      ref0(asyncIterable) |
      ref0(readOnlyMember) |
      ref0(readWriteAttribute) |
      ref0(readWriteMaplike) |
      ref0(readWriteSetlike) |
      ref0(inheritAttribute) |
      ref0(operation);

  /// An `Inheritance` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Inheritance).
  Parser inheritance() => (ref1(token, ':') & ref0(identifier)).optional();

  /// A `MixinRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-MixinRest).
  Parser mixinRest() =>
      ref0(mixinKeyword) &
      ref0(identifier) &
      ref1(token, '{') &
      ref0(mixinMembers) &
      ref1(token, '}') &
      ref1(token, ';');

  /// A `MixinMembers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-MixinMembers).
  Parser mixinMembers() =>
      (ref0(extendedAttributeList) & ref0(mixinMember) & ref0(mixinMembers))
          .optional();

  /// A `MixinMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-MixinMember).
  Parser mixinMember() =>
      ref0(constant) |
      ref0(regularOperation) |
      ref0(stringifier) |
      (ref0(optionalReadOnly) & ref0(attributeRest));

  /// An `IncludesStatement` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-IncludesStatement).
  Parser includesStatement() =>
      ref0(identifier) &
      ref0(includesKeyword) &
      ref0(identifier) &
      ref1(token, ';');

  /// A `CallbackRestOrInterface` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-CallbackRestOrInterface).
  Parser callbackRestOrInterface() {
    final interface = ref0(interfaceKeyword) &
        ref0(identifier) &
        ref1(token, '{') &
        ref0(callbackInterfaceMembers) &
        ref1(token, '}') &
        ref1(token, ';');

    return ref0(callbackRest) | interface;
  }

  /// A `CallbackInterfaceMembers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-CallbackInterfaceMembers).
  Parser callbackInterfaceMembers() {
    final members = ref0(extendedAttributeList) &
        ref0(callbackInterfaceMember) &
        ref0(callbackInterfaceMembers);

    return members.optional();
  }

  /// A `CallbackInterfaceMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-CallbackInterfaceMember).
  Parser callbackInterfaceMember() => ref0(constant) | ref0(regularOperation);

  /// A `Const` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Const).
  Parser constant() =>
      ref0(constKeyword) &
      ref0(constantType) &
      ref0(identifier) &
      ref1(token, '=') &
      ref0(constantValue) &
      ref1(token, ';');

  /// A `ConstValue` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ConstValue).
  Parser constantValue() =>
      ref0(booleanLiteral) | ref0(floatLiteral) | ref0(integer);

  /// A `BooleanLiteral` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-BooleanLiteral).
  Parser booleanLiteral() => ref1(token, 'true') | ref1(token, 'false');

  /// A `FloatLiteral` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-FloatLiteral).
  Parser floatLiteral() =>
      ref0(decimal) |
      ref1(token, '-Infinity') |
      ref1(token, 'Infinity') |
      ref1(token, 'NaN');

  /// A `ConstType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ConstType).
  Parser constantType() => ref0(primitiveType) | ref0(identifier);

  /// A `ReadOnlyMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ReadOnlyMember).
  Parser readOnlyMember() => ref0(readonlyKeyword) & ref0(readOnlyMemberRest);

  /// A `ReadOnlyMemberRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ReadOnlyMemberRest).
  Parser readOnlyMemberRest() =>
      ref0(attributeRest) | ref0(maplikeRest) | ref0(setlikeRest);

  /// A `ReadWriteAttribute` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ReadWriteAttribute).
  Parser readWriteAttribute() => ref0(attributeRest);

  /// An `InheritAttribute` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-InheritAttribute)
  Parser inheritAttribute() => ref0(inheritKeyword) & ref0(attributeRest);

  /// An `AttributeRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-AttributeRest).
  Parser attributeRest() =>
      ref0(attributeKeyword) &
      ref0(typeWithExtendedAttributes) &
      ref0(attributeName) &
      ref1(token, ';');

  /// An `AttributeName` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-AttributeName).
  Parser attributeName() => ref0(attributeNameKeyword) | ref0(identifier);

  /// An `AttributeNameKeyword` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-AttributeNameKeyword).
  Parser attributeNameKeyword() => ref0(asyncKeyword) | ref0(requiredKeyword);

  /// An `OptionalReadOnly` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OptionalReadOnly).
  Parser optionalReadOnly() => ref0(readonlyKeyword).optional();

  /// A `DefaultValue` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-DefaultValue).
  Parser defaultValue() =>
      ref0(constantValue) |
      ref0(stringLiteral) |
      (ref1(token, '[') & ref1(token, ']')) |
      (ref1(token, '{') & ref1(token, '}')) |
      ref1(token, 'null');

  /// An `Operation` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Operation).
  Parser operation() => ref0(regularOperation) | ref0(specialOperation);

  /// A `RegularOperation` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-RegularOperation).
  Parser regularOperation() => ref0(type) & ref0(operationRest);

  /// A `SpecialOperation` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-SpecialOperation).
  Parser specialOperation() => ref0(special) & ref0(regularOperation);

  /// A `Special` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Special).
  Parser special() =>
      ref0(getterKeyword) | ref0(setterKeyword) | ref0(deleterKeyword);

  /// An `OperationRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OperationRest).
  Parser operationRest() =>
      ref0(optionalOperationName) &
      ref1(token, '(') &
      ref0(argumentList) &
      ref1(token, ')') &
      ref1(token, ';');

  /// An `OptionalOperationName` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OptionalOperationName).
  Parser optionalOperationName() => ref0(operationName).optional();

  /// An `OperationName` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OperationName).
  Parser operationName() => ref0(operationNameKeyword) | ref0(identifier);

  /// An `OperationNameKeyword` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OperationNameKeyword).
  Parser operationNameKeyword() => ref0(includesKeyword);

  /// An `ArgumentList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ArgumentList).
  Parser argumentList() => (ref0(argument) & ref0(arguments)).optional();

  /// An `Arguments` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Arguments).
  Parser arguments() =>
      (ref1(token, ',') & ref0(argument) & ref0(arguments)).optional();

  /// An `Argument` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Argument).
  Parser argument() => ref0(extendedAttributeList) & ref0(argumentRest);

  /// An `ArgumentRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ArgumentRest).
  Parser argumentRest() {
    final optional = ref1(token, 'optional') &
        ref0(typeWithExtendedAttributes) &
        ref0(argumentName) &
        ref0(defaultTo);
    final require = ref0(type) & ref0(ellipsis) & ref0(argumentName);

    return optional | require;
  }

  /// An `ArgumentName` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ArgumentName).
  Parser argumentName() => ref0(argumentNameKeyword) | ref0(identifier);

  /// An `Ellipsis` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Ellipsis).
  Parser ellipsis() => ref1(token, '...').optional();

  /// A `Constructor` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Constructor).
  Parser constructor() =>
      ref0(constructorKeyword) &
      ref1(token, '(') &
      ref0(argumentList) &
      ref1(token, ')') &
      ref1(token, ';');

  /// A `Stringifier` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Stringifier).
  Parser stringifier() => ref0(stringifierKeyword) & ref0(stringifierRest);

  /// A `StringifierRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-StringifierRest).
  Parser stringifierRest() =>
      (ref0(optionalReadOnly) & ref0(attributeRest)) |
      ref0(regularOperation) |
      ref1(token, ';');

  /// A `StaticMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-StaticMember).
  Parser staticMember() => ref0(staticKeyword) & ref0(staticMemberRest);

  /// A `StaticMemberRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-StaticMemberRest).
  Parser staticMemberRest() =>
      (ref0(optionalReadOnly) & ref0(attributeRest)) | ref0(regularOperation);

  /// An `Iterable` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Iterable).
  Parser iterable() =>
      ref0(iterableKeyword) &
      ref1(token, '<') &
      ref0(typeWithExtendedAttributes) &
      ref0(optionalType) &
      ref1(token, '>') &
      ref1(token, ';');

  /// An `OptionalType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OptionalType).
  Parser optionalType() =>
      (ref1(token, ',') & ref0(typeWithExtendedAttributes)).optional();

  /// An `AsyncIterable` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-AsyncIterable).
  Parser asyncIterable() =>
      ref0(asyncKeyword) &
      ref0(iterableKeyword) &
      ref1(token, '<') &
      ref0(typeWithExtendedAttributes) &
      ref0(optionalType) &
      ref1(token, '>') &
      ref0(optionalArgumentList) &
      ref1(token, ';');

  /// An `OptionalArgumentList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OptionalArgumentList).
  Parser optionalArgumentList() =>
      (ref1(token, '(') & ref0(argumentList) & ref1(token, ')')).optional();

  /// A `ReadWriteMaplike` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ReadWriteMaplike).
  Parser readWriteMaplike() => ref0(maplikeRest);

  /// A `MaplikeRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-MaplikeRest).
  Parser maplikeRest() =>
      ref0(maplikeKeyword) &
      ref1(token, '<') &
      ref0(typeWithExtendedAttributes) &
      ref1(token, ',') &
      ref0(typeWithExtendedAttributes) &
      ref1(token, '>') &
      ref1(token, ';');

  /// A `ReadWriteSetlike` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ReadWriteSetlike).
  Parser readWriteSetlike() => ref0(setlikeRest);

  /// A `SetlikeRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-SetlikeRest).
  Parser setlikeRest() =>
      ref0(setlikeKeyword) &
      ref1(token, '<') &
      ref0(typeWithExtendedAttributes) &
      ref1(token, '>') &
      ref1(token, ';');

  /// A `Namespace` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Namespace).
  Parser namespace() =>
      ref0(namespaceKeyword) &
      ref0(identifier) &
      ref1(token, '{') &
      ref0(namespaceMembers) &
      ref1(token, '}') &
      ref1(token, ';');

  /// A `NamespaceMembers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-NamespaceMembers).
  Parser namespaceMembers() {
    final members = ref0(extendedAttributeList) &
        ref0(namespaceMember) &
        ref0(namespaceMembers);

    return members.optional();
  }

  /// A `NamespaceMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-NamespaceMember).
  Parser namespaceMember() =>
      ref0(regularOperation) |
      (ref0(readonlyKeyword) & ref0(attributeRest)) |
      ref0(constant);

  /// A `Dictionary` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Dictionary).
  Parser dictionary() =>
      ref0(dictionaryKeyword) &
      ref0(identifier) &
      ref0(inheritance) &
      ref1(token, '{') &
      ref0(dictionaryMembers) &
      ref1(token, '}') &
      ref1(token, ';');

  /// A `DictionaryMembers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-DictionaryMembers).
  Parser dictionaryMembers() =>
      (ref0(dictionaryMember) & ref0(dictionaryMembers)).optional();

  /// A `DictionaryMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-DictionaryMember).
  Parser dictionaryMember() =>
      ref0(extendedAttributeList) & ref0(dictionaryMemberRest);

  /// A `DictionaryMemberRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-DictionaryMemberRest).
  Parser dictionaryMemberRest() {
    final require = ref0(requiredKeyword) &
        ref0(typeWithExtendedAttributes) &
        ref0(identifier) &
        ref1(token, ';');
    final member =
        ref0(type) & ref0(identifier) & ref0(defaultTo) & ref1(token, ';');

    return require | member;
  }

  /// A `PartialDictionary` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PartialDictionary).
  Parser partialDictionary() =>
      ref0(dictionaryKeyword) &
      ref0(identifier) &
      ref1(token, '{') &
      ref0(dictionaryMembers) &
      ref1(token, '}') &
      ref1(token, ';');

  /// A `Default` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Default).
  Parser defaultTo() => (ref1(token, '=') & ref0(defaultValue)).optional();

  /// An `Enum` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Enum).
  Parser enumeration() =>
      ref0(enumKeyword) &
      ref0(identifier) &
      ref1(token, '{') &
      ref0(enumerationValueList) &
      ref1(token, '}') &
      ref1(token, ';');

  /// An `EnumValueList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-EnumValueList).
  Parser enumerationValueList() =>
      ref0(stringLiteral) & ref0(enumerationValueListComma);

  /// An `EnumValueListComma` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-EnumValueListComma).
  Parser enumerationValueListComma() =>
      (ref1(token, ',') & ref0(enumerationValueListString)).optional();

  /// An `EnumValueListString` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-EnumValueListString).
  Parser enumerationValueListString() =>
      (ref0(stringLiteral) & ref0(enumerationValueListComma)).optional();

  /// A `CallbackRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-CallbackRest).
  Parser callbackRest() =>
      ref0(identifier) &
      ref1(token, '=') &
      ref0(type) &
      ref1(token, '(') &
      ref0(argumentList) &
      ref1(token, ')') &
      ref1(token, ';');

  /// A `Typedef` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Typedef).
  Parser typeDefinition() =>
      ref0(typedefKeyword) &
      ref0(typeWithExtendedAttributes) &
      ref0(identifier) &
      ref1(token, ';');

  /// A `Type` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Type).
  Parser type() => ref0(singleType) | (ref0(unionType) & ref0(nullable));

  /// A `TypeWithExtendedAttributes` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-TypeWithExtendedAttributes).
  Parser typeWithExtendedAttributes() =>
      ref0(extendedAttributeList) & ref0(type);

  /// A `SingleType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-SingleType).
  Parser singleType() =>
      refBuiltinType(token, 'any') |
      ref0(promiseType) |
      ref0(distinguishableType);

  /// An `UnionType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-UnionType).
  Parser unionType() =>
      ref1(token, '(') &
      ref0(unionMemberType) &
      ref1(token, 'or') &
      ref0(unionMemberType) &
      ref0(unionMemberTypes) &
      ref1(token, ')');

  /// An `UnionMemberType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-UnionMemberType).
  Parser unionMemberType() =>
      (ref0(extendedAttributeList) & ref0(distinguishableType)) |
      (ref0(unionType) & ref0(nullable));

  /// An `UnionMemberTypes` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-UnionMemberTypes).
  Parser unionMemberTypes() =>
      (ref1(token, 'or') & ref0(unionMemberType) & ref0(unionMemberTypes))
          .optional();

  /// A `DistinguishableType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-DistinguishableType).
  Parser distinguishableType() {
    final sequenceType = ref1(token, 'sequence') &
        ref1(token, '<') &
        ref0(typeWithExtendedAttributes) &
        ref1(token, '>');
    final frozenArrayType = ref1(token, 'FrozenArray') &
        ref1(token, '<') &
        ref0(typeWithExtendedAttributes) &
        ref1(token, '>');
    final observableArrayType = ref1(token, 'ObservableArray') &
        ref1(token, '<') &
        ref0(typeWithExtendedAttributes) &
        ref1(token, '>');

    final types = ref0(primitiveType) |
        ref0(stringType) |
        sequenceType |
        ref1(token, 'object') |
        ref1(token, 'symbol') |
        ref0(bufferRelatedType) |
        frozenArrayType |
        observableArrayType |
        ref0(recordType) |
        // This is purposefully at the bottom since its a catch all
        ref0(identifier);

    return types & ref0(nullable);
  }

  /// A `PrimitiveType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PrimitiveType).
  Parser primitiveType() =>
      ref0(unsignedIntegerType) |
      ref0(unrestrictedFloatType) |
      ref1(token, 'undefined') |
      ref1(token, 'boolean') |
      ref1(token, 'byte') |
      ref1(token, 'octet') |
      ref1(token, 'bigint');

  /// An `UnrestrictedFloatType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-UnrestrictedFloatType).
  Parser unrestrictedFloatType() =>
      ref1(token, 'unrestricted').optional() & ref0(floatType);

  /// A `FloatType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-FloatType).
  Parser floatType() => ref1(token, 'float') | ref1(token, 'double');

  /// An `UnsignedIntegerType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-UnsignedIntegerType).
  Parser unsignedIntegerType() =>
      ref1(token, 'unsigned').optional() & ref0(integerType);

  /// An `IntegerType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-IntegerType).
  Parser integerType() =>
      ref1(token, 'short') | (ref1(token, 'long') & ref0(optionalLong));

  /// A `OptionalLong` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OptionalLong).
  Parser optionalLong() => ref1(token, 'long').optional();

  /// A `StringType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-StringType).
  Parser stringType() =>
      refBuiltinType(token, 'ByteString') |
      refBuiltinType(token, 'DOMString') |
      refBuiltinType(token, 'USVString');

  /// A `PromiseType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PromiseType).
  Parser promiseType() =>
      ref1(token, 'Promise') & ref1(token, '<') & ref0(type) & ref1(token, '>');

  /// A `RecordType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-RecordType).
  Parser recordType() =>
      ref1(token, 'record') &
      ref1(token, '<') &
      ref0(stringType) &
      ref1(token, ',') &
      ref0(typeWithExtendedAttributes) &
      ref1(token, '>');

  /// A `Null` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Null).
  Parser nullable() => ref1(token, '?').optional();

  /// A `BufferRelatedType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-BufferRelatedType).
  Parser bufferRelatedType() =>
      refBuiltinType(token, 'ArrayBuffer') |
      refBuiltinType(token, 'DataView') |
      refBuiltinType(token, 'Int8Array') |
      refBuiltinType(token, 'Int16Array') |
      refBuiltinType(token, 'Int32Array') |
      refBuiltinType(token, 'Uint8Array') |
      refBuiltinType(token, 'Uint16Array') |
      refBuiltinType(token, 'Uint32Array') |
      refBuiltinType(token, 'Uint8ClampedArray') |
      refBuiltinType(token, 'Float32Array') |
      refBuiltinType(token, 'Float64Array');

  //------------------------------------------------------------------
  // Extended Attributes
  //
  // The WebIDL grammar supports a more general definition for
  // extended attributes but notes that really only 5 variants are
  // actually used. So this only matches those 5 cases.
  //------------------------------------------------------------------

  /// An `ExtendedAttributeList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeList).
  Parser extendedAttributeList() {
    final attributes = ref1(token, '[') &
        ref0(extendedAttribute) &
        ref0(extendedAttributes) &
        ref1(token, ']');

    return attributes.optional();
  }

  /// An `ExtendedAttributes` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributes).
  Parser extendedAttributes() =>
      (ref1(token, ',') & ref0(extendedAttribute) & ref0(extendedAttributes))
          .optional();

  /// An `ExtendedAttribute` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttribute).
  Parser extendedAttribute() =>
      ref0(extendedAttributeArgList) |
      ref0(extendedAttributeIdent) |
      ref0(extendedAttributeIdentList) |
      ref0(extendedAttributeNamedArgList) |
      ref0(extendedAttributeNoArgs);

  /// An `IdentifierList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-IdentifierList).
  Parser identifierList() => ref0(identifier) & ref0(identifiers);

  /// An `Identifiers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Identifiers).
  Parser identifiers() =>
      (ref1(token, ',') & ref0(identifier) & ref0(identifiers)).optional();

  /// An `ExtendedAttributeNoArgs` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeNoArgs).
  Parser extendedAttributeNoArgs() => ref0(identifier);

  /// An `ExtendedAttributeArgList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeArgList).
  Parser extendedAttributeArgList() =>
      ref0(identifier) &
      ref1(token, '(') &
      ref0(argumentList) &
      ref1(token, ')');

  /// An `ExtendedAttributeIdent` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeIdent).
  Parser extendedAttributeIdent() =>
      ref0(identifier) & ref1(token, '=') & ref0(identifier);

  /// An `ExtendedAttributeIdentList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeIdentList).
  Parser extendedAttributeIdentList() =>
      ref0(identifier) &
      ref1(token, '=') &
      ref1(token, '(') &
      ref0(identifierList) &
      ref1(token, ')');

  /// An `ExtendedAttributeNamedArgList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeNamedArgList).
  Parser extendedAttributeNamedArgList() =>
      ref0(identifier) &
      ref1(token, '=') &
      ref1(token, '(') &
      ref0(argumentList) &
      ref1(token, ')');

  //------------------------------------------------------------------
  // Lexical tokens
  //------------------------------------------------------------------

  /// An `Identifier` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#prod-identifier).
  Parser identifier() => ref2(token, ref0(_identifier), 'identifier');
  Parser _identifier() =>
      pattern('_-').optional() &
      pattern('a-zA-Z') &
      pattern('0-9a-zA-Z_-').star();

  /// A `String` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#prod-string).
  Parser stringLiteral() => char('"') & pattern('^"').star() & char('"');

  /// An `Integer` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#prod-integer).
  Parser integer() {
    final numberTypes =
        hexadecimalInteger() | octalInteger() | decimalInteger();

    return char('-').optional() & numberTypes;
  }

  /// A decimal, base 10, `Integer`.
  Parser decimalInteger() => digit().plus();

  /// A hexadecimal, base 16, `Integer`.
  Parser hexadecimalInteger() =>
      string('0x') & ref0(_hexadecimalDigit).plus() |
      string('0X') & ref0(_hexadecimalDigit).plus();

  Parser _hexadecimalDigit() => pattern('0-9a-fA-F');

  /// An octal, base 8, `Integer`.
  Parser octalInteger() => char('0') & pattern('0-7').star();

  /// A `Decimal` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#prod-decimal).
  Parser decimal() {
    // [0-9]+\.[0-9]*|[0-9]*\.[0-9]+
    final group0 = (digit().plus() & char('.') & digit().star()) |
        (digit().star() & char('.') & digit().plus());

    // [Ee][+-]?[0-9]+
    final group1 = pattern('Ee') & pattern('+-').optional() & digit().plus();

    // [0-9]+[Ee][+-]?[0-9]+
    final group2 = digit().plus() &
        pattern('Ee') &
        pattern('+-').optional() &
        digit().plus();

    // -?((group0)(group1)?|group2)
    return char('-').optional() & group0 & group1.optional() | group2;
  }

  // -----------------------------------------------------------------
  // Whitespace and comments.
  // -----------------------------------------------------------------

  Parser _hidden() => ref0(_hiddenStuff).plus();

  Parser _hiddenStuff() =>
      whitespace() | ref0(_singleLineComment) | ref0(_multiLineComment);

  Parser _singleLineComment() =>
      string('//') & ref0(_newLine).neg().star() & ref0(_newLine).optional();

  Parser _multiLineComment() =>
      string('/*') &
      (ref0(_multiLineComment) | string('*/').neg()).star() &
      string('*/');

  Parser _newLine() => pattern('\n\r');

  //------------------------------------------------------------------
  // Keyword definitions.
  //------------------------------------------------------------------

  /// The `async` keyword.
  Parser asyncKeyword() => refKeyword(token, keywords.async);

  /// The `attribute` keyword.
  Parser attributeKeyword() => refKeyword(token, keywords.attribute);

  /// The `callback` keyword.
  Parser callbackKeyword() => refKeyword(token, keywords.callback);

  /// The `const` keyword.
  Parser constKeyword() => refKeyword(token, keywords.constant);

  /// The `constructor` keyword.
  Parser constructorKeyword() => refKeyword(token, keywords.constructor);

  /// The `deleter` keyword.
  Parser deleterKeyword() => refKeyword(token, keywords.deleter);

  /// The `dictionary` keyword.
  Parser dictionaryKeyword() => refKeyword(token, keywords.dictionary);

  /// The `enum` keyword.
  Parser enumKeyword() => refKeyword(token, keywords.enumeration);

  /// The `getter` keyword.
  Parser getterKeyword() => refKeyword(token, keywords.getter);

  /// The `includes` keyword.
  Parser includesKeyword() => refKeyword(token, keywords.includes);

  /// The `inherit` keyword.
  Parser inheritKeyword() => refKeyword(token, keywords.inherit);

  /// The `interface` keyword.
  Parser interfaceKeyword() => refKeyword(token, keywords.interface);

  /// The `iterable` keyword.
  Parser iterableKeyword() => refKeyword(token, keywords.iterable);

  /// The `maplike` keyword.
  Parser maplikeKeyword() => refKeyword(token, keywords.maplike);

  /// The `mixin` keyword.
  Parser mixinKeyword() => refKeyword(token, keywords.mixin);

  /// The `namespace` keyword.
  Parser namespaceKeyword() => refKeyword(token, keywords.namespace);

  /// The `partial` keyword.
  Parser partialKeyword() => refKeyword(token, keywords.partial);

  /// The `readonly` keyword.
  Parser readonlyKeyword() => refKeyword(token, keywords.readonly);

  /// The `required` keyword.
  Parser requiredKeyword() => refKeyword(token, keywords.required);

  /// The `setlike` keyword.
  Parser setlikeKeyword() => refKeyword(token, keywords.setlike);

  /// The `setter` keyword.
  Parser setterKeyword() => refKeyword(token, keywords.setter);

  /// The `static` keyword.
  Parser staticKeyword() => refKeyword(token, keywords.static);

  /// The `stringifier` keyword.
  Parser stringifierKeyword() => refKeyword(token, keywords.stringifier);

  /// The `typedef` keyword.
  Parser typedefKeyword() => refKeyword(token, keywords.typedef);

  /// The `unrestricted` keyword.
  Parser unrestrictedKeyword() => refKeyword(token, keywords.unrestricted);
}
