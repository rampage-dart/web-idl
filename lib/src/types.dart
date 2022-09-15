// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'element.dart';
import 'parser/builtin_types.dart' as builtin;
import 'type.dart';

/// Checks for whether the [SingleType] represents the `any` type.
extension AnyType on SingleType {
  /// Whether the type is the `any` type.
  ///
  /// The any type is the union of all other possible non-union types.
  bool get isAny => name == builtin.any;
}

/// Checks for whether the [SingleType] represents the `undefined` type.
extension UndefinedType on SingleType {
  /// Whether the type is the `undefined` type.
  ///
  /// The undefined type has a unique value.
  bool get isUndefined => name == builtin.undefined;
}

/// Checks for whether the [SingleType] represents an integer.
extension IntegerType on SingleType {
  /// Whether the type is a `byte`.
  ///
  /// The `byte` type is a signed integer type that has values in the range
  /// [−128, 127].
  bool get isByte => name == builtin.byte;

  /// Whether the type is an `octet`.
  ///
  /// The `octet` type is an unsigned integer type that has values in the range
  /// [0, 255].
  bool get isOctet => name == builtin.octet;

  /// Whether the type is a `short`.
  ///
  /// The `short` type is a signed integer type that has values in the range
  /// [−32768, 32767].
  bool get isShort => name == builtin.short;

  /// Whether the type is an `unsigned short`.
  ///
  /// The `unsigned short` type is an unsigned integer type that has values in
  /// the range [0, 65535].
  bool get isUnsignedShort => name == '${builtin.unsigned} ${builtin.short}';

  /// Whether the type is a `long`.
  ///
  /// The `long` type is a signed integer type that has values in the range
  /// [−2147483648, 2147483647].
  bool get isLong => name == builtin.long;

  /// Whether the type is an `unsigned long`.
  ///
  /// The `unsigned long` type is an unsigned integer type that has values in
  /// the range [0, 4294967295].
  bool get isUnsignedLong => name == '${builtin.unsigned} ${builtin.long}';

  /// Whether the type is a `long long`.
  ///
  /// The `long long` type is a signed integer type that has values in the range
  /// [−9223372036854775808, 9223372036854775807].
  bool get isLongLong => name == '${builtin.long} ${builtin.long}';

  /// Whether the type is an `unsigned long long`.
  ///
  /// The `unsigned long long` type is an unsigned integer type that has values
  /// in the range [0, 18446744073709551615].
  bool get isUnsignedLongLong =>
      name == '${builtin.unsigned} ${builtin.long} ${builtin.long}';

  /// Whether the type represents an integer.
  ///
  /// The following types are known as integer types: `byte`, `octet`, `short`,
  /// `unsigned short`, `long`, `unsigned long`, `long long` and
  /// `unsigned long long`.
  bool get isInteger =>
      isByte ||
      isOctet ||
      isShort ||
      isUnsignedShort ||
      isLong ||
      isUnsignedLong ||
      isLongLong ||
      isUnsignedLongLong;
}

/// Checks for whether the [SingleType] represents a number.
extension NumericType on SingleType {
  /// Whether the type is a `float`.
  ///
  /// The `float` type is a floating point numeric type that corresponds to the
  /// set of finite single-precision 32 bit IEEE 754 floating point numbers.
  bool get isFloat => name == builtin.float;

  /// Whether the type is an `unrestricted float`.
  ///
  /// The `unrestricted float` type is a floating point numeric type that
  /// corresponds to the set of all possible single-precision 32 bit IEEE 754
  /// floating point numbers, finite, non-finite, and special "not a number"
  /// values (NaNs).
  bool get isUnrestrictedFloat =>
      name == '${builtin.unrestricted} ${builtin.float}';

  /// Whether the type is a `double`.
  ///
  /// The `double` type is a floating point numeric type that corresponds to the
  /// set of finite double-precision 64 bit IEEE 754 floating point numbers.
  bool get isDouble => name == builtin.double;

  /// Whether the type is an `unrestricted double`.
  ///
  /// The `unrestricted double` type is a floating point numeric type that
  /// corresponds to the set of all possible double-precision 64 bit IEEE 754
  /// floating point numbers, finite, non-finite, and special "not a number"
  /// values (NaNs).
  bool get isUnrestrictedDouble =>
      name == '${builtin.unrestricted} ${builtin.double}';

  /// Whether the type is numeric.
  ///
  /// The following types are known as numeric types: the [IntegerType]s,
  /// `float`, `unrestricted float`, `double` and `unrestricted double`.
  bool get isNumeric =>
      isInteger ||
      isFloat ||
      isUnrestrictedFloat ||
      isDouble ||
      isUnrestrictedDouble;
}

/// Checks for whether the [SingleType] represents a primitive type.
extension PrimitiveType on SingleType {
  /// Whether the type is a `boolean`.
  ///
  /// The `boolean` type has two values: `true` and `false`.
  bool get isBool => name == builtin.boolean;

