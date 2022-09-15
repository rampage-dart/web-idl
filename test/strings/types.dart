// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

/// Strings containing values that parse to types.

/// Makes the type nullable by appending a `?`.
String nullable(String str) => '$str?';

/// User defined types.
const List<String> userDefinedTypes = <String>[
  'Foo',
  'Bar',
  'FooBar',
  'FooBar2020',
  'DOMParser',
  'MutationObserver',
];

/// Types matched by `SingleType`.
const List<String> singleTypes = <String>[
  'any',
  ...promiseTypes,
  ...distinguishableTypes,
];

/// Types matched by `UnionType`.
const List<String> unionTypes = <String>[
  '(boolean or byte)',
  '(DOMString or unrestricted float)',
  '(unsigned long long or unrestricted double)',
  '(ByteString or ArrayBuffer)',
  '(ArrayBufferView or ArrayBuffer)',
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

/// Types matched by `DistinguishableType`.
const List<String> distinguishableTypes = <String>[
  'sequence<Foo>',
  'FrozenArray<Foo>',
  'ObservableArray<Foo>',
  'object',
  'symbol',
  'ArrayBufferView',
  ...primitiveTypes,
  ...stringTypes,
  ...bufferRelatedTypes,
  ...recordTypes,
  ...userDefinedTypes,
];

/// Types matched by `PrimitiveType`.
const List<String> primitiveTypes = <String>[
  'boolean',
  'byte',
  'octet',
  ...unsignedIntegerTypes,
  ...unrestrictedFloatTypes,
];

/// Types matched by `UnrestrictedFloatType`
const List<String> unrestrictedFloatTypes = <String>[
  'unrestricted float',
  'unrestricted double',
  ...floatTypes,
];

/// Types matched by `FloatType`
const List<String> floatTypes = <String>[
  'float',
  'double',
];

/// Types matched by `UnsignedIntegerType`
const List<String> unsignedIntegerTypes = <String>[
  'unsigned short',
  'unsigned long',
  'unsigned long long',
  ...integerTypes,
];

/// Types matched by `IntegerType`
const List<String> integerTypes = <String>[
  'short',
  'long',
  'long long',
];

/// Types matched by `StringType`
const List<String> stringTypes = <String>[
  'ByteString',
  'DOMString',
  'USVString',
];

/// Types matched by `PromiseType`
const List<String> promiseTypes = <String>[
  'Promise<undefined>',
  'Promise<any>',
  'Promise<DOMString>',
  'Promise<float>',
  'Promise<object>',
  'Promise<symbol>',
  'Promise<Foo>',
  'Promise<Foo?>',
];

/// Types matched by `RecordType`
const List<String> recordTypes = <String>[
  'record<ByteString, Foo>',
  'record<DOMString, Bar>',
  'record<USVString, Baz>',
  'record<ByteString, Foo?>',
];

/// Types matched by `BufferRelatedType`
const List<String> bufferRelatedTypes = <String>[
  'ArrayBuffer',
  'DataView',
  'Int8Array',
  'Int16Array',
  'Int32Array',
  'Uint8Array',
  'Uint16Array',
  'Uint32Array',
  'Uint8ClampedArray',
  'BigInt64Array',
  'BigUint64Array',
  'Float32Array',
  'Float64Array',
];
