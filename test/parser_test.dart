// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'package:web_idl/web_idl.dart';
import 'package:web_idl/src/parser/parser.dart';
import 'package:web_idl/src/parser/type_builder.dart';

import 'strings/types.dart' as string_types;

void acceptAll(Parser parser, Map<String, Object?> inputs) {
  inputs.forEach((input, expected) {
    final actual = parser.parse(input);
    expect(actual.value, equals(expected));
  });
}

void acceptAllDoubles(Parser parser, Map<String, double> inputs) {
  inputs.forEach((input, expected) {
    final actual = parser.parse(input);
    expect(actual.value, closeTo(expected, 0.0001));
  });
}

void acceptType(WebIdlType actual, Map<String, Object> expected) =>
    actual is SingleType
        ? acceptSingleType(actual, expected)
        : acceptUnionType(actual as UnionType, expected);

void acceptSingleType(SingleType actual, Map<String, Object> expected) {
  expect(actual.name, equals(expected['name']));
  expect(actual.isNullable, equals(expected['isNullable']));
  expect(actual.extendedAttributes, equals(expected['extendedAttributes']));

  final expectedTypeArguments =
      expected['typeArguments']! as List<Map<String, Object>>;
  final expectedCount = expectedTypeArguments.length;
  expect(actual.typeArguments, hasLength(expectedCount));

  for (var i = 0; i < expectedCount; ++i) {
    acceptType(actual.typeArguments[i], expectedTypeArguments[i]);
  }
}

void acceptAllSingleTypes(
  Parser<WebIdlTypeBuilder> parser,
  Map<String, Map<String, Object>> inputs,
) {
  inputs.forEach((input, expected) {
    final actual = parser.parse(input).value.build() as SingleType;
    acceptSingleType(actual, expected);
  });
}

void acceptUnionType(UnionType actual, Map<String, Object> expected) {
  expect(actual.isNullable, equals(expected['isNullable']));
  expect(actual.extendedAttributes, equals(expected['extendedAttributes']));

  final expectedMemberTypes =
      expected['memberTypes']! as List<Map<String, Object>>;
  final expectedCount = expectedMemberTypes.length;
  expect(actual.memberTypes, hasLength(expectedCount));

  for (var i = 0; i < expectedCount; ++i) {
    acceptType(actual.memberTypes[i], expectedMemberTypes[i]);
  }
}

void acceptAllUnionTypes(
  Parser<WebIdlTypeBuilder> parser,
  Map<String, Map<String, Object>> inputs,
) {
  inputs.forEach((input, expected) {
    final actual = parser.parse(input).value.build() as UnionType;
    acceptUnionType(actual, expected);
  });
}

