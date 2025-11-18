// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

// \TODO Remove after WebIdlParserDefinition completely defined
// ignore_for_file: unnecessary_overrides

import 'package:petitparser/petitparser.dart';

import '../../specs.dart';
import '../specs/builtin_types.dart' as builtin;
import 'grammar.dart';
import 'keywords.dart' as keywords;

/// WebIDL parser definition.
///
/// Parser for the [WebIDL specification](https://heycam.github.io/webidl).
class WebIdlParserDefinition extends WebIdlGrammarDefinition {
  @override
  Parser<bool> ellipsis() => super.ellipsis().map(_isToken);

  @override
  Parser<Operation> constructor() =>
      super.constructor().map(_constructor);
  static Operation _constructor(Object? value) {
    final tokens = value! as List<Object?>;

    return Operation((o) => o
      ..name = (tokens[0]! as keywords.Keyword).token
      ..arguments.addAll(tokens[2]! as List<Argument>));
  }

  @override
  Parser<AttributeBuilder> stringifier() =>
      super.stringifier().map(_stringifier);
  static AttributeBuilder _stringifier(Object? value) {
    final tokens = value! as List<Object?>;

    return tokens[1]! as AttributeBuilder..isStringifier = true;
  }

  @override
  Parser<Attribute> stringifierRest() =>
      super.stringifierRest().map(_stringifierRest);
  static Attribute _stringifierRest(Object? value) {
    if (value is Token) {
      return Attribute(
        (a) =>
            a
              ..name = 'stringifier'
              ..isStringifier = true
              ..type = _singleTypeFromToken(builtin.domString),
      );
    }

    final tokens = value! as List<Object?>;
    return (tokens[1]! as Attribute).rebuild(
      (a) => a..readOnly = tokens[0] != null,
    );
  }

  @override
  Parser<Spec> staticMember() => super.staticMember().map(_staticMember);
  static Spec _staticMember(Object? value) {
    final tokens = value! as List<Object?>;
    final spec = tokens[1]! as Spec;

    return spec is Attribute
        ? spec.rebuild((a) => a..isStatic = true)
        : (spec as Operation).rebuild((o) => o..isStatic = true);
  }

  @override
  Parser<Spec> staticMemberRest() =>
      super.staticMemberRest().map(_staticMemberRest);
  static Spec _staticMemberRest(Object? value) {
    if (value is Operation) {
      return value;
    }

    final tokens = value! as List<Object?>;
    return (tokens[1]! as Attribute).rebuild((a) => a..readOnly = tokens[0] != null);
  }

  @override
  Parser<IterableInterface> iterable() => super.iterable().map(_iterable);
  static IterableInterface _iterable(Object? value) {
    final tokens = value as List<Object?>;
    final requiredType = tokens[2]! as WebIdlType;
    final optionalType = tokens[3] as WebIdlType?;

    late final WebIdlType? keyType;
    late final WebIdlType valueType;

    if (optionalType != null) {
      keyType = requiredType;
      valueType = optionalType;
    } else {
      keyType = null;
      valueType = requiredType;
    }

    return IterableInterface(
      (i) =>
          i
            ..keyType = keyType
            ..valueType = valueType,
    );
  }

  @override
  Parser<WebIdlType?> optionalType() => super.optionalType().map(_optionalType);
  static WebIdlType? _optionalType(Object? value) {
    if (value == null) {
      return null;
    }

    final tokens = value as List<Object?>;
    return tokens[1]! as WebIdlType;
  }

  @override
  Parser<IterableInterface> asyncIterable() =>
      super.asyncIterable().map(_asyncIterable);
  static IterableInterface _asyncIterable(Object? value) {
    final tokens = value as List<Object?>;
    final requiredType = tokens[3]! as WebIdlType;
    final optionalType = tokens[4] as WebIdlType?;

    late final WebIdlType? keyType;
    late final WebIdlType valueType;

    if (optionalType != null) {
      keyType = requiredType;
      valueType = optionalType;
    } else {
      keyType = null;
      valueType = requiredType;
    }

    return IterableInterface(
      (i) =>
          i
            ..isAsync = true
            ..keyType = keyType
            ..valueType = valueType
            ..arguments.addAll(tokens[6]! as List<Argument>),
    );
  }

