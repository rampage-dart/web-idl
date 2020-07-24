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

void acceptAll(Parser parser, List<String> inputs) {
  for (final input in inputs) {
    expect(input, accept(parser));
  }
}

void rejectAll(Parser parser, List<String> inputs) {
  for (final input in inputs) {
    expect(input, reject(parser));
  }
}

void main() {
  final grammar = WebIdlGrammarDefinition();
  group('ArgumentNameKeyword', () {
    final parser = grammar.build(start: grammar.argumentNameKeyword).end();
    test('accept', () {
      for (final val in _argumentNameKeywords) {
        expect(val, accept(parser));
      }
    });
  });
  group('CallbackRest', () {
    final parser = grammar.build(start: grammar.callbackRest).end();
    test('accept', () {
      expect(
        'MutationCallback = void (sequence<MutationRecord> mutations, MutationObserver observer)',
        accept(parser),
      );
    });
  });
  group('PrimitiveType', () {
    final parser = grammar.build(start: grammar.primitiveType).end();
    test('accept', () {
      expect('unrestricted float', accept(parser));
      expect('unrestricted double', accept(parser));
      expect('float', accept(parser));
      expect('double', accept(parser));
      expect('short', accept(parser));
      expect('long', accept(parser));
      expect('long long', accept(parser));
      expect('unsigned short', accept(parser));
      expect('unsigned long', accept(parser));
      expect('unsigned long long', accept(parser));
      expect('boolean', accept(parser));
      expect('byte', accept(parser));
      expect('octet', accept(parser));
    });
    test('reject', () {
      expect('Foo', reject(parser));
      expect('USVString', reject(parser));
    });
  });

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
  group('UnsignedIntegerType', () {
    final parser = grammar.build(start: grammar.unsignedIntegerType).end();
    test('accept', () {
      expect('short', accept(parser));
      expect('long', accept(parser));
      expect('long long', accept(parser));
      expect('unsigned short', accept(parser));
      expect('unsigned long', accept(parser));
      expect('unsigned long long', accept(parser));
    });
    test('reject', () {
      expect('Foo', reject(parser));
      expect('USVString', reject(parser));
      expect('double', reject(parser));
    });
  });
  group('IntegerType', () {
    final parser = grammar.build(start: grammar.integerType).end();
    test('accept', () {
      expect('short', accept(parser));
      expect('long', accept(parser));
      expect('long long', accept(parser));
    });
    test('reject', () {
      expect('Foo', reject(parser));
      expect('USVString', reject(parser));
      expect('double', reject(parser));
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
  group('Promise', () {
    final parser = grammar.build(start: grammar.promiseType).end();
    test('accept', () {
      expect('Promise<void>', accept(parser));
      expect('Promise<any>', accept(parser));
      expect('Promise<DOMString>', accept(parser));
      expect('Promise<float>', accept(parser));
      expect('Promise<object>', accept(parser));
      expect('Promise<symbol>', accept(parser));
      expect('Promise<Foo>', accept(parser));
    });
  });
  group('Null', () {
    final parser = grammar.build(start: grammar.nullable).end();
    test('accept', () {
      expect('?', accept(parser));
      expect('', accept(parser));
    });
    test('reject', () {
      expect('!', reject(parser));
      expect('Foo', reject(parser));
    });
  });
  group('BufferRelatedType', () {
    final parser = grammar.build(start: grammar.bufferRelatedType).end();
    test('accept', () {
      expect('ArrayBuffer', accept(parser));
      expect('DataView', accept(parser));
      expect('Int8Array', accept(parser));
      expect('Int16Array', accept(parser));
      expect('Int32Array', accept(parser));
      expect('Uint8Array', accept(parser));
      expect('Uint16Array', accept(parser));
      expect('Uint32Array', accept(parser));
      expect('Uint8ClampedArray', accept(parser));
      expect('Float32Array', accept(parser));
      expect('Float64Array', accept(parser));
    });
    test('reject', () {
      expect('Foo', reject(parser));
      expect('float', reject(parser));
    });
  });
  group('ExtendedAttributeList', () {
    final parser = grammar.build(start: grammar.extendedAttributeList).end();
    test('accept', () {
      expect('[Exposed=Window]', accept(parser));
      expect('[Exposed=(Window,Worker)]', accept(parser));
      expect('[SameObject]', accept(parser));
      expect('[CEReactions, Unscopable]', accept(parser));
      expect('', accept(parser));
    });
    test('reject', () {});
  });
}

final _argumentNameKeywords = <String>[
  'async',
  'attribute',
  'callback',
  'const',
  'constructor',
  'deleter',
  'dictionary',
  'enum',
  'getter',
  'includes',
  'inherit',
  'interface',
  'iterable',
  'maplike',
  'mixin',
  'namespace',
  'partial',
  'readonly',
  'required',
  'setlike',
  'setter',
  'static',
  'stringifier',
  'typedef',
  'unrestricted',
];