  /// Whether the type is a `bigint`.
  ///
  /// The `bigint` type is an arbitrary integer type, unrestricted in range.
  bool get isBigint => name == builtin.bigint;

  /// Whether the type is a primitive type.
  ///
  /// The primitive types are `bigint`, `boolean` and the [NumericType]s.
  bool get isPrimitive => isNumeric || isBool || isBigint;
}

/// Checks for whether the [SingleType] represents a String.
extension StringType on SingleType {
  /// Whether the type is a `DOMString`.
  ///
  /// The `DOMString` type corresponds to the set of all possible sequences of
  /// code units. Such sequences are commonly interpreted as UTF-16 encoded
  /// strings although this is not required.
  bool get isDomString => name == builtin.domString;

  /// Whether the type is a `ByteString`.
  ///
  /// The ByteString type corresponds to the set of all possible sequences of
  /// bytes. Such sequences might be interpreted as UTF-8 encoded strings or
  /// strings in some other 8-bit-per-code-unit encoding, although this is not
  /// required.
  bool get isByteString => name == builtin.byteString;

  /// Whether the type is a `USVString`.
  ///
  /// The USVString type corresponds to the set of all possible sequences of
  /// Unicode scalar values, which are all of the Unicode code points apart from
  /// the surrogate code points.
  bool get isUsvString => name == builtin.usvString;

  /// Whether the type is a String.
  ///
  /// The string types are `DOMString`, all [EnumType]s, `ByteString` and
  /// `USVString`.
  bool get isString => isDomString || isByteString || isUsvString || isEnum;
}

/// Checks for whether the [SingleType] represents an `object`.
extension ObjectType on SingleType {
  /// Whether the type is an `object`.
  ///
  /// The object type corresponds to the set of all possible non-null object
  /// references.
  bool get isObject => name == builtin.object;
}

/// Checks for whether the [SingleType] represents a `symbol`.
extension SymbolType on SingleType {
  /// Whether the type is a `symbol`.
  ///
  /// The symbol type corresponds to the set of all possible symbol values.
  /// Symbol values are opaque, non-object values which nevertheless have
  /// identity (i.e., are only equal to themselves).
  bool get isSymbol => name == builtin.symbol;
}

/// Checks for whether the [SingleType] represents an interface.
extension InterfaceType on SingleType {
  /// Whether the type is an interface.
  ///
  /// An identifier that identifies an interface is used to refer to a type that
  /// corresponds to the set of all possible non-null references to objects that
  /// implement that interface.
  bool get isInterface => element is InterfaceElement;
}

/// Checks for whether the [SingleType] represents a dictionary.
extension DictionaryType on SingleType {
  /// Whether the type is a dictionary.
  ///
  /// An identifier that identifies a dictionary is used to refer to a type that
  /// corresponds to the set of all dictionaries that adhere to the dictionary
  /// definition.
  bool get isDictionary => element is DictionaryElement;
}

/// Checks for whether the [SingleType] represents an enumeration.
extension EnumerationType on SingleType {
  /// Whether the type is an enumeration.
  ///
  /// An identifier that identifies an enumeration is used to refer to a type
  /// whose values are the set of strings (sequences of code units, as with
  /// `DOMString`) that are the enumeration’s values.
  bool get isEnum => element is EnumElement;
}

/// Checks for whether the [SingleType] represents a callback function.
extension CallbackFunctionType on SingleType {
  /// Whether the type is a callback function.
  ///
  /// An identifier that identifies a callback function is used to refer to a
  /// type whose values are references to objects that are functions with the
  /// given signature.
  bool get isCallbackFunction => element is FunctionTypeAliasElement;
}

/// Checks for whether the [SingleType] represents a type alias.
extension AliasType on SingleType {
  /// Whether the type is a type alias.
  bool get isTypeAlias => element is TypeAliasElement;
}

/// Checks for whether the [SingleType] represents a `sequence`.
extension SequenceType on SingleType {
  /// Whether the type is a `sequence`.
  ///
  /// The `sequence<T>` type is a parameterized type whose values are (possibly
  /// zero-length) lists of values of type `T`.
  bool get isSequence => name == builtin.sequence;
}

/// Checks for whether the [SingleType] represents a `record`.
extension RecordType on SingleType {
  /// Whether the type is a `record`.
  ///
  /// A record type is a parameterized type whose values are ordered maps with
  /// keys that are instances of K and values that are instances of V. K must be
  /// one of `DOMString`, `USVString`, or `ByteString`.
  bool get isRecord => name == builtin.record;
}