void main() {
  final grammar = WebIdlParserDefinition();

  test('Type', () {
    final parser = grammar.build<WebIdlTypeBuilder>(start: grammar.type).end();
    acceptAllSingleTypes(parser, _singleTypes);
    acceptAllUnionTypes(parser, _unionTypes);
    acceptAllUnionTypes(parser, _nullableUnionTypes);
  });
  test('SingleType', () {
    acceptAllSingleTypes(
      grammar.build<SingleTypeBuilder>(start: grammar.singleType).end(),
      _singleTypes,
    );
  });
  test('UnionType', () {
    final parser =
        grammar.build<UnionTypeBuilder>(start: grammar.unionType).end();
    acceptAllUnionTypes(parser, _unionTypes);

    // Create a nested union type
    final nestedUnionType = _unionType(
      <Map<String, Object>>[
        _singleType('double'),
        _unionTypeFromString('(sequence<long> or Event)'),
        _unionTypeFromString('(Node or DOMString)?'),
      ],
    );

    acceptAllUnionTypes(parser, <String, Map<String, Object>>{
      '(double or (sequence<long> or Event) or (Node or DOMString)?)':
          nestedUnionType
    });
  });
  test('DistinguishableType', () {
    acceptAllSingleTypes(
      grammar
          .build<SingleTypeBuilder>(start: grammar.distinguishableType)
          .end(),
      _distinguishableTypes,
    );
  });
  test('PrimitiveType', () {
    acceptAllSingleTypes(
      grammar.build<SingleTypeBuilder>(start: grammar.primitiveType).end(),
      _primitiveTypes,
    );
  });
  test('UnrestrictedFloatType', () {
    acceptAllSingleTypes(
      grammar
          .build<SingleTypeBuilder>(start: grammar.unrestrictedFloatType)
          .end(),
      _unrestrictedFloatTypes,
    );
  });
  test('FloatType', () {
    acceptAllSingleTypes(
      grammar.build<SingleTypeBuilder>(start: grammar.floatType).end(),
      _floatTypes,
    );
  });
  test('UnsignedIntegerType', () {
    acceptAllSingleTypes(
      grammar
          .build<SingleTypeBuilder>(start: grammar.unsignedIntegerType)
          .end(),
      _unsignedIntegerTypes,
    );
  });
  test('IntegerType', () {
    acceptAllSingleTypes(
      grammar.build<SingleTypeBuilder>(start: grammar.integerType).end(),
      _integerTypes,
    );
  });
  test('StringType', () {
    acceptAllSingleTypes(
      grammar.build<SingleTypeBuilder>(start: grammar.stringType).end(),
      _stringTypes,
    );
  });
  test('Promise', () {
    acceptAllSingleTypes(
      grammar.build<SingleTypeBuilder>(start: grammar.promiseType).end(),
      _promiseTypes,
    );
  });
  test('RecordType', () {
    acceptAllSingleTypes(
      grammar.build<SingleTypeBuilder>(start: grammar.recordType).end(),
      _recordTypes,
    );
  });
  test('BufferRelatedType', () {
    acceptAllSingleTypes(
      grammar.build<SingleTypeBuilder>(start: grammar.bufferRelatedType).end(),
      _bufferRelatedTypes,
    );
  });
  test('BooleanLiteral', () {
    final parser = grammar.build<bool>(start: grammar.booleanLiteral).end();
    expect(parser.parse('true').value, isTrue);
    expect(parser.parse('false').value, isFalse);
  });
  test('FloatLiteral', () {
    final parser = grammar.build<double>(start: grammar.floatLiteral).end();
    expect(parser.parse('-Infinity').value, equals(double.negativeInfinity));
    expect(parser.parse('Infinity').value, equals(double.infinity));
    expect(parser.parse('NaN').value, isNaN);

    // Decimal
    acceptAllDoubles(parser, _decimalValues);
  });
  test('DefaultValue', () {
    final parser = grammar.build<Object?>(start: grammar.defaultValue).end();

    final aList = parser.parse('[]').value;
    expect(aList, isA<List<Object?>>());
    expect(aList, isEmpty);

    final aMap = parser.parse('{}').value;
    expect(aMap, isA<Map<String, Object?>>());
    expect(aMap, isEmpty);

    expect(parser.parse('null').value, isNull);

    // BooleanLiteral
    expect(parser.parse('true').value, isTrue);
    expect(parser.parse('false').value, isFalse);

    // FloatLiteral
    expect(parser.parse('-Infinity').value, equals(double.negativeInfinity));
    expect(parser.parse('Infinity').value, equals(double.infinity));
    expect(parser.parse('NaN').value, isNaN);

    // String
    acceptAll(parser, _stringValues);
    // Integer
    acceptAll(parser, _integerValues);
    // Decimal
    acceptAllDoubles(parser, _decimalValues);
  });
  test('String', () {
    final parser = grammar.build<String>(start: grammar.stringLiteral).end();
    acceptAll(parser, _stringValues);
  });
  test('Integer', () {
    final parser = grammar.build<int>(start: grammar.integer).end();
    acceptAll(parser, _integerValues);
    final negative = _integerValues.map<String, int>(
      (input, expected) => MapEntry<String, int>('-$input', expected * -1),
    );
    acceptAll(parser, negative);
  });
  test('Decimal', () {
    final parser = grammar.build<double>(start: grammar.decimal).end();
    acceptAllDoubles(parser, _decimalValues);
    final negative = _decimalValues.map<String, double>(
      (input, expected) => MapEntry<String, double>('-$input', expected * -1.0),
    );
    acceptAllDoubles(parser, negative);
  });
}

const _stringValues = <String, String>{
  '"foo"': 'foo',
  '"FOO BAR"': 'FOO BAR',
  '"FOO   BAR   "': 'FOO   BAR   ',
  '"   FOO   BAR"': '   FOO   BAR',
  '"   FOO   BAR   "': '   FOO   BAR   ',
  '"FOO\nBAR"': 'FOO\nBAR',
};

const _integerValues = <String, int>{
  // Decimal integers
  '123': 123,
  // Hexadecimal integers
  '0xff': 255,
  '0': 0,
  // Octal integers
  '02322': 1234,
};

const _decimalValues = <String, double>{
  '0.0': 0.0,
  '1.0': 1.0,
  '2.0': 2.0,
};

//------------------------------------------------------------------
// Type definitions
//
// Used to test that types match within the Grammar.
//------------------------------------------------------------------

