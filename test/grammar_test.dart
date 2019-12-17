// Copyright (c) 2019 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';
import 'package:web_idl/web_idl.dart';

typedef ParserTestFunction = bool Function(String input);

ParserTestFunction accept(Parser parser) =>
    (input) => parser.parse(input).isSuccess;

ParserTestFunction reject(Parser parser) =>
    (input) => parser.parse(input).isFailure;

void main() {
  final grammar = WebIdlGrammarDefinition();
  group('UnrestrictedFloatType', () {
    final parser = grammar.build(start: grammar.unrestrictedFloatType).end();
    test('accept', () {
      expect('unrestricted float', accept(parser));
      expect('unrestricted double', accept(parser));
      expect('float', accept(parser));
      expect('double', accept(parser));
    });
    test('reject', () {
      expect('Foo', reject(parser));
      expect('USVString', reject(parser));
    });
  });
  group('FloatType', () {
    final parser = grammar.build(start: grammar.floatType).end();
    test('accept', () {
      expect('float', accept(parser));
      expect('double', accept(parser));
    });
    test('reject', () {
      expect('Foo', reject(parser));
      expect('USVString', reject(parser));
    });
  });
  group('StringType', () {
    final parser = grammar.build(start: grammar.stringType).end();
    test('accept', () {
      expect('ByteString', accept(parser));
      expect('DOMString', accept(parser));
      expect('USVString', accept(parser));
    });
    test('reject', () {
      expect('Foo', reject(parser));
      expect('float', reject(parser));
    });
  });
}