/// Checks for whether the [SingleType] represents a `Promise`.
extension PromiseType on SingleType {
  /// Whether the type is a `Promise`.
  ///
  /// A `Promise` type is a parameterized type whose values are references to
  /// objects that “is used as a place holder for the eventual results of a
  /// deferred (and possibly asynchronous) computation result of an asynchronous
  /// operation”.
  bool get isPromise => name == builtin.promise;
}

/// Checks for whether the [SingleType] represents a buffer of data or a view on
/// to a buffer of data.
extension BufferSourceType on SingleType {
  /// Whether the type is an `ArrayBuffer`.
  ///
  /// An `ArrayBuffer` is an object that holds a pointer (which may be null) to
  /// a buffer of a fixed number of bytes.
  bool get isArrayBuffer => name == builtin.arrayBuffer;

  /// Whether the type is a `DataView`.
  ///
  /// A `DataView` is a view on to an `ArrayBuffer` that allows typed access to
  /// integers and floating point values stored at arbitrary offsets into the
  /// buffer.
  bool get isDataView => name == builtin.dataView;

  /// Whether the type is a buffer source.
  bool get isBufferSource => isArrayBuffer || isDataView || isTypedArray;
}

/// Checks for whether the [SingleType] represents a typed array.
extension TypedArrayType on SingleType {
  /// Whether the type is an `Int8Array`.
  ///
  /// An `Int8Array` is a view on to an `ArrayBuffer` that exposes it as an
  /// array of two’s complement 8-bit signed integers.
  bool get isInt8Array => name == builtin.int8Array;

  /// Whether the type is an `Int16Array`.
  ///
  /// An `Int16Array` is a view on to an `ArrayBuffer` that exposes it as an
  /// array of two’s complement 16-bit signed integers.
  bool get isInt16Array => name == builtin.int16Array;

  /// Whether the type is an `Int32Array`.
  ///
  /// An `Int32Array` is a view on to an `ArrayBuffer` that exposes it as an
  /// array of two’s complement 32-bit signed integers.
  bool get isInt32Array => name == builtin.int32Array;

  /// Whether the type is an `Uint8Array`.
  ///
  /// An `Uint8Array` is a view on to an `ArrayBuffer` that exposes it as an
  /// array of 8-bit unsigned integers.
  bool get isUint8Array => name == builtin.uint8Array;

  /// Whether the type is an `Uint16Array`.
  ///
  /// An `Uint16Array` is a view on to an `ArrayBuffer` that exposes it as an
  /// array of 16-bit unsigned integers.
  bool get isUint16Array => name == builtin.uint16Array;

  /// Whether the type is an `Uint32Array`.
  ///
  /// An `Uint32Array` is a view on to an `ArrayBuffer` that exposes it as an
  /// array of 32-bit unsigned integers.
  bool get isUint32Array => name == builtin.uint32Array;

  /// Whether the type is an `Uint8ClampedArray`.
  ///
  /// An `Uint8ClampedArray` is a view on to an `ArrayBuffer` that exposes it
  /// as an array of unsigned 8 bit integers with clamped conversions.
  bool get isUint8ClampedArray => name == builtin.uint8ClampedArray;

  /// Whether the type is a `BigInt64Array`.
  ///
  /// A `BigInt64Array` is a view on to an `ArrayBuffer` that exposes it as an
  /// array of 64-bit signed integers.
  bool get isBigInt64Array => name == builtin.bigInt64Array;

  /// Whether the type is a `BigUint64Array`.
  ///
  /// A `BigUint64Array` is a view on to an `ArrayBuffer` that exposes it as an
  /// array of 64-bit unsigned integers.
  bool get isBigUint64Array => name == builtin.bigUint64Array;

  /// Whether the type is a `Float32Array`.
  ///
  /// A `Float32Array` is a view on to an `ArrayBuffer` that exposes it as an
  /// array of 32-bit IEEE 754 floating point numbers.
  bool get isFloat32Array => name == builtin.float32Array;

  /// Whether the type is a `Float64Array`.
  ///
  /// A `Float64Array` is a view on to an `ArrayBuffer` that exposes it as an
  /// array of 64-bit IEEE 754 floating point numbers.
  bool get isFloat64Array => name == builtin.float64Array;

  /// Whether the type is a typed array.
  bool get isTypedArray =>
      isInt8Array ||
      isInt16Array ||
      isInt32Array ||
      isUint8Array ||
      isUint16Array ||
      isUint32Array ||
      isUint8ClampedArray ||
      isBigInt64Array ||
      isBigUint64Array ||
      isFloat32Array ||
      isFloat64Array;
}

/// Checks for whether the [SingleType] is built-in.
extension BuiltinType on SingleType {
  /// Whether the type is builtin.
  bool get isBuiltIn =>
      isAny ||
      isUndefined ||
      isPrimitive ||
      isString ||
      isObject ||
      isSymbol ||
      isSequence ||
      isRecord ||
      isPromise ||
      isBufferSource;
}