final _singleTypeMatcher = RegExp(r'^([-_a-zA-Z0-9 ]+)(<(.*)>)?(\?)?$');
final _unionTypeMatcher = RegExp(r'^\((.+)\)(\?)?$');

Map<String, Object> _typeFromString(String type) =>
    _singleTypeMatcher.hasMatch(type)
        ? _singleTypeFromString(type)
        : _unionTypeFromString(type);

Map<String, Object> _singleType(
  String name, {
  List<Object> extendedAttributes = const <Object>[],
  bool isNullable = false,
  List<Map<String, Object>> typeArguments = const <Map<String, Object>>[],
}) =>
    <String, Object>{
      'name': name,
      'extendedAttributes': extendedAttributes,
      'isNullable': isNullable,
      'typeArguments': typeArguments
    };

Map<String, Object> _unionType(
  List<Map<String, Object>> memberTypes, {
  List<Object> extendedAttributes = const <Object>[],
  bool isNullable = false,
}) =>
    <String, Object>{
      'memberTypes': memberTypes,
      'extendedAttributes': extendedAttributes,
      'isNullable': isNullable,
    };

Map<String, Object> _singleTypeFromString(String type) {
  final match = _singleTypeMatcher.firstMatch(type);
  if (match == null) {
    throw ArgumentError.value(type, 'not a valid single type');
  }

  final typeArgumentsGroup = match.group(3);
  final typeArguments = typeArgumentsGroup != null
      ? typeArgumentsGroup
          .split(',')
          .map((str) => str.trim())
          .map(_typeFromString)
          .toList()
      : const <Map<String, Object>>[];

  return _singleType(
    match.group(1)!,
    isNullable: match.group(4) != null,
    typeArguments: typeArguments,
  );
}

Map<String, Object> _unionTypeFromString(String type) {
  final match = _unionTypeMatcher.firstMatch(type);
  if (match == null) {
    throw ArgumentError.value(type, 'not a valid union type');
  }

  final memberTypesGroup = match.group(1)!;
  final memberTypes = memberTypesGroup
      .split(' or ')
      .map((str) => str.trim())
      .map(_typeFromString)
      .toList();

  return _unionType(memberTypes, isNullable: match.group(2) != null);
}

Map<String, Map<String, Object>> _singleTypesFromStrings(
  Iterable<String> names,
) =>
    Map<String, Map<String, Object>>.fromEntries(
      names.map((type) => MapEntry<String, Map<String, Object>>(
            type,
            _singleTypeFromString(type),
          )),
    );

Map<String, Map<String, Object>> _unionTypesFromString(
  Iterable<String> names,
) =>
    Map<String, Map<String, Object>>.fromEntries(
      names.map((type) => MapEntry<String, Map<String, Object>>(
            type,
            _unionTypeFromString(type),
          )),
    );

final Map<String, Map<String, Object>> _singleTypes =
    _singleTypesFromStrings(string_types.singleTypes);

final Map<String, Map<String, Object>> _unionTypes =
    _unionTypesFromString(string_types.unionTypes);

final Map<String, Map<String, Object>> _nullableUnionTypes =
    _unionTypesFromString(string_types.unionTypes.map(string_types.nullable));

final Map<String, Map<String, Object>> _distinguishableTypes =
    _singleTypesFromStrings(string_types.distinguishableTypes);

final Map<String, Map<String, Object>> _primitiveTypes =
    _singleTypesFromStrings(string_types.primitiveTypes);

final Map<String, Map<String, Object>> _unrestrictedFloatTypes =
    _singleTypesFromStrings(string_types.unrestrictedFloatTypes);

final Map<String, Map<String, Object>> _floatTypes =
    _singleTypesFromStrings(string_types.floatTypes);

final Map<String, Map<String, Object>> _unsignedIntegerTypes =
    _singleTypesFromStrings(string_types.unsignedIntegerTypes);

final Map<String, Map<String, Object>> _integerTypes =
    _singleTypesFromStrings(string_types.integerTypes);

final Map<String, Map<String, Object>> _stringTypes =
    _singleTypesFromStrings(string_types.stringTypes);

final Map<String, Map<String, Object>> _promiseTypes =
    _singleTypesFromStrings(string_types.promiseTypes);

final Map<String, Map<String, Object>> _recordTypes =
    _singleTypesFromStrings(string_types.recordTypes);

final Map<String, Map<String, Object>> _bufferRelatedTypes =
    _singleTypesFromStrings(string_types.bufferRelatedTypes);