  @override
  Parser<List<Argument>> optionalArgumentList() =>
      super.argumentList().map(_optionalArgumentList);
  static List<Argument> _optionalArgumentList(Object? value) {
    if (value == null) {
      return const <Argument>[];
    }

    final tokens = value as List<Object?>;
    return tokens[1]! as List<Argument>;
  }

  @override
  Parser<Maplike> readWriteMaplike() =>
      super.readWriteMaplike().cast<Maplike>();

  @override
  Parser<Maplike> maplikeRest() => super.maplikeRest().map(_maplikeRest);
  static Maplike _maplikeRest(Object? value) {
    final tokens = value! as List<Object?>;

    return Maplike(
      (m) =>
          m
            ..keyType = tokens[2]! as WebIdlType
            ..valueType = tokens[4]! as WebIdlType,
    );
  }

  @override
  Parser<Setlike> readWriteSetlike() =>
      super.readWriteSetlike().cast<Setlike>();

  @override
  Parser<Setlike> setlikeRest() => super.setlikeRest().map(_setlikeRest);
  static Setlike _setlikeRest(Object? value) {
    final tokens = value! as List<Object?>;

    return Setlike((m) => m..valueType = tokens[2]! as WebIdlType);
  }

  @override
  Parser<Namespace> namespace() => super.namespace().map(_namespace);
  static Namespace _namespace(Object? value) {
    final tokens = value! as List<Object?>;
    final members = tokens[3]! as List<Spec>;

    return Namespace(
      (n) =>
          n
            ..name = tokens[1]! as String
            ..attributes.addAll(members.whereType<Attribute>())
            ..operations.addAll(members.whereType<Operation>())
            ..constants.addAll(members.whereType<Constant>()),
    );
  }

  @override
  Parser<List<Spec>> namespaceMembers() =>
      super.namespaceMembers().map(_namespaceMembers);
  static List<Spec> _namespaceMembers(Object? value) {
    if (value == null) {
      return const <Spec>[];
    }

    final tokens = value as List<Object?>;
    final spec = (tokens[1]! as Spec).rebuild(
      (s) => s..extendedAttributes.addAll(tokens[0]! as List<Object>),
    );

    return <Spec>[spec, ...tokens[2]! as List<Spec>];
  }

  @override
  Parser<Dictionary> dictionary() => super.dictionary().map(_dictionary);
  static Dictionary _dictionary(Object? value) {
    final tokens = value! as List<Object?>;

    return Dictionary(
      (d) =>
          d
            ..name = tokens[1]! as String
            ..supertype =
                (tokens[2] as SingleType?)
                    ?.toBuilder() // ??? this ok?
            ..members.addAll(tokens[4]! as List<DictionaryMember>),
    );
  }

  @override
  Parser<List<DictionaryMember>> dictionaryMembers() =>
      super.dictionaryMembers().map(_dictionaryMembers);
  static List<DictionaryMember> _dictionaryMembers(Object? value) {
    if (value == null) {
      return const <DictionaryMember>[];
    }

    final tokens = value as List<Object?>;
    return <DictionaryMember>[
      tokens[0]! as DictionaryMember,
      ...tokens[1]! as List<DictionaryMember>,
    ];
  }

  @override
  Parser<DictionaryMember> dictionaryMember() =>
      super.dictionaryMember().map(_dictionaryMember);
  static DictionaryMember _dictionaryMember(Object? value) {
    final tokens = value! as List<Object?>;

    return (tokens[1]! as DictionaryMember).rebuild(
      (d) => d..extendedAttributes.addAll(tokens[0]! as List<Object>),
    );
  }

