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

part 'operation.g.dart';

/// A declaration of a certain kind of special behavior on objects implementing
/// the interface on which the special operation declarations appear.
enum SpecialOperation {
  /// Defines behavior for when an object is indexed for property retrieval.
  getter,

  /// Defines behavior for when an object is indexed for property assignment or
  /// creation.
  setter,

  /// Defines behavior for when an object is indexed for property deletion.
  deleter,
}

/// Defines a behavior that can be invoked on objects implementing the
/// interface.
@immutable
abstract class Operation
    implements
        Built<Operation, OperationBuilder>,
        Spec,
        NamedSpec,
        FunctionTypedSpec,
        StaticSpec {
  /// Create an [Operation] based on result of a call to [updates].
  factory Operation([void Function(OperationBuilder)? updates]) = _$Operation;
  const Operation._();

  static Serializer<Operation> get serializer => _$operationSerializer;

  /// The [SpecialOperation] type; if applicable.
  SpecialOperation? get operationType;
}
