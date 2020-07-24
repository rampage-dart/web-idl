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

void acceptAll(Parser parser, Iterable<String> inputs) {
  for (final input in inputs) {
    expect(input, accept(parser));
  }
}

void rejectAll(Parser parser, Iterable<String> inputs) {
  for (final input in inputs) {
    expect(input, reject(parser));
  }
}

void main() {
  final grammar = WebIdlGrammarDefinition();
  group('ArgumentNameKeyword', () {
    final parser = grammar.build(start: grammar.argumentNameKeyword).end();
    test('accept', () {
      acceptAll(parser, _argumentNameKeywords);
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
  group('UnionType', () {
    final parser = grammar.build(start: grammar.unionType).end();
    test('accept', () {
      acceptAll(parser, _unionTypes);
    });
    test('reject', () {
      // Needs at least two types
      expect('()', reject(parser));
      expect('(or)', reject(parser));
      expect('(Foo or)', reject(parser));
      expect('(or Bar)', reject(parser));
      // Parenthesis errors
      expect('Foo or Bar', reject(parser));
      expect(')Foo or Bar(', reject(parser));
      expect('Foo or Bar)', reject(parser));
      expect('(Foo or Bar', reject(parser));
      // Must be DistinguishableType
      expect('(Promise<long> or long)', reject(parser));

      // Nullable type
      rejectAll(parser, _unionTypes.map(_makeNullable));
      // Unrelated types
      rejectAll(parser, _userDefinedTypes);
      rejectAll(parser, _unrestrictedFloatTypes);
      rejectAll(parser, _unsignedIntegerTypes);
      rejectAll(parser, _stringTypes);
      rejectAll(parser, _promiseTypes);
      rejectAll(parser, _recordTypes);
      rejectAll(parser, _bufferRelatedTypes);
    });
  });
  group('PrimitiveType', () {
    final parser = grammar.build(start: grammar.primitiveType).end();
    test('accept', () {
      acceptAll(parser, _primitiveTypes);
    });
    test('reject', () {
      // Misspellings
      expect('booleans', reject(parser));
      expect('bytes', reject(parser));
      expect('octets', reject(parser));

      // Nullable type
      rejectAll(parser, _primitiveTypes.map(_makeNullable));
      // Unrelated types
      rejectAll(parser, _userDefinedTypes);
      rejectAll(parser, _unionTypes);
      rejectAll(parser, _stringTypes);
      rejectAll(parser, _promiseTypes);
      rejectAll(parser, _recordTypes);
      rejectAll(parser, _bufferRelatedTypes);
    });
  });

  group('UnrestrictedFloatType', () {
    final parser = grammar.build(start: grammar.unrestrictedFloatType).end();
    test('accept', () {
      acceptAll(parser, _unrestrictedFloatTypes);
    });
    test('reject', () {
      // Misspellings
      expect('unrestricted floats', reject(parser));
      expect('unrestricted doubles', reject(parser));
      // Repeating
      expect('unrestricted float unrestricted', reject(parser));
      expect('unrestricted unrestricted float', reject(parser));

      // Nullable type
      rejectAll(parser, _unrestrictedFloatTypes.map(_makeNullable));
      // Unrelated types
      rejectAll(parser, _userDefinedTypes);
      rejectAll(parser, _unionTypes);
      rejectAll(parser, _unsignedIntegerTypes);
      rejectAll(parser, _stringTypes);
      rejectAll(parser, _promiseTypes);
      rejectAll(parser, _recordTypes);
      rejectAll(parser, _bufferRelatedTypes);
    });
  });
  group('FloatType', () {
    final parser = grammar.build(start: grammar.floatType).end();
    test('accept', () {
      acceptAll(parser, _floatTypes);
    });
    test('reject', () {
      // Misspellings
      expect('floats', reject(parser));
      expect('doubles', reject(parser));
      // Repeating
      expect('float float', reject(parser));
      expect('double double', reject(parser));
      // UnrestrictedFloatType (superset of FloatType)
      expect('unrestricted float', reject(parser));
      expect('unrestricted double', reject(parser));

      // Nullable type
      rejectAll(parser, _floatTypes.map(_makeNullable));
      // Unrelated types
      rejectAll(parser, _userDefinedTypes);
      rejectAll(parser, _unionTypes);
      rejectAll(parser, _unsignedIntegerTypes);
      rejectAll(parser, _stringTypes);
      rejectAll(parser, _promiseTypes);
      rejectAll(parser, _recordTypes);
      rejectAll(parser, _bufferRelatedTypes);
    });
  });
  group('UnsignedIntegerType', () {
    final parser = grammar.build(start: grammar.unsignedIntegerType).end();
    test('accept', () {
      acceptAll(parser, _unsignedIntegerTypes);
    });
    test('reject', () {
      // Repeating
      expect('short short', reject(parser));
      expect('short long', reject(parser));
      expect('long long long', reject(parser));
      expect('unsigned unsigned short', reject(parser));
      expect('unsigned unsigned long', reject(parser));
      expect('unsigned unsigned long long', reject(parser));

      // Nullable type
      rejectAll(parser, _unsignedIntegerTypes.map(_makeNullable));
      // Unrelated types
      rejectAll(parser, _userDefinedTypes);
      rejectAll(parser, _unionTypes);
      rejectAll(parser, _unrestrictedFloatTypes);
      rejectAll(parser, _stringTypes);
      rejectAll(parser, _promiseTypes);
      rejectAll(parser, _recordTypes);
      rejectAll(parser, _bufferRelatedTypes);
    });
  });
  group('IntegerType', () {
    final parser = grammar.build(start: grammar.integerType).end();
    test('accept', () {
      acceptAll(parser, _integerTypes);
    });
    test('reject', () {
      // Misspellings
      expect('shorts', reject(parser));
      expect('longs', reject(parser));
      expect('long longs', reject(parser));
      // Repeating
      expect('short short', reject(parser));
      expect('short long', reject(parser));
      expect('long long long', reject(parser));
      // UnsignedIntegerType (superset of IntegerType)
      expect('unsigned short', reject(parser));
      expect('unsigned long', reject(parser));
      expect('unsigned long long', reject(parser));

      // Nullable type
      rejectAll(parser, _integerTypes.map(_makeNullable));
      // Unrelated types
      rejectAll(parser, _userDefinedTypes);
      rejectAll(parser, _unionTypes);
      rejectAll(parser, _unrestrictedFloatTypes);
      rejectAll(parser, _stringTypes);
      rejectAll(parser, _promiseTypes);
      rejectAll(parser, _recordTypes);
      rejectAll(parser, _bufferRelatedTypes);
    });
  });
  group('StringType', () {
    final parser = grammar.build(start: grammar.stringType).end();
    test('accept', () {
      acceptAll(parser, _stringTypes);
    });
    test('reject', () {
      // Misspellings
      expect('ByteStrings', reject(parser));
      expect('DOMStrings', reject(parser));
      expect('USVStrings', reject(parser));
      // Repeating
      expect('ByteString ByteString', reject(parser));
      expect('DOMString DOMString', reject(parser));
      expect('USVString USVString', reject(parser));

      // Nullable type
      rejectAll(parser, _stringTypes.map(_makeNullable));
      // Unrelated types
      rejectAll(parser, _userDefinedTypes);
      rejectAll(parser, _unionTypes);
      rejectAll(parser, _unrestrictedFloatTypes);
      rejectAll(parser, _unsignedIntegerTypes);
      rejectAll(parser, _promiseTypes);
      rejectAll(parser, _recordTypes);
      rejectAll(parser, _bufferRelatedTypes);
    });
  });
  group('Promise', () {
    final parser = grammar.build(start: grammar.promiseType).end();
    test('accept', () {
      acceptAll(parser, _promiseTypes);
    });
    test('reject', () {
      // Misspellings
      expect('Promises<Foo>', reject(parser));
      // Generic argument errors
      expect('Promise<>', reject(parser));
      expect('Promise<,>', reject(parser));
      expect('Promise<Foo,>', reject(parser));
      expect('Promise<Foo, Bar>', reject(parser));
      expect('Promise<Foo, Bar, Baz>', reject(parser));

      // Nullable type
      rejectAll(parser, _promiseTypes.map(_makeNullable));
      // Unrelated types
      rejectAll(parser, _userDefinedTypes);
      rejectAll(parser, _unionTypes);
      rejectAll(parser, _unrestrictedFloatTypes);
      rejectAll(parser, _unsignedIntegerTypes);
      rejectAll(parser, _stringTypes);
      rejectAll(parser, _recordTypes);
      rejectAll(parser, _bufferRelatedTypes);
    });
  });
  group('RecordType', () {
    final parser = grammar.build(start: grammar.recordType).end();
    test('accept', () {
      acceptAll(parser, _recordTypes);
    });
    test('reject', () {
      // Misspellings
      expect('records<DOMString, Bar>', reject(parser));
      // Key must be a StringType
      expect('record<Foo, Bar>', reject(parser));
      expect('record<Foo, DOMString>', reject(parser));
      // Generic argument errors
      expect('record<>', reject(parser));
      expect('record<,>', reject(parser));
      expect('record<,,>', reject(parser));
      expect('record<DOMString, Bar,>', reject(parser));
      expect('record<DOMString, Bar, Baz>', reject(parser));

      // Nullable type
      rejectAll(parser, _recordTypes.map(_makeNullable));
      // Unrelated types
      rejectAll(parser, _userDefinedTypes);
      rejectAll(parser, _unionTypes);
      rejectAll(parser, _unrestrictedFloatTypes);
      rejectAll(parser, _unsignedIntegerTypes);
      rejectAll(parser, _stringTypes);
      rejectAll(parser, _promiseTypes);
      rejectAll(parser, _bufferRelatedTypes);
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
      acceptAll(parser, _bufferRelatedTypes);
    });
    test('reject', () {
      // Misspellings
      expect('ArrayBuffers', reject(parser));
      expect('DataViews', reject(parser));
      expect('Int8Arrays', reject(parser));
      expect('Int16Arrays', reject(parser));
      expect('Int32Arrays', reject(parser));
      expect('Uint8Arrays', reject(parser));
      expect('Uint16Arrays', reject(parser));
      expect('Uint32Arrays', reject(parser));
      expect('Uint8ClampedArrays', reject(parser));
      expect('Float32Arrays', reject(parser));
      expect('Float64Arrays', reject(parser));
      // Repeating
      expect('ArrayBuffer ArrayBuffer', reject(parser));
      expect('DataView DataView', reject(parser));
      expect('Int8Array Int8Array', reject(parser));
      expect('Int16Array Int16Array', reject(parser));
      expect('Int32Array Int32Array', reject(parser));
      expect('Uint8Array Uint8Array', reject(parser));
      expect('Uint16Array Uint16Array', reject(parser));
      expect('Uint32Array Uint32Array', reject(parser));
      expect('Uint8ClampedArray Uint8ClampedArray', reject(parser));
      expect('Float32Array Float32Array', reject(parser));
      expect('Float64Array Float64Array', reject(parser));

      // Nullable type
      rejectAll(parser, _bufferRelatedTypes.map(_makeNullable));
      // Unrelated types
      rejectAll(parser, _userDefinedTypes);
      rejectAll(parser, _unionTypes);
      rejectAll(parser, _unrestrictedFloatTypes);
      rejectAll(parser, _unsignedIntegerTypes);
      rejectAll(parser, _stringTypes);
      rejectAll(parser, _promiseTypes);
      rejectAll(parser, _recordTypes);
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

//------------------------------------------------------------------
// Type definitions
//
// Used to test that types match within the Grammar.
//------------------------------------------------------------------

String _makeNullable(String str) => '$str?';

final _userDefinedTypes = <String>[
  'Foo',
  'Bar',
  '_FooBar',
  'FooBar2020',
  'DOMParser',
  'MutationObserver',
  'Foo?',
];

final _unionTypes = <String>[
  '(boolean or byte)',
  '(DOMString or unrestricted float)',
  '(unsigned long long or unrestricted double)',
  '(ByteString or ArrayBuffer)',
  '(sequence<long> or long)',
  '(long or FrozenArray<long>)',
  '(ObservableArray<unsigned long> or unsigned long)',
  '(Foo or Bar)',
  '(Foo or Bar or Baz)',
  '(Foo? or Bar or Baz)',
  '(Foo or Bar? or Baz)',
  '(Foo or Bar or Baz?)',
  '(Foo? or Bar? or Baz?)',
  '(Foo or Bar or Baz or Gaz)',
];

final _primitiveTypes = <String>[
  'boolean',
  'byte',
  'octet',
  ..._unsignedIntegerTypes,
  ..._unrestrictedFloatTypes,
];

final _unrestrictedFloatTypes = <String>[
  'unrestricted float',
  'unrestricted double',
  ..._floatTypes,
];

final _floatTypes = <String>[
  'float',
  'double',
];

final _unsignedIntegerTypes = <String>[
  'unsigned short',
  'unsigned long',
  'unsigned long long',
  ..._integerTypes,
];

final _integerTypes = <String>[
  'short',
  'long',
  'long long',
];

final _stringTypes = <String>[
  'ByteString',
  'DOMString',
  'USVString',
];

final _promiseTypes = <String>[
  'Promise<void>',
  'Promise<any>',
  'Promise<DOMString>',
  'Promise<float>',
  'Promise<object>',
  'Promise<symbol>',
  'Promise<Foo>',
  'Promise<Foo?>',
];

final _recordTypes = <String>[
  'record<ByteString, Foo>',
  'record<DOMString, Bar>',
  'record<USVString, Baz>',
  'record<ByteString, Foo?>',
];

final _bufferRelatedTypes = <String>[
  'ArrayBuffer',
  'DataView',
  'Int8Array',
  'Int16Array',
  'Int32Array',
  'Uint8Array',
  'Uint16Array',
  'Uint32Array',
  'Uint8ClampedArray',
  'Float32Array',
  'Float64Array',
];