  @override
  Parser<DictionaryMember> dictionaryMemberRest() =>
      super.dictionaryMemberRest().map(_dictionaryMemberRest);
  static DictionaryMember _dictionaryMemberRest(Object? value) {
    final tokens = value! as List<Object?>;

    if (tokens[0]! is keywords.Keyword) {
      return DictionaryMember(
        (d) =>
            d
              ..name = tokens[2]! as String
              ..type = tokens[1]! as WebIdlType,
      );
    }

    return DictionaryMember(
      (d) =>
          d
            ..name = tokens[1]! as String
            ..type = tokens[0]! as WebIdlType
            ..defaultTo = tokens[2],
    );
  }

  @override
  Parser<Dictionary> partialDictionary() =>
      super.partialDictionary().map(_partialDictionary);
  static Dictionary _partialDictionary(Object? value) {
    final tokens = value! as List<Object?>;

    return Dictionary(
      (d) =>
          d
            ..name = tokens[1]! as String
            ..members.addAll(tokens[3]! as List<DictionaryMember>),
    );
  }

  @override
  Parser<Object?> defaultTo() => super.defaultTo().map(_defaultTo);
  static Object? _defaultTo(Object? value) {
    if (value == null) {
      return null;
    }

    final tokens = value as List<Object?>;
    return tokens[1];
  }

  @override
  Parser<Enum> enumeration() => super.enumeration().map(_enumeration);
  static Enum _enumeration(Object? value) {
    final tokens = value! as List<Object?>;

    return Enum(
      (e) =>
          e
            ..name = tokens[1]! as String
            ..values.addAll(tokens[3]! as List<String>),
    );
  }

  @override
  Parser<List<String>> enumerationValueList() =>
      super.enumerationValueList().map(_enumerationValueList);
  static List<String> _enumerationValueList(Object? value) {
    final tokens = value! as List<Object?>;

    return <String>[tokens[0]! as String, ...tokens[1]! as List<String>];
  }

  @override
  Parser<List<String>> enumerationValueListComma() =>
      super.enumerationValueListComma().map(_enumerationValueListComma);
  static List<String> _enumerationValueListComma(Object? value) {
    if (value == null) {
      return const <String>[];
    }

    final tokens = value as List<Object?>;
    return tokens[1]! as List<String>;
  }

  @override
  Parser<List<String>> enumerationValueListString() =>
      super.enumerationValueListString().map(_enumerationValueListString);
  static List<String> _enumerationValueListString(Object? value) {
    if (value == null) {
      return const <String>[];
    }

    final tokens = value as List<Object?>;
    return <String>[tokens[0]! as String, ...tokens[1]! as List<String>];
  }

  @override
  Parser<FunctionTypeAlias> callbackRest() =>
      super.callbackRest().map(_callbackRest);
  static FunctionTypeAlias _callbackRest(Object? value) {
    final tokens = value! as List<Object?>;

    return FunctionTypeAlias(
      (f) =>
          f
            ..name = tokens[0]! as String
            ..returnType = tokens[2]! as WebIdlType
            ..arguments.addAll(tokens[4]! as List<Argument>),
    );
  }

  @override
  Parser<TypeAlias> typeDefinition() =>
      super.typeDefinition().map(_typeDefinition);
  static TypeAlias _typeDefinition(Object? value) {
    final tokens = value! as List<Object?>;

    return TypeAlias(
      (t) =>
          t
            ..type = tokens[1]! as WebIdlType
            ..name = tokens[2]! as String,
    );
  }

  //------------------------------------------------------------------
  // Types
  //------------------------------------------------------------------

