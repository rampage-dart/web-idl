// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

import 'package:web_idl/web_idl.dart';

import 'utilities.dart';

Future<void> generateGoldenFiles(String directory) async {
  final convertor = _GoldenFileGenerator();
  const encoder = JsonEncoder.withIndent('  ');

  await for (final file in findTests(directory)) {
    final contents = await file.readAsString();
    final fragment = parseFragment(contents);
    final converted = convertor.visitFragment(fragment);

    final goldenFile = File(
      '$directory/${basenameWithoutExtension(file.path)}.golden.json',
    );
    await goldenFile.writeAsString(encoder.convert(converted));
  }
}

Future<void> main() async {
  await generateGoldenFiles('test/web_idl_spec');
  await generateGoldenFiles('test/web_api_spec');
}

class _GoldenFileGenerator implements ElementVisitor<Map<String, Object?>> {
  @override
  Map<String, Object?> visitFragment(FragmentElement element) =>
      <String, Object?>{
        'interfaces': element.interfaces.map(visitInterface).toList(),
        'namespaces': element.namespaces.map(visitNamespace).toList(),
        'dictionaries': element.dictionaries.map(visitDictionary).toList(),
        'functions': element.functions.map(visitFunctionTypeAlias).toList(),
        'enumerations': element.enumerations.map(visitEnum).toList(),
        'typeDefinitions': element.typeDefinitions.map(visitTypeAlias).toList(),
        'includes': element.includes.map(visitIncludesStatement).toList(),
      };

  @override
  Map<String, Object?> visitDictionary(DictionaryElement element) =>
      <String, Object?>{
        'name': element.name,
        'supertype': _webIdlTypeNullable(element.supertype),
        'partial': element.isPartial,
        'members': element.members.map(visitDictionaryMember).toList(),
      };

  @override
  Map<String, Object?> visitEnum(EnumElement element) => <String, Object?>{
        'name': element.name,
        'values': element.values,
      };

  @override
  Map<String, Object?> visitFunctionTypeAlias(
    FunctionTypeAliasElement element,
  ) =>
      <String, Object?>{
        'name': element.name,
        'returnType': _webIdlType(element.returnType),
        'arguments': element.arguments.map(visitArgument).toList(),
      };

  @override
  Map<String, Object?> visitIncludesStatement(IncludesElement element) =>
      <String, Object?>{
        'name': element.name,
        'on': _webIdlType(element.on),
        'mixin': _webIdlType(element.mixin),
      };

  @override
  Map<String, Object?> visitInterface(InterfaceElement element) =>
      <String, Object?>{
        'name': element.name,
        'supertype': _webIdlTypeNullable(element.supertype),
        'partial': element.isPartial,
        'mixin': element.isMixin,
        'callback': element.isCallback,
        'constructors': element.constructors.map(visitOperation).toList(),
        'attributes': element.attributes.map(visitAttribute).toList(),
        'operations': element.operations.map(visitOperation).toList(),
        'constants': element.constants.map(visitConstant).toList(),
      };

  @override
  Map<String, Object?> visitNamespace(NamespaceElement element) =>
      <String, Object?>{
        'name': element.name,
        'partial': element.isPartial,
        'attributes': element.attributes.map(visitAttribute).toList(),
        'operations': element.operations.map(visitOperation).toList(),
        'constants': element.constants.map(visitConstant).toList(),
      };

  @override
  Map<String, Object?> visitTypeAlias(TypeAliasElement element) =>
      <String, Object?>{
        'name': element.name,
        'type': _webIdlType(element.type),
      };

  @override
  Map<String, Object?> visitAttribute(AttributeElement element) =>
      <String, Object?>{
        'name': element.name,
        'type': _webIdlType(element.type),
        'static': element.isStatic,
        'readOnly': element.readOnly,
      };

  @override
  Map<String, Object?> visitArgument(ArgumentElement element) =>
      <String, Object?>{
        'name': element.name,
        'type': _webIdlType(element.type),
        'isOptional': element.isOptional,
        'isVariadic': element.isVariadic,
        'defaultTo': element.defaultTo,
      };

  @override
  Map<String, Object?> visitConstant(ConstantElement element) =>
      <String, Object?>{
        'name': element.name,
        'type': _webIdlType(element.type),
        'value': element.value,
      };

  @override
  Map<String, Object?> visitDictionaryMember(DictionaryMemberElement element) =>
      <String, Object?>{
        'name': element.name,
        'type': _webIdlType(element.type),
        'isRequired': element.isRequired,
        'defaultTo': element.defaultTo,
      };

  @override
  Map<String, Object?> visitOperation(OperationElement element) =>
      <String, Object?>{
        'name': element.name,
        'returnType': _webIdlType(element.returnType),
        'arguments': element.arguments.map(visitArgument).toList(),
        'static': element.isStatic,
        'operationType': _specialOperation(element.operationType),
      };

  String? _specialOperation(SpecialOperation? operation) {
    if (operation == null) {
      return 'null';
    }

    switch (operation) {
      case SpecialOperation.getter:
        return 'getter';
      case SpecialOperation.setter:
        return 'setter';
      case SpecialOperation.deleter:
        return 'deleter';
    }
  }

  Object? _webIdlTypeNullable(WebIdlType? type) =>
      type != null ? _webIdlType(type) : null;

  Object _webIdlType(WebIdlType type) =>
      type is SingleType ? _singleType(type) : _unionType(type as UnionType);

  String _singleType(SingleType type) {
    final typeArguments = type.typeArguments;
    final typeArgumentDeclaration = typeArguments.isNotEmpty
        ? '<${typeArguments.map(_webIdlType).join(',')}>'
        : '';

    return '${type.name}$typeArgumentDeclaration${type.isNullable ? '?' : ''}';
  }

  String _unionType(UnionType type) {
    final joined = type.memberTypes.map(_webIdlType).join(' or ');

    return '($joined)${type.isNullable ? '?' : ''}';
  }
}
