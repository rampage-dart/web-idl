// Copyright (c) 2025 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

import 'argument.dart';
import 'specs.dart';
import 'type_system.dart';

part 'iterable_interface.g.dart';

/// A data field with a given type and identifier whose value can be retrieved
/// and (in some cases) changed.
@immutable
abstract class IterableInterface
    implements Built<IterableInterface, IterableInterfaceBuilder>, Spec, ReadOnlySpec {
  factory IterableInterface([void Function(IterableInterfaceBuilder)? updates]) = _$IterableInterface;
  const IterableInterface._();

  static Serializer<IterableInterface> get serializer => _$iterableInterfaceSerializer;

  /// Whether the iteration is async
  bool get isAsync;

  /// The key type used.
  ///
  /// Can be `null` if only iterating over a set of values.
  WebIdlType? get keyType;

  /// The value type contained.
  WebIdlType get valueType;

  /// The arguments for the iteration.
  /// 
  /// Only possible when [isAsync] is `true`.
  BuiltList<Argument> get arguments;
}