  @override
  Parser<WebIdlType> type() => super.type().map(_type);
  static WebIdlType _type(Object? value) {
    if (value is WebIdlType) {
      return value;
    }

    final tokens = value! as List<Object?>;
    return (tokens[0]! as WebIdlType).rebuild(
      (t) => t..isNullable = tokens[1]! as bool,
    );
  }

  @override
  Parser<WebIdlType> typeWithExtendedAttributes() =>
      super.typeWithExtendedAttributes().map(_typeWithExtendedAttributes);
  static WebIdlType _typeWithExtendedAttributes(Object? value) {
    final tokens = value! as List<Object?>;

    return (tokens[1]! as WebIdlType).rebuild(
      (t) => t..extendedAttributes.addAll(tokens[0]! as List<Object>),
    );
  }

  @override
  Parser<SingleType> singleType() => super.singleType().map(_singleType);

  @override
  Parser<UnionType> unionType() => super.unionType().map(_unionType);
  static UnionType _unionType(Object? value) {
    final tokens = value! as List<Object?>;
    final tokenUnionMemberTypes = tokens[4]! as UnionType;

    return tokenUnionMemberTypes.rebuild(
      (t) =>
          t
            ..memberTypes.addAll(<WebIdlType>[
              tokens[1]! as WebIdlType,
              tokens[3]! as WebIdlType,
              ...tokenUnionMemberTypes.memberTypes,
            ]),
    );
  }

  @override
  Parser<WebIdlType> unionMemberType() =>
      super.unionMemberType().map(_unionMemberType);
  static WebIdlType _unionMemberType(Object? value) {
    final tokens = value! as List<Object?>;
    final token0 = tokens[0];
    if (token0 is UnionType) {
      return token0.rebuild((t) => t..isNullable = tokens[1]! as bool);
    }

    return (tokens[1]! as SingleType).rebuild(
      (t) => t..extendedAttributes.addAll(token0! as List<Object>),
    );
  }

  @override
  Parser<UnionType> unionMemberTypes() =>
      super.unionMemberTypes().map(_unionMemberTypes);
  static UnionType _unionMemberTypes(Object? value) {
    if (value == null) {
      return UnionType();
    }

    final tokens = value as List<Object?>;
    final tokenUnionMemberType = tokens[1]! as WebIdlType;
    final tokenUnionMemberTypes = tokens[2]! as UnionType;

    return tokenUnionMemberTypes.rebuild(
      (t) => t..memberTypes.insert(0, tokenUnionMemberType),
    );
  }

  @override
  Parser<SingleType> distinguishableType() =>
      super.distinguishableType().map(_distinguishableType);
  static SingleType _distinguishableType(Object? value) {
    final tokens = value! as List<Object?>;
    final nullable = tokens.removeLast()! as bool;

    return _singleType(tokens[0]).rebuild((t) => t..isNullable = nullable);
  }

  @override
  Parser<SingleType> primitiveType() => super.primitiveType().map(_singleType);

  @override
  Parser<SingleType> unrestrictedFloatType() =>
      super.unrestrictedFloatType().map(_unrestrictedFloatType);
  static SingleType _unrestrictedFloatType(Object? object) {
    final tokens = object! as List<Object?>;
    final tokenUnrestricted = tokens[0];
    final tokenFloatType = tokens[1]! as SingleType;

    return tokenUnrestricted != null
        ? tokenFloatType.rebuild(
          (t) =>
              t
                ..name =
                    '${(tokenUnrestricted as Token).value} '
                    '${tokenFloatType.name}',
        )
        : tokenFloatType;
  }

  @override
  Parser<SingleType> floatType() => super.floatType().map(_singleTypeFromToken);

  @override
  Parser<SingleType> unsignedIntegerType() =>
      super.unsignedIntegerType().map(_unsignedIntegerType);
  static SingleType _unsignedIntegerType(Object? value) {
    final tokens = value! as List<Object?>;
    final tokenUnsigned = tokens[0];
    final tokenIntegerType = tokens[1]! as SingleType;

    return tokenUnsigned != null
        ? tokenIntegerType.rebuild(
          (t) =>
              t
                ..name =
                    '${(tokenUnsigned as Token).value} '
                    '${tokenIntegerType.name}',
        )
        : tokenIntegerType;
  }

