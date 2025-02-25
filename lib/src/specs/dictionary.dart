// Copyright (c) 2025 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

import 'specs.dart';
import 'type_system.dart';

part 'dictionary.g.dart';

/// Defines an ordered map data type with a fixed, ordered set of entries,
/// termed dictionary members, where keys are strings and values are of a
/// particular type specified in the definition.
///
/// A [Dictionary]'s definition can be split across multiple fragments. Each
/// [Dictionary] only corresponds to a single definition.
@immutable
abstract class Dictionary
    implements
        Built<Dictionary, DictionaryBuilder>,
        Spec,
        NamedSpec,
        PartiallyDefinedSpec {
  /// Create a [DictionaryMember] based on result of a call to [updates].
  factory Dictionary([void Function(DictionaryBuilder)? updates]) =
      _$Dictionary;
  const Dictionary._();

  static Serializer<Dictionary> get serializer => _$dictionarySerializer;

  /// Returns the type of the inherited dictionary, or `null` if there is none.
  //SingleType? get supertype;

  /// The set of entries contained in this dictionary definition.
  ///
  /// The full dictionary definition can be split across fragments.
  BuiltList<DictionaryMember> get members;
}

/// An entry in a [Dictionary].
@immutable
abstract class DictionaryMember
    implements
        Built<DictionaryMember, DictionaryMemberBuilder>,
        Spec,
        NamedSpec,
        TypedSpec<WebIdlType> {
  /// Create a [DictionaryMember] based on result of a call to [updates].
  factory DictionaryMember([void Function(DictionaryMemberBuilder)? updates]) =
      _$DictionaryMember;
  const DictionaryMember._();

  static Serializer<DictionaryMember> get serializer =>
      _$dictionaryMemberSerializer;

  /// Whether setting the field is required.
  bool get isRequired;

  /// The default value for the argument.
  ///
  /// If the argument [isRequired] then this will be `null`. Otherwise this may
  /// be a constant.
  Object? get defaultTo;
}
