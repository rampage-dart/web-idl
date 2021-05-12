// Copyright (c) 2019 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'package:web_idl/src/parser/grammar.dart';

import 'strings/types.dart' as types;
import 'utilities.dart';

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
  group('Definitions', () {
    final parser = grammar.build<Object?>().end();
    test('accept', () {
      expect(_definition.join('\n'), accept(parser));
    });
  });
  group('Definition', () {
    final parser = grammar.build<Object?>(start: grammar.definition).end();
    test('accept', () {
      acceptAll(parser, _definition);
      expect('enum MealType { "rice" };', accept(parser));
      expect('enum MealType { "rice", "noodles", "other" };', accept(parser));
      expect('partial interface Foo {};', accept(parser));
      expect('Node includes EventTarget;', accept(parser));
    });
  });
  group('ArgumentNameKeyword', () {
    final parser =
        grammar.build<Object?>(start: grammar.argumentNameKeyword).end();
    test('accept', () {
      acceptAll(parser, _argumentNameKeywords);
    });
  });
  group('AttributeRest', () {
    final parser = grammar.build<Object?>(start: grammar.attributeRest).end();
    test('accept', () {
      expect('attribute double async;', accept(parser));
      expect('attribute Foo foo;', accept(parser));
    });
  });
  group('AttributeName', () {
    final parser = grammar.build<Object?>(start: grammar.attributeName).end();
    test('accept', () {
      expect('async', accept(parser));
      expect('required', accept(parser));
    });
  });
  group('AttributeNameKeyword', () {
    final parser =
        grammar.build<Object?>(start: grammar.attributeNameKeyword).end();
    test('accept', () {
      expect('async', accept(parser));
      expect('required', accept(parser));
    });
  });
  group('Partial', () {
    final parser = grammar.build<Object?>(start: grammar.partial).end();
    test('accept', () {
      expect('partial interface Foo {};', accept(parser));
      expect('partial interface mixin Foo {};', accept(parser));
      expect('partial namespace Foo {};', accept(parser));
    });
    test('reject', () {
      expect('interface Foo {};', reject(parser));
      expect('interface mixin Foo {};', reject(parser));
      expect('namespace Foo {};', reject(parser));
    });
  });
  group('Enum', () {
    final parser = grammar.build<Object?>(start: grammar.enumeration).end();
    test('accept', () {
      expect('enum MealType { "rice" };', accept(parser));
      expect('enum MealType { "rice", "noodles", "other" };', accept(parser));
      // Single trailing ,
      expect('enum MealType { "rice", "noodles", "other", };', accept(parser));
    });
    test('reject', () {
      // Enum can't be empty
      expect('enum MealType { };', reject(parser));
      // Missing ;
      expect('enum MealType { "rice" }', reject(parser));
      expect('enum MealType { "rice", "noodles", "other" }', reject(parser));
      // Missing ,
      expect('enum MealType { "rice", "noodles" "other" };', reject(parser));
      expect('enum MealType { "rice" "noodles", "other" };', reject(parser));
      expect('enum MealType { "rice" "noodles" "other" };', reject(parser));
      // Multiple trailing ,
      expect('enum MealType { "rice", "noodles", , , };', reject(parser));
      // Misspellings
      expect('enu MealType { "rice", "noodles", "other" };', reject(parser));
      // Not enum declaration
      expect('namespace Foo { };', reject(parser));
    });
  });
  group('CallbackRest', () {
    final parser = grammar.build<Object?>(start: grammar.callbackRest).end();
    test('accept', () {
      expect(
        'AsyncOperationCallback = void (DOMString status);',
        accept(parser),
      );
      expect(
        'MutationCallback = void '
        '(sequence<MutationRecord> mutations, MutationObserver observer);',
        accept(parser),
      );
    });
  });
  group('Const', () {
    final parser = grammar.build<Object?>(start: grammar.constant).end();
    test('accept', () {
      expect('const boolean aBool = false;', accept(parser));
      expect('const unsigned long anInt = 4;', accept(parser));
      expect('const float aFloat = -1.0;', accept(parser));
    });
    test('reject', () {
      // Nullable types
      expect('const boolean? aBoolNullable = false;', reject(parser));
      expect('const unsigned long? anIntNullable = 2;', reject(parser));
      expect('const float? aFloat = -1.0;', reject(parser));
    });
  });
  group('ConstValue', () {
    final parser = grammar.build<Object?>(start: grammar.constantValue).end();
    test('accept', () {
      acceptAll(parser, _constantValues);
    });
    test('reject', () {
      // Default value
      rejectAll(parser, _stringLiterals);
      expect('[ ]', reject(parser));
      expect('{ }', reject(parser));
      expect('null', reject(parser));
    });
  });
  group('DefaultValue', () {
    final parser = grammar.build<Object?>(start: grammar.defaultValue).end();
    test('accept', () {
      acceptAll(parser, _constantValues);
      acceptAll(parser, _stringLiterals);
      expect('[ ]', accept(parser));
      expect('{ }', accept(parser));
      expect('null', accept(parser));
    });
    test('reject', () {
      rejectAll(parser, _validIdentifiers);
    });
  });
  group('ArgumentList', () {
    final parser = grammar.build<Object?>(start: grammar.argumentList).end();
    test('accept', () {
      expect('', accept(parser));

      expect('any arg', accept(parser));
      expect('Promise<Foo> promise', accept(parser));
      expect('(double or short) num', accept(parser));
      expect('Foo foo', accept(parser));
      expect('optional any foo', accept(parser));
      expect('optional Foo foo', accept(parser));

      expect('Foo foo, any arg', accept(parser));
      expect('any arg, Foo foo', accept(parser));
    });
  });
  group('Argument', () {
    final parser = grammar.build<Object?>(start: grammar.argument).end();
    test('accept', () {
      // Builtin types
      expect('any arg', accept(parser));
      expect('Promise<Foo> promise', accept(parser));
      expect('boolean withFoo', accept(parser));
      expect('(double or short) num', accept(parser));

      expect('any... arg', accept(parser));
      expect('Promise<Foo>... promise', accept(parser));
      expect('boolean... withFoo', accept(parser));
      expect('(double or short)... num', accept(parser));

      expect('optional any arg', accept(parser));
      expect('optional Promise<Foo> promise', accept(parser));
      expect('optional boolean withFoo', accept(parser));
      expect('optional (double or short) num', accept(parser));

      // User defined
      expect('Foo async', accept(parser));
      expect('Foo foo', accept(parser));
      expect('Foo? foo', accept(parser));
      expect('Foo... foo', accept(parser));
      expect('(Foo or Bar) foobar', accept(parser));
      expect('(Foo or Bar)... foobars', accept(parser));
    });
  });
  group('ArgumentName', () {
    final parser = grammar.build<Object?>(start: grammar.argumentName).end();
    test('accept', () {
      acceptAll(parser, _validIdentifiers);
      acceptAll(parser, _argumentNameKeywords);
    });
    test('reject', () {
      rejectAll(parser, _invalidIdentifiers);
    });
  });
  group('Type', () {
    final parser = grammar.build<Object?>(start: grammar.type).end();
    test('accept', () {
      acceptAll(parser, types.singleTypes);
      acceptAll(parser, types.distinguishableTypes.map(types.nullable));
      acceptAll(parser, types.unionTypes);
      acceptAll(parser, types.unionTypes.map(types.nullable));
    });
    test('reject', () {
      // Can't be nullable
      expect('any?', reject(parser));
      expect('Promise<Foo>?', reject(parser));
    });
  });
  group('SingleType', () {
    final parser = grammar.build<Object?>(start: grammar.singleType).end();
    test('accept', () {
      acceptAll(parser, types.singleTypes);
      acceptAll(parser, types.distinguishableTypes.map(types.nullable));
    });
    test('reject', () {
      // Can't be nullable
      expect('any?', reject(parser));
      expect('Promise<Foo>?', reject(parser));

      // Unrelated types
      rejectAll(parser, types.unionTypes);
    });
  });
  group('UnionType', () {
    final parser = grammar.build<Object?>(start: grammar.unionType).end();
    test('accept', () {
      acceptAll(parser, types.unionTypes);
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
      rejectAll(parser, types.unionTypes.map(types.nullable));
      // Unrelated types
      rejectAll(parser, types.userDefinedTypes);
      rejectAll(parser, types.unrestrictedFloatTypes);
      rejectAll(parser, types.unsignedIntegerTypes);
      rejectAll(parser, types.stringTypes);
      rejectAll(parser, types.promiseTypes);
      rejectAll(parser, types.recordTypes);
      rejectAll(parser, types.bufferRelatedTypes);
    });
  });
  group('DistinguishableType', () {
    final parser =
        grammar.build<Object?>(start: grammar.distinguishableType).end();
    test('accept', () {
      acceptAll(parser, types.distinguishableTypes);
      acceptAll(parser, types.distinguishableTypes.map(types.nullable));
    });
    test('reject', () {
      // Misspellings (generics only since others will be caught as identifiers)
      expect('sequences<Foo>', reject(parser));
      expect('FrozenArrays<Foo>', reject(parser));
      expect('ObservableArrays<Foo>', reject(parser));
      // User defined generics
      expect('Foo<Bar>', reject(parser));
      // Generic argument errors
      expect('sequence<>', reject(parser));
      expect('sequence<,>', reject(parser));
      expect('sequence<Foo,>', reject(parser));
      expect('sequence<Foo, Bar>', reject(parser));
      expect('sequence<Foo, Bar, Baz>', reject(parser));
      expect('FrozenArray<>', reject(parser));
      expect('FrozenArray<,>', reject(parser));
      expect('FrozenArray<Foo,>', reject(parser));
      expect('FrozenArray<Foo, Bar>', reject(parser));
      expect('FrozenArray<Foo, Bar, Baz>', reject(parser));
      expect('ObservableArray<>', reject(parser));
      expect('ObservableArray<,>', reject(parser));
      expect('ObservableArray<Foo,>', reject(parser));
      expect('ObservableArray<Foo, Bar>', reject(parser));
      expect('ObservableArray<Foo, Bar, Baz>', reject(parser));

      // Unrelated types
      rejectAll(parser, types.unionTypes);
      rejectAll(parser, types.promiseTypes);
    });
  });
  group('PrimitiveType', () {
    final parser = grammar.build<Object?>(start: grammar.primitiveType).end();
    test('accept', () {
      acceptAll(parser, types.primitiveTypes);
    });
    test('reject', () {
      // Misspellings
      expect('booleans', reject(parser));
      expect('bytes', reject(parser));
      expect('octets', reject(parser));

      // Nullable type
      rejectAll(parser, types.primitiveTypes.map(types.nullable));
      // Unrelated types
      rejectAll(parser, types.userDefinedTypes);
      rejectAll(parser, types.unionTypes);
      rejectAll(parser, types.stringTypes);
      rejectAll(parser, types.promiseTypes);
      rejectAll(parser, types.recordTypes);
      rejectAll(parser, types.bufferRelatedTypes);
    });
  });

  group('UnrestrictedFloatType', () {
    final parser =
        grammar.build<Object?>(start: grammar.unrestrictedFloatType).end();
    test('accept', () {
      acceptAll(parser, types.unrestrictedFloatTypes);
    });
    test('reject', () {
      // Misspellings
      expect('unrestricted floats', reject(parser));
      expect('unrestricted doubles', reject(parser));
      // Repeating
      expect('unrestricted float unrestricted', reject(parser));
      expect('unrestricted unrestricted float', reject(parser));

      // Nullable type
      rejectAll(parser, types.unrestrictedFloatTypes.map(types.nullable));
      // Unrelated types
      rejectAll(parser, types.userDefinedTypes);
      rejectAll(parser, types.unionTypes);
      rejectAll(parser, types.unsignedIntegerTypes);
      rejectAll(parser, types.stringTypes);
      rejectAll(parser, types.promiseTypes);
      rejectAll(parser, types.recordTypes);
      rejectAll(parser, types.bufferRelatedTypes);
    });
  });
  group('FloatType', () {
    final parser = grammar.build<Object?>(start: grammar.floatType).end();
    test('accept', () {
      acceptAll(parser, types.floatTypes);
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
      rejectAll(parser, types.floatTypes.map(types.nullable));
      // Unrelated types
      rejectAll(parser, types.userDefinedTypes);
      rejectAll(parser, types.unionTypes);
      rejectAll(parser, types.unsignedIntegerTypes);
      rejectAll(parser, types.stringTypes);
      rejectAll(parser, types.promiseTypes);
      rejectAll(parser, types.recordTypes);
      rejectAll(parser, types.bufferRelatedTypes);
    });
  });
  group('UnsignedIntegerType', () {
    final parser =
        grammar.build<Object?>(start: grammar.unsignedIntegerType).end();
    test('accept', () {
      acceptAll(parser, types.unsignedIntegerTypes);
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
      rejectAll(parser, types.unsignedIntegerTypes.map(types.nullable));
      // Unrelated types
      rejectAll(parser, types.userDefinedTypes);
      rejectAll(parser, types.unionTypes);
      rejectAll(parser, types.unrestrictedFloatTypes);
      rejectAll(parser, types.stringTypes);
      rejectAll(parser, types.promiseTypes);
      rejectAll(parser, types.recordTypes);
      rejectAll(parser, types.bufferRelatedTypes);
    });
  });
  group('IntegerType', () {
    final parser = grammar.build<Object?>(start: grammar.integerType).end();
    test('accept', () {
      acceptAll(parser, types.integerTypes);
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
      rejectAll(parser, types.integerTypes.map(types.nullable));
      // Unrelated types
      rejectAll(parser, types.userDefinedTypes);
      rejectAll(parser, types.unionTypes);
      rejectAll(parser, types.unrestrictedFloatTypes);
      rejectAll(parser, types.stringTypes);
      rejectAll(parser, types.promiseTypes);
      rejectAll(parser, types.recordTypes);
      rejectAll(parser, types.bufferRelatedTypes);
    });
  });
  group('StringType', () {
    final parser = grammar.build<Object?>(start: grammar.stringType).end();
    test('accept', () {
      acceptAll(parser, types.stringTypes);
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
      rejectAll(parser, types.stringTypes.map(types.nullable));
      // Unrelated types
      rejectAll(parser, types.userDefinedTypes);
      rejectAll(parser, types.unionTypes);
      rejectAll(parser, types.unrestrictedFloatTypes);
      rejectAll(parser, types.unsignedIntegerTypes);
      rejectAll(parser, types.promiseTypes);
      rejectAll(parser, types.recordTypes);
      rejectAll(parser, types.bufferRelatedTypes);
    });
  });
  group('Promise', () {
    final parser = grammar.build<Object?>(start: grammar.promiseType).end();
    test('accept', () {
      acceptAll(parser, types.promiseTypes);
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
      rejectAll(parser, types.promiseTypes.map(types.nullable));
      // Unrelated types
      rejectAll(parser, types.userDefinedTypes);
      rejectAll(parser, types.unionTypes);
      rejectAll(parser, types.unrestrictedFloatTypes);
      rejectAll(parser, types.unsignedIntegerTypes);
      rejectAll(parser, types.stringTypes);
      rejectAll(parser, types.recordTypes);
      rejectAll(parser, types.bufferRelatedTypes);
    });
  });
  group('RecordType', () {
    final parser = grammar.build<Object?>(start: grammar.recordType).end();
    test('accept', () {
      acceptAll(parser, types.recordTypes);
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
      rejectAll(parser, types.recordTypes.map(types.nullable));
      // Unrelated types
      rejectAll(parser, types.userDefinedTypes);
      rejectAll(parser, types.unionTypes);
      rejectAll(parser, types.unrestrictedFloatTypes);
      rejectAll(parser, types.unsignedIntegerTypes);
      rejectAll(parser, types.stringTypes);
      rejectAll(parser, types.promiseTypes);
      rejectAll(parser, types.bufferRelatedTypes);
    });
  });
  group('Null', () {
    final parser = grammar.build<Object?>(start: grammar.nullable).end();
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
    final parser =
        grammar.build<Object?>(start: grammar.bufferRelatedType).end();
    test('accept', () {
      acceptAll(parser, types.bufferRelatedTypes);
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
      rejectAll(parser, types.bufferRelatedTypes.map(types.nullable));
      // Unrelated types
      rejectAll(parser, types.userDefinedTypes);
      rejectAll(parser, types.unionTypes);
      rejectAll(parser, types.unrestrictedFloatTypes);
      rejectAll(parser, types.unsignedIntegerTypes);
      rejectAll(parser, types.stringTypes);
      rejectAll(parser, types.promiseTypes);
      rejectAll(parser, types.recordTypes);
    });
  });
  group('ExtendedAttributeList', () {
    final parser =
        grammar.build<Object?>(start: grammar.extendedAttributeList).end();
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

final _definition = <String>[
  ..._partial,
];

final _partial = <String>[
  'partial interface Foo {};',
  'partial interface mixin Foo {};',
  'partial namespace Foo {};',
  'partial dictionary Foo {};',
];

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

final _validIdentifiers = <String>[
  'foo',
  'bar',
  'baz',
  'fooBar',
  'fooBarBaz',
  'Foo',
  'Bar',
  'Baz',
  // With numbers
  'foo0',
  'foo0bar1baz2',
  // With _
  'FOO',
  'FOO_BAR',
  'Foo_Bar_Baz',
  // DOM names
  'Element',
  'MutationObserver',
];

final _invalidIdentifiers = <String>[
  '0',
  '*foo',
];

//------------------------------------------------------------------
// Constant values
//------------------------------------------------------------------

final _constantValues = <String>[
  ..._booleanLiterals,
  ..._floatLiterals,
  ..._integerLiterals,
];

final _booleanLiterals = <String>['true', 'false'];

final _floatLiterals = <String>['0.0'];

final _integerLiterals = <String>[
  '0',
  '123456789',
  '-987654321',
];

final _stringLiterals = <String>[
  '"foo bar"',
  '"0123456789"',
];
