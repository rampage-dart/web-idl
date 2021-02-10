// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'package:web_idl/src/parser/parser.dart';

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

void main() {
  final grammar = WebIdlParserDefinition();

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
