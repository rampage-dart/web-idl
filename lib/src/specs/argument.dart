// Copyright (c) 2025 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

import 'specs.dart';
import 'type_system.dart';

part 'argument.g.dart';

/// An argument to an operation or callback.
@immutable
abstract class Argument
    implements
        Built<Argument, ArgumentBuilder>,
        Spec,
        NamedSpec,
        TypedSpec<WebIdlType> {
  /// Create an [Argument] based on result of a call to [updates].
  factory Argument([void Function(ArgumentBuilder)? updates]) = _$Argument;
  const Argument._();

  static Serializer<Argument> get serializer => _$argumentSerializer;

  /// Whether the argument is optional.
  bool get isOptional;

  /// Whether the argument is variadic.
  bool get isVariadic;

  /// The default value for the argument.
  ///
  /// If the argument is required then this will be `null`. Otherwise this may
  /// be a constant.
  Object? get defaultTo;
}
