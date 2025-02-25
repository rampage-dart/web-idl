// Copyright (c) 2025 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

import 'attribute.dart';
import 'constant.dart';
import 'operation.dart';
import 'specs.dart';

part 'namespace.g.dart';

/// A definition that declares a global singleton with associated behaviors.
///
/// A [Namespace]'s definition can be split across multiple fragments. Each
/// [Namespace] only corresponds to a single definition.
@immutable
abstract class Namespace
    implements
        Built<Namespace, NamespaceBuilder>,
        Spec,
        NamedSpec,
        PartiallyDefinedSpec {
  /// Create an [Namespace] based on result of a call to [updates].
  factory Namespace([void Function(NamespaceBuilder)? updates]) = _$Namespace;
  const Namespace._();

  static Serializer<Namespace> get serializer => _$namespaceSerializer;

  /// The attributes contained in this namespace definition.
  ///
  /// The full namespace definition can be split across fragments.
  BuiltList<Attribute> get attributes;

  /// The operations contained in this namespace definition.
  ///
  /// The full namespace definition can be split across fragments.
  BuiltList<Operation> get operations;

  /// The constants defined in this namespace definition.
  ///
  /// The full namespace definition can be split across fragments.
  BuiltList<Constant> get constants;
}