  @override
  Parser<SingleType> integerType() => super.integerType().map(_integerType);
  static SingleType _integerType(Object? object) {
    if (object is Token) {
      return _singleTypeFromToken(object);
    }

    final tokens = object! as List<Object?>;
    final tokenLong = tokens[0]! as Token;
    final tokenOptionalLong = tokens[1];
    var name = tokenLong.value as String;

    if (tokenOptionalLong != null) {
      name += ' ${(tokenOptionalLong as Token).value}';
    }

    return SingleType((t) => t..name = name);
  }

  @override
  Parser<SingleType> stringType() =>
      super.stringType().map(_singleTypeFromToken);

  @override
  Parser<SingleType> promiseType() =>
      super.promiseType().map(_singleTypeFromTokens);

  @override
  Parser<SingleType> recordType() =>
      super.recordType().map(_singleTypeFromTokens);

  @override
  Parser<bool> nullable() => super.nullable().map(_isToken);

  @override
  Parser<SingleType> bufferRelatedType() =>
      super.bufferRelatedType().map(_singleTypeFromToken);

  static SingleType _singleType(Object? value) {
    if (value is SingleType) {
      return value;
    } else if (value is List) {
      return _singleTypeFromTokens(value);
    } else {
      return _singleTypeFromToken(value);
    }
  }

  static SingleType _singleTypeFromTokens(Object? value) {
    final tokens = value! as List<Object?>;
    final typeArguments = <WebIdlType>[];
    final tokenCount = tokens.length;

    for (var i = 2; i < tokenCount; i += 2) {
      typeArguments.add(tokens[i]! as WebIdlType);
    }

    return _singleType(
      tokens[0]! as Token,
    ).rebuild((t) => t..typeArguments.addAll(typeArguments));
  }

  static SingleType _singleTypeFromToken(Object? value) {
    if (value is SingleType) {
      return value;
    }

    return SingleType(
      (t) =>
          t..name = value is Token ? value.value! as String : value! as String,
    );
  }

  static bool _isToken(Object? value) => value != null;

  //------------------------------------------------------------------
  // Lexical tokens
  //------------------------------------------------------------------

  @override
  Parser<String> identifier() =>
      super.identifier().flatten().map((str) => str.trim());

  @override
  Parser<String> stringLiteral() => super.stringLiteral().map(_stringLiteral);
  static String _stringLiteral(Object? value) {
    // Grammar is `"<values>"`
    final tokens = value! as List;

    return (tokens[1] as List<String>).join();
  }

  @override
  Parser<int> integer() => super.integer().map(_integer);
  static int _integer(Object? value) {
    final tokens = value! as List<Object?>;
    final tokenSign = tokens[0] != null ? -1 : 1;
    final tokenValue = tokens[1]! as int;

    return tokenSign * tokenValue;
  }

  @override
  Parser<int> decimalInteger() => super.decimalInteger().map(_decimalInteger);
  static int _decimalInteger(Object? value) {
    final asString = (value! as List<Object?>).join();
    return int.parse(asString);
  }

  @override
  Parser<int> hexadecimalInteger() =>
      super.hexadecimalInteger().map(_hexadecimalInteger);
  static int _hexadecimalInteger(Object? value) {
    final tokens = value! as List<Object?>;

    // Ignore first group its just 0x
    // The second group is all the digits
    final digits = tokens[1]! as List<Object?>;

    return int.parse(digits.join(), radix: 16);
  }

