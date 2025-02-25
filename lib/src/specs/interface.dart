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
import 'type_system.dart';

part 'interface.g.dart';

/// A definition that declares some state and behavior that an object
/// implementing that interface will expose.
///
/// An [Interface]'s definition can be split across multiple fragments. Each
/// [Interface] only corresponds to a single definition.
@immutable
abstract class Interface
    implements
        Built<Interface, InterfaceBuilder>,
        Spec,
        NamedSpec,
        PartiallyDefinedSpec {
  /// Create an [Interface] based on result of a call to [updates].
  factory Interface([void Function(InterfaceBuilder)? updates]) = _$Interface;
  const Interface._();

  static Serializer<Interface> get serializer => _$interfaceSerializer;

  /// Returns the type of the inherited interface, or `null` if there is none.
  SingleType? get supertype;

  /// Whether the interface is a mixin.
  ///
  /// An interface mixin declares state and behavior that can be included by one
  /// or more interfaces, and that are exposed by objects that implement an
  /// interface that includes the interface mixin.
  bool get isMixin;

  /// Whether the interface is a callback.
  ///
  /// _A callback interface is not an interface. The name and syntax are left
  /// over from earlier versions of this standard, where these concepts had more
  /// in common._
  bool get isCallback;

  /// The constructors for the interface.
  BuiltList<Operation> get constructors;

  /// The attributes exposed on the interface.
  BuiltList<Attribute> get attributes;

  /// The operations available for the interface.
  BuiltList<Operation> get operations;

  /// The constants defined on the interface.
  BuiltList<Constant> get constants;
}
