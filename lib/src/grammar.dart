// Copyright (c) 2019 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:petitparser/petitparser.dart';

/// WebIDL grammar.
class WebIdlGrammar extends GrammarParser {
  /// Creates an instance of the [WebIdlGrammar] class.
  WebIdlGrammar() : super(WebIdlGrammarDefinition());
}

/// WebIDL grammar definition.
///
/// Implementation of the [WebIDL grammar]
/// (https://heycam.github.io/webidl/#idl-grammar).
class WebIdlGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => ref(definitions).end();

  /// Parses the [input] token.
  Parser token(Object input) {
    if (input is Parser) {
      return input.token().trim(ref(whitespace));
    } else if (input is String) {
      return token(input.length == 1 ? char(input) : string(input));
    } else if (input is Function) {
      return token(ref(input));
    }

    throw ArgumentError.value(input, 'invalid token parser');
  }

  /// The `Definitions` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Definitions).
  ///
  /// This is the root of the grammar.
  Parser definitions() =>
      (ref(extendedAttributeList) & ref(definition) & ref(definition))
          .optional();

  /// A `Definition` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Definition).
  Parser definition() =>
      ref(callbackOrInterfaceOrMixin) |
      ref(namespace) |
      ref(partial) |
      ref(dictionary) |
      ref(enumeration) |
      ref(typeDefinition) |
      ref(includesStatement);

  /// An `ArgumentNameKeyword` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ArgumentNameKeyword).
  Parser argumentNameKeyword() =>
      ref(asyncKeyword) |
      ref(attributeKeyword) |
      ref(callbackKeyword) |
      ref(constKeyword) |
      ref(constructorKeyword) |
      ref(deleterKeyword) |
      ref(dictionaryKeyword) |
      ref(enumKeyword) |
      ref(getterKeyword) |
      ref(includesKeyword) |
      ref(inheritKeyword) |
      ref(interfaceKeyword) |
      ref(iterableKeyword) |
      ref(maplikeKeyword) |
      ref(mixinKeyword) |
      ref(namespaceKeyword) |
      ref(partialKeyword) |
      ref(readonlyKeyword) |
      ref(requiredKeyword) |
      ref(setlikeKeyword) |
      ref(setterKeyword) |
      ref(staticKeyword) |
      ref(stringifierKeyword) |
      ref(typedefKeyword) |
      ref(unrestrictedKeyword);

  /// A `CallbackOrInterfaceOrMixin` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-CallbackOrInterfaceOrMixin).
  Parser callbackOrInterfaceOrMixin() =>
      (ref(callbackKeyword) & ref(callbackRestOrInterface)) |
      (ref(interfaceKeyword) & ref(interfaceOrMixin));

  /// An `InterfaceOrMixin` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-InterfaceOrMixin).
  Parser interfaceOrMixin() => ref(interfaceRest) | ref(mixinRest);

  /// An `InterfaceRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-InterfaceRest).
  Parser interfaceRest() =>
      ref(identifier) &
      ref(inheritance) &
      ref(token, '{') &
      ref(interfaceMembers) &
      ref(token, '}') &
      ref(token, ';');

  /// A `Partial` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Partial).
  Parser partial() => ref(partialKeyword) & ref(partialDefinition);

  /// A `PartialDefinition` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PartialDefinition).
  Parser partialDefinition() =>
      (ref(interfaceKeyword) & ref(partialInterfaceOrPartialMixin)) |
      ref(partialDictionary) |
      ref(namespace);

  /// A `PartialInterfaceOrPartialMixin` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PartialInterfaceOrPartialMixin).
  Parser partialInterfaceOrPartialMixin() =>
      ref(partialInterfaceRest) | ref(mixinRest);

  /// A `PartialInterfaceRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PartialInterfaceRest).
  Parser partialInterfaceRest() =>
      ref(identifier) &
      ref(token, '{') &
      ref(partialInterfaceMembers) &
      ref(token, '}') &
      ref(token, ';');

  /// An `InterfaceMembers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-InterfaceMembers).
  Parser interfaceMembers() => (ref(identifier) &
          ref(token, '{') &
          ref(partialInterfaceMembers) &
          ref(token, '}') &
          ref(token, ';'))
      .optional();

  /// An `InterfaceMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-InterfaceMember).
  Parser interfaceMember() => ref(partialInterfaceMember) | ref(constructor);

  /// A `PartialInterfaceMembers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PartialInterfaceMembers).
  Parser partialInterfaceMembers() => (ref(extendedAttributeList) &
          ref(partialInterfaceMember) &
          ref(partialInterfaceMembers))
      .optional();

  /// A `PartialInterfaceMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PartialInterfaceMember).
  Parser partialInterfaceMember() =>
      ref(constant) |
      ref(operation) |
      ref(stringifier) |
      ref(staticMember) |
      ref(iterable) |
      ref(asyncIterable) |
      ref(readOnlyMember) |
      ref(readWriteAttribute) |
      ref(readWriteMaplike) |
      ref(readWriteSetlike);

  /// An `Inheritance` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Inheritance).
  Parser inheritance() => (ref(token, ':') & ref(identifier)).optional();

  /// A `MixinRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-MixinRest).
  Parser mixinRest() =>
      ref(mixinKeyword) &
      ref(identifier) &
      ref(token, '{') &
      ref(mixinMembers) &
      ref(token, '}') &
      ref(token, ';');

  /// A `MixinMembers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-MixinMembers).
  Parser mixinMembers() =>
      (ref(extendedAttributeList) & ref(mixinMember) & ref(mixinMembers))
          .optional();

  /// A `MixinMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-MixinMember).
  Parser mixinMember() =>
      ref(constant) |
      ref(regularOperation) |
      ref(stringifier) |
      (ref(readOnly) & ref(attributeRest));

  /// An `IncludesStatement` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-IncludesStatement).
  Parser includesStatement() =>
      ref(identifier) &
      ref(includesKeyword) &
      ref(identifier) &
      ref(token, ';');

  /// A `CallbackRestOrInterface` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-CallbackRestOrInterface).
  Parser callbackRestOrInterface() =>
      ref(callbackRest) |
      (ref(interfaceKeyword) &
          ref(identifier) &
          ref(token, '{') &
          ref(callbackInterfaceMembers) &
          ref(token, '}') &
          ref(token, ';'));

  /// A `CallbackInterfaceMembers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-CallbackInterfaceMembers).
  Parser callbackInterfaceMembers() => (ref(extendedAttributeList) &
          ref(callbackInterfaceMember) &
          ref(callbackInterfaceMembers))
      .optional();

  /// A `CallbackInterfaceMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-CallbackInterfaceMember).
  Parser callbackInterfaceMember() => ref(constant) | ref(regularOperation);

  /// A `Const` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Const).
  Parser constant() =>
      ref(constKeyword) &
      ref(constantType) &
      ref(identifier) &
      ref(token, '=') &
      ref(constantValue) &
      ref(token, ';');

  /// A `ConstValue` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ConstValue).
  Parser constantValue() =>
      ref(booleanLiteral) | ref(floatLiteral) | ref(integer);

  /// A `BooleanLiteral` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-BooleanLiteral).
  Parser booleanLiteral() => ref(token, 'true') | ref(token, 'false');

  /// A `FloatLiteral` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-FloatLiteral).
  Parser floatLiteral() =>
      ref(decimal) |
      ref(token, '-Infinity') |
      ref(token, 'Infinity') |
      ref(token, 'NaN');

  /// A `ConstType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ConstType).
  Parser constantType() => ref(primitiveType) | ref(identifier);

  /// A `ReadOnlyMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ReadOnlyMember).
  Parser readOnlyMember() => ref(readonlyKeyword) & ref(readOnlyMemberRest);

  /// A `ReadOnlyMemberRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ReadOnlyMemberRest).
  Parser readOnlyMemberRest() =>
      ref(attributeRest) | ref(maplikeRest) | ref(setlikeRest);

  /// A `ReadWriteAttribute` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ReadWriteAttribute).
  Parser readWriteAttribute() =>
      (ref(inheritKeyword) & ref(attributeRest)) | ref(attributeRest);

  /// An `AttributeRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-AttributeRest).
  Parser attributeRest() =>
      ref(attributeKeyword) &
      ref(typeWithExtendedAttributes) &
      ref(attributeName) &
      ref(token, ';');

  /// An `AttributeName` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-AttributeName).
  Parser attributeName() => ref(attributeNameKeyword) | ref(identifier);

  /// An `AttributeNameKeyword` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-AttributeNameKeyword).
  Parser attributeNameKeyword() => ref(asyncKeyword) | ref(requiredKeyword);

  /// A `ReadOnly` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ReadOnly).
  Parser readOnly() => ref(readonlyKeyword).optional();

  /// A `DefaultValue` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-DefaultValue).
  Parser defaultValue() =>
      ref(constantValue) |
      //ref(string) |
      (ref(token, '[') & ref(token, ']')) |
      (ref(token, '{') & ref(token, '}') | ref(token, 'null'));

  /// An `Operation` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Operation).
  Parser operation() => ref(regularOperation) | ref(specialOperation);

  /// A `RegularOperation` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-RegularOperation).
  Parser regularOperation() => ref(returnType) & ref(operationRest);

  /// A `SpecialOperation` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-SpecialOperation).
  Parser specialOperation() => ref(special) & ref(regularOperation);

  /// A `Special` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Special).
  Parser special() =>
      ref(getterKeyword) | ref(setterKeyword) | ref(deleterKeyword);

  /// An `OperationRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OperationRest).
  Parser operationRest() =>
      ref(optionalOperationName) &
      ref(token, '(') &
      ref(argumentList) &
      ref(token, ')') &
      ref(token, ';');

  /// An `OptionalOperationName` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OptionalOperationName).
  Parser optionalOperationName() => ref(operationName).optional();

  /// An `OperationName` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OperationName).
  Parser operationName() => ref(operationNameKeyword) | ref(identifier);

  /// An `OperationNameKeyword` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OperationNameKeyword).
  Parser operationNameKeyword() => ref(includesKeyword);

  /// An `ArgumentList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ArgumentList).
  Parser argumentList() => (ref(argument) & ref(arguments)).optional();

  /// An `Arguments` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Arguments).
  Parser arguments() =>
      (ref(token, ',') & ref(argument) & ref(arguments)).optional();

  /// An `Argument` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Argument).
  Parser argument() => ref(extendedAttributeList) & ref(argumentRest);

  /// An `ArgumentRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ArgumentRest).
  Parser argumentRest() =>
      (ref(token, 'optional') &
          ref(typeWithExtendedAttributes) &
          ref(argumentName) &
          ref(defaultTo)) |
      (ref(type) & ref(ellipsis) & ref(argumentName));

  /// An `ArgumentName` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ArgumentName).
  Parser argumentName() => ref(identifier);

  /// An `Ellipsis` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Ellipsis).
  Parser ellipsis() => ref(token, '...').optional();

  /// A `ReturnType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ReturnType).
  Parser returnType() => ref(type) | ref(token, 'void');

  /// A `Constructor` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Constructor).
  Parser constructor() =>
      ref(constructorKeyword) &
      ref(token, '(') &
      ref(argumentList) &
      ref(token, ')') &
      ref(token, ';');

  /// A `Stringifier` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Stringifier).
  Parser stringifier() => ref(stringifierKeyword) & ref(stringifierRest);

  /// A `StringifierRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-StringifierRest).
  Parser stringifierRest() =>
      (ref(readOnly) & ref(attributeRest)) |
      ref(regularOperation) |
      ref(token, ';');

  /// A `StaticMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-StaticMember).
  Parser staticMember() => ref(staticKeyword) & ref(staticMemberRest);

  /// A `StaticMemberRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-StaticMemberRest).
  Parser staticMemberRest() =>
      (ref(readOnly) & ref(attributeRest)) | ref(regularOperation);

  /// An `Iterable` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Iterable).
  Parser iterable() =>
      ref(iterableKeyword) &
      ref(token, '<') &
      ref(typeWithExtendedAttributes) &
      ref(optionalType) &
      ref(token, '>') &
      ref(token, ';');

  /// An `OptionalType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OptionalType).
  Parser optionalType() =>
      (ref(token, ',') & ref(typeWithExtendedAttributes)).optional();

  /// An `AsyncIterable` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-AsyncIterable).
  Parser asyncIterable() =>
      ref(asyncKeyword) &
      ref(iterableKeyword) &
      ref(token, '<') &
      ref(typeWithExtendedAttributes) &
      ref(token, ',') &
      ref(typeWithExtendedAttributes) &
      ref(token, '>') &
      ref(token, ';');

  /// A `ReadWriteMaplike` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ReadWriteMaplike).
  Parser readWriteMaplike() => ref(maplikeRest);

  /// A `MaplikeRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-MaplikeRest).
  Parser maplikeRest() =>
      ref(maplikeKeyword) &
      ref(token, '<') &
      ref(typeWithExtendedAttributes) &
      ref(token, ',') &
      ref(typeWithExtendedAttributes) &
      ref(token, '>') &
      ref(token, ';');

  /// A `ReadWriteSetlike` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ReadWriteSetlike).
  Parser readWriteSetlike() => ref(setlikeRest);

  /// A `SetlikeRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-SetlikeRest).
  Parser setlikeRest() =>
      ref(setlikeKeyword) &
      ref(token, '<') &
      ref(typeWithExtendedAttributes) &
      ref(token, '>') &
      ref(token, ';');

  /// A `Namespace` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Namespace).
  Parser namespace() =>
      ref(namespaceKeyword) &
      ref(identifier) &
      ref(token, '{') &
      ref(namespaceMembers) &
      ref(token, '}') &
      ref(token, ';');

  /// A `NamespaceMembers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-NamespaceMembers).
  Parser namespaceMembers() => (ref(extendedAttributeList) &
          ref(namespaceMember) &
          ref(namespaceMembers))
      .optional();

  /// A `NamespaceMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-NamespaceMember).
  Parser namespaceMember() =>
      ref(regularOperation) | (ref(readonlyKeyword) & ref(attributeRest));

  /// A `Dictionary` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Dictionary).
  Parser dictionary() =>
      ref(dictionaryKeyword) &
      ref(identifier) &
      ref(inheritance) &
      ref(token, '{') &
      ref(dictionaryMembers) &
      ref(token, '}') &
      ref(token, ';');

  /// A `DictionaryMembers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-DictionaryMembers).
  Parser dictionaryMembers() =>
      (ref(dictionaryMember) & ref(dictionaryMembers)).optional();

  /// A `DictionaryMember` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-DictionaryMember).
  Parser dictionaryMember() =>
      ref(extendedAttributeList) & ref(dictionaryMemberRest);

  /// A `DictionaryMemberRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-DictionaryMemberRest).
  Parser dictionaryMemberRest() =>
      (ref(requiredKeyword) &
          ref(typeWithExtendedAttributes) &
          ref(identifier) &
          ref(token, ';')) |
      (ref(type) & ref(identifier) & ref(defaultTo) & ref(token, ';'));

  /// A `PartialDictionary` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PartialDictionary).
  Parser partialDictionary() =>
      ref(dictionaryKeyword) &
      ref(identifier) &
      ref(token, '{') &
      ref(dictionaryMembers) &
      ref(token, '}') &
      ref(token, ';');

  /// A `Default` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Default).
  Parser defaultTo() => (ref(token, '=') & ref(defaultValue)).optional();

  /// An `Enum` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Enum).
  Parser enumeration() =>
      ref(enumKeyword) &
      ref(identifier) &
      ref(token, '{') &
      ref(enumerationValueList) &
      ref(token, '}') &
      ref(token, ';');

  /// An `EnumValueList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-EnumValueList).
  Parser enumerationValueList() => ref(string) & ref(enumerationValueListComma);

  /// An `EnumValueListComma` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-EnumValueListComma).
  Parser enumerationValueListComma() =>
      (ref(token, ',') & ref(enumerationValueListString)).optional();

  /// An `EnumValueListString` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-EnumValueListString).
  Parser enumerationValueListString() =>
      (ref(string) & ref(enumerationValueListComma)).optional();

  /// A `CallbackRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-CallbackRest).
  Parser callbackRest() =>
      ref(identifier) &
      ref(token, '=') &
      ref(returnType) &
      ref(token, '(') &
      ref(argumentList) &
      ref(token, ')');

  /// A `Typedef` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Typedef).
  Parser typeDefinition() =>
      ref(typedefKeyword) &
      ref(typeWithExtendedAttributes) &
      ref(identifier) &
      ref(token, ';');

  /// A `Type` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Type).
  Parser type() => ref(singleType) | (ref(unionType) & ref(nullable));

  /// A `TypeWithExtendedAttributes` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-TypeWithExtendedAttributes).
  Parser typeWithExtendedAttributes() => ref(extendedAttributeList) & ref(type);

  /// A `SingleType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-SingleType).
  Parser singleType() =>
      ref(distinguishableType) | ref(token, 'any') | ref(promiseType);

  /// An `UnionType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-UnionType).
  Parser unionType() =>
      ref(token, '(') &
      ref(unionMemberType) &
      ref(token, 'or') &
      ref(unionMemberType) &
      ref(unionMemberTypes) &
      ref(token, ')');

  /// An `UnionMemberType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-UnionMemberType).
  Parser unionMemberType() =>
      (ref(extendedAttributeList) & ref(distinguishableType)) |
      (ref(unionType) & ref(nullable));

  /// An `UnionMemberTypes` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-UnionMemberTypes).
  Parser unionMemberTypes() =>
      (ref(token, 'or') & ref(unionMemberType) & ref(unionMemberTypes))
          .optional();

  /// A `DistinguishableType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-DistinguishableType).
  Parser distinguishableType() =>
      (ref(primitiveType) |
          ref(stringType) |
          ref(identifier) |
          (ref(token, 'sequence') &
              ref(token, '<') &
              ref(token, typeWithExtendedAttributes) &
              ref(token, '>')) |
          ref(token, 'object') |
          ref(token, 'symbol') |
          ref(bufferRelatedType) |
          (ref(token, 'FrozenArray') &
              ref(token, '<') &
              ref(typeWithExtendedAttributes) &
              ref(token, '>')) |
          ref(recordType)) &
      ref(nullable);

  /// A `PrimitiveType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PrimitiveType).
  Parser primitiveType() =>
      ref(unsignedIntegerType) |
      ref(unrestrictedFloatType) |
      ref(token, 'boolean') |
      ref(token, 'byte') |
      ref(token, 'octet');

  /// An `UnrestrictedFloatType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-UnrestrictedFloatType).
  Parser unrestrictedFloatType() =>
      ref(token, 'unrestricted').optional() & ref(floatType);

  /// A `FloatType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-FloatType).
  Parser floatType() => ref(token, 'float') | ref(token, 'double');

  /// An `UnsignedIntegerType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-UnsignedIntegerType).
  Parser unsignedIntegerType() =>
      ref(token, 'unsigned').optional() & ref(integerType);

  /// An `IntegerType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-IntegerType).
  Parser integerType() =>
      ref(token, 'short') | (ref(token, 'long') & ref(optionalLong));

  /// A `OptionalLong` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OptionalLong).
  Parser optionalLong() => ref(token, 'long').optional();

  /// A `StringType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-StringType).
  Parser stringType() =>
      ref(token, 'ByteString') |
      ref(token, 'DOMString') |
      ref(token, 'USVString');

  /// A `PromiseType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-PromiseType).
  Parser promiseType() =>
      ref(token, 'Promise') &
      ref(token, '<') &
      ref(returnType) &
      ref(token, '>');

  /// A `RecordType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-RecordType).
  Parser recordType() =>
      ref(token, 'record') &
      ref(token, '<') &
      ref(typeWithExtendedAttributes) &
      ref(token, '>');

  /// A `Null` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Null).
  Parser nullable() => ref(token, '?').optional();

  /// A `BufferRelatedType` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-BufferRelatedType).
  Parser bufferRelatedType() =>
      ref(token, 'ArrayBuffer') |
      ref(token, 'DataView') |
      ref(token, 'Int8Array') |
      ref(token, 'Int16Array') |
      ref(token, 'Int32Array') |
      ref(token, 'Uint8Array') |
      ref(token, 'Uint16Array') |
      ref(token, 'Uint32Array') |
      ref(token, 'Uint8ClampedArray') |
      ref(token, 'Float32Array') |
      ref(token, 'Float64Array');

  /// An `ExtendedAttributeList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeList).
  Parser extendedAttributeList() => (ref(token, '[') &
          //ref(extendedAttribute) &
          //ref(extendedAttributes) &
          ref(token, ']'))
      .optional();

  /// An `ExtendedAttributes` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributes).
  Parser extendedAttributes() => null;

  /// An `ExtendedAttribute` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttribute).
  Parser extendedAttribute() => null;

  /// An `ExtendedAttributeRest` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeRest).
  Parser extendedAttributeRest() => null;

  /// An `ExtendedAttributeInner` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeInner).
  Parser extendedAttributeInner() => null;

  /// An `Other` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Other).
  Parser other() => null;

  /// An `OtherOrComma` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-OtherOrComma).
  Parser otherOrComma() => null;

  /// An `IdentifierList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-IdentifierList).
  Parser identifierList() => null;

  /// An `Identifiers` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-Identifiers).
  Parser identifiers() => null;

  /// An `ExtendedAttributeNoArgs` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeNoArgs).
  Parser extendedAttributeNoArgs() => null;

  /// An `ExtendedAttributeArgList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeArgList).
  Parser extendedAttributeArgList() => null;

  /// An `ExtendedAttributeIdent` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeIdent).
  Parser extendedAttributeIdent() => null;

  /// An `ExtendedAttributeIdentList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeIdentList).
  Parser extendedAttributeIdentList() => null;

  /// An `ExtendedAttributeNamedArgList` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#index-prod-ExtendedAttributeNamedArgList).
  Parser extendedAttributeNamedArgList() => null;

  //------------------------------------------------------------------
  // Lexical tokens.
  //------------------------------------------------------------------

  /// An `Identifier` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#prod-identifier).
  Parser identifier() => pattern('a-zA-Z_').seq(word().star());

  /// An `Integer` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#prod-integer).
  Parser integer() => ref(digit).plus();

  /// A `Decimal` within the [WebIDL grammar]
  /// (https://heycam.github.io/webidl/#prod-decimal).
  Parser decimal() =>
      char('-').optional() &
      char('0').or(digit().plus()) &
      char('.').seq(digit().plus()).optional() &
      pattern('eE')
          .seq(pattern('-+').optional())
          .seq(digit().plus())
          .optional();

  //------------------------------------------------------------------
  // Keyword definitions.
  //------------------------------------------------------------------

  /// The `async` keyword.
  Parser asyncKeyword() => ref(token, 'async');

  /// The `attribute` keyword.
  Parser attributeKeyword() => ref(token, 'attribute');

  /// The `callback` keyword.
  Parser callbackKeyword() => ref(token, 'callback');

  /// The `const` keyword.
  Parser constKeyword() => ref(token, 'const');

  /// The `constructor` keyword.
  Parser constructorKeyword() => ref(token, 'constructor');

  /// The `deleter` keyword.
  Parser deleterKeyword() => ref(token, 'deleter');

  /// The `dictionary` keyword.
  Parser dictionaryKeyword() => ref(token, 'dictionary');

  /// The `enum` keyword.
  Parser enumKeyword() => ref(token, 'enum');

  /// The `getter` keyword.
  Parser getterKeyword() => ref(token, 'getter');

  /// The `includes` keyword.
  Parser includesKeyword() => ref(token, 'includes');

  /// The `inherit` keyword.
  Parser inheritKeyword() => ref(token, 'inherit');

  /// The `interface` keyword.
  Parser interfaceKeyword() => ref(token, 'interface');

  /// The `iterable` keyword.
  Parser iterableKeyword() => ref(token, 'iterable');

  /// The `maplike` keyword.
  Parser maplikeKeyword() => ref(token, 'maplike');

  /// The `mixin` keyword.
  Parser mixinKeyword() => ref(token, 'mixin');

  /// The `namespace` keyword.
  Parser namespaceKeyword() => ref(token, 'namespace');

  /// The `partial` keyword.
  Parser partialKeyword() => ref(token, 'partial');

  /// The `readonly` keyword.
  Parser readonlyKeyword() => ref(token, 'readonly');

  /// The `required` keyword.
  Parser requiredKeyword() => ref(token, 'required');

  /// The `setlike` keyword.
  Parser setlikeKeyword() => ref(token, 'setlike');

  /// The `setter` keyword.
  Parser setterKeyword() => ref(token, 'setter');

  /// The `static` keyword.
  Parser staticKeyword() => ref(token, 'static');

  /// The `stringifier` keyword.
  Parser stringifierKeyword() => ref(token, 'stringifier');

  /// The `typedef` keyword.
  Parser typedefKeyword() => ref(token, 'typedef');

  /// The `unrestricted` keyword.
  Parser unrestrictedKeyword() => ref(token, 'unrestricted');
}