  @override
  Parser<int> octalInteger() => super.octalInteger().map(_octalInteger);
  static int _octalInteger(Object? value) {
    final tokens = value! as List<Object?>;

    // Ignore first group its just a 0
    // The second group is all the digits
    final digits = tokens[1]! as List<Object?>;

    // An empty list means this is 0
    if (digits.isEmpty) {
      return 0;
    }

    return int.parse(digits.join(), radix: 8);
  }

  @override
  Parser<double> decimal() => super.decimal().flatten().map(_decimal);
  static double _decimal(String value) => double.parse(value);

  //------------------------------------------------------------------
  // Keyword definitions.
  //------------------------------------------------------------------

  @override
  Parser<keywords.Keyword> asyncKeyword() =>
      super.asyncKeyword().map((_) => keywords.async);

  @override
  Parser<keywords.Keyword> attributeKeyword() =>
      super.attributeKeyword().map((_) => keywords.attribute);

  @override
  Parser<keywords.Keyword> callbackKeyword() =>
      super.callbackKeyword().map((_) => keywords.callback);

  @override
  Parser<keywords.Keyword> constKeyword() =>
      super.constKeyword().map((_) => keywords.constant);

  @override
  Parser<keywords.Keyword> constructorKeyword() =>
      super.constructorKeyword().map((_) => keywords.constructor);

  @override
  Parser<keywords.Keyword> deleterKeyword() =>
      super.deleterKeyword().map((_) => keywords.deleter);

  @override
  Parser<keywords.Keyword> dictionaryKeyword() =>
      super.dictionaryKeyword().map((_) => keywords.dictionary);

  @override
  Parser<keywords.Keyword> enumKeyword() =>
      super.enumKeyword().map((_) => keywords.enumeration);

  @override
  Parser<keywords.Keyword> getterKeyword() =>
      super.getterKeyword().map((_) => keywords.getter);

  @override
  Parser<keywords.Keyword> includesKeyword() =>
      super.includesKeyword().map((_) => keywords.includes);

  @override
  Parser<keywords.Keyword> inheritKeyword() =>
      super.inheritKeyword().map((_) => keywords.inherit);

  @override
  Parser<keywords.Keyword> interfaceKeyword() =>
      super.interfaceKeyword().map((_) => keywords.interface);

  @override
  Parser<keywords.Keyword> iterableKeyword() =>
      super.iterableKeyword().map((_) => keywords.iterable);

  @override
  Parser<keywords.Keyword> maplikeKeyword() =>
      super.maplikeKeyword().map((_) => keywords.maplike);

  @override
  Parser<keywords.Keyword> mixinKeyword() =>
      super.mixinKeyword().map((_) => keywords.mixin);

  @override
  Parser<keywords.Keyword> namespaceKeyword() =>
      super.namespaceKeyword().map((_) => keywords.namespace);

  @override
  Parser<keywords.Keyword> partialKeyword() =>
      super.partialKeyword().map((_) => keywords.partial);

  @override
  Parser<keywords.Keyword> readonlyKeyword() =>
      super.readonlyKeyword().map((_) => keywords.readonly);

  @override
  Parser<keywords.Keyword> requiredKeyword() =>
      super.requiredKeyword().map((_) => keywords.required);

  @override
  Parser<keywords.Keyword> setlikeKeyword() =>
      super.setlikeKeyword().map((_) => keywords.setlike);

  @override
  Parser<keywords.Keyword> setterKeyword() =>
      super.setterKeyword().map((_) => keywords.setter);

  @override
  Parser<keywords.Keyword> staticKeyword() =>
      super.staticKeyword().map((_) => keywords.static);

  @override
  Parser<keywords.Keyword> stringifierKeyword() =>
      super.stringifierKeyword().map((_) => keywords.stringifier);

  @override
  Parser<keywords.Keyword> typedefKeyword() =>
      super.typedefKeyword().map((_) => keywords.typedef);

  @override
  Parser<keywords.Keyword> unrestrictedKeyword() =>
      super.unrestrictedKeyword().map((_) => keywords.unrestricted);
}
