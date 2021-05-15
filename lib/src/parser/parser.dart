// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:petitparser/petitparser.dart';

import '../element.dart';
import 'element_builder.dart';
import 'grammar.dart';
import 'keywords.dart' as keywords;
import 'type_builder.dart';

/// WebIDL parser definition.
///
/// Parser for the [WebIDL specification](https://heycam.github.io/webidl).
class WebIdlParserDefinition extends WebIdlGrammarDefinition {
  @override
  Parser<List<ElementBuilder>> definitions() =>
      super.definitions().map(_definitions);
  static List<ElementBuilder> _definitions(Object? value) {
    if (value == null) {
      return const <ElementBuilder>[];
    }

    final tokens = value as List<Object?>;
    final tokenDefinition = tokens[1]! as ElementBuilder
      ..extendedAttributes = tokens[0]! as List<Object>;

    return <ElementBuilder>[
      tokenDefinition,
      ...tokens[2]! as List<ElementBuilder>,
    ];
  }

  @override
  Parser<ElementBuilder> definition() =>
      super.definition().cast<ElementBuilder>();

  @override
  Parser<keywords.Keyword> argumentNameKeyword() =>
      super.argumentNameKeyword().cast<keywords.Keyword>();

  @override
  Parser<ElementBuilder> partialDefinition() =>
      super.partialDefinition().cast<ElementBuilder>();

  @override
  Parser<AttributeBuilder> readOnlyMember() =>
      super.readOnlyMember().map(_readOnlyMember);
  static AttributeBuilder _readOnlyMember(Object? value) {
    final tokens = value! as List;
    final builder = tokens[1] as AttributeBuilder;

    return builder..readOnly = true;
  }

  @override
  Parser<AttributeBuilder> readWriteAttribute() =>
      super.readWriteAttribute().cast<AttributeBuilder>();

  @override
  Parser<AttributeBuilder> inheritAttribute() =>
      super.inheritAttribute().map(_inheritAttribute);
  static AttributeBuilder _inheritAttribute(Object? value) {
    final tokens = value! as List;

    return tokens[1]! as AttributeBuilder;
  }

  @override
  Parser<AttributeBuilder> attributeRest() =>
      super.attributeRest().map(_attributeRest);
  static AttributeBuilder _attributeRest(Object? value) {
    final tokens = value! as List;

    return AttributeBuilder()
      ..name = tokens[2]! as String
      ..type = tokens[1]! as WebIdlTypeBuilder;
  }

  @override
  Parser<Object?> defaultValue() => super.defaultValue().map(_defaultValue);
  static Object? _defaultValue(Object? value) {
    // DefaultValue :: ConstValue | string | [ ] | { } | null
    if (value is List) {
      final tokens = value.cast<Token<Object?>>();
      final token = tokens[0];

      return token.value == '['
          ? const <Object?>[] // Matches []
          : const <String, Object?>{}; // Matches {}
    } else if (value is Token) {
      // Matches null
      return null;
    }

    // Matches ConstValue | string
    return value!;
  }

  @override
  Parser<OperationBuilder> operation() =>
      super.operation().cast<OperationBuilder>();

  @override
  Parser<OperationBuilder> regularOperation() =>
      super.regularOperation().map(_regularOperation);
  static OperationBuilder _regularOperation(Object? value) {
    final tokens = value! as List<Object?>;
    final builder = tokens[1]! as OperationBuilder;

    return builder..returnType = tokens[0]! as WebIdlTypeBuilder;
  }

  @override
  Parser<OperationBuilder> specialOperation() =>
      super.specialOperation().map(_specialOperation);
  static OperationBuilder _specialOperation(Object? value) {
    final tokens = value! as List<Object?>;
    final builder = tokens[1]! as OperationBuilder;

    return builder..operationType = tokens[0]! as SpecialOperation;
  }

  @override
  Parser<SpecialOperation> special() => super.special().map(_special);
  static SpecialOperation _special(Object? value) {
    final token = value! as Token;

    switch (token.value as keywords.Keyword) {
      case keywords.getter:
        return SpecialOperation.getter;
      case keywords.setter:
        return SpecialOperation.setter;
      default:
        return SpecialOperation.deleter;
    }
  }

  @override
  Parser<OperationBuilder> operationRest() =>
      super.operationRest().map(_operationRest);
  static OperationBuilder _operationRest(Object? value) {
    final tokens = value! as List<Object?>;

    return OperationBuilder()
      ..name = tokens[0]! as String
      ..arguments = tokens[2]! as List<ArgumentBuilder>;
  }

  @override
  Parser<List<ArgumentBuilder>> optionalArgumentList() =>
      super.argumentList().map(_optionalArgumentList);
  static List<ArgumentBuilder> _optionalArgumentList(Object? value) {
    if (value == null) {
      return const <ArgumentBuilder>[];
    }

    final tokens = value as List<Object?>;
    return tokens[1]! as List<ArgumentBuilder>;
  }

  @override
  Parser<List<ArgumentBuilder>> argumentList() =>
      super.argumentList().map(_argumentList);
  static List<ArgumentBuilder> _argumentList(Object? value) {
    if (value == null) {
      return const <ArgumentBuilder>[];
    }

    final tokens = value as List<Object?>;
    return <ArgumentBuilder>[
      tokens[0]! as ArgumentBuilder,
      ...tokens[1]! as List<ArgumentBuilder>,
    ];
  }

  @override
  Parser<List<ArgumentBuilder>> arguments() =>
      super.arguments().map(_arguments);
  static List<ArgumentBuilder> _arguments(Object? value) {
    if (value == null) {
      return const <ArgumentBuilder>[];
    }

    final tokens = value as List<Object?>;
    return <ArgumentBuilder>[
      tokens[1]! as ArgumentBuilder,
      ...tokens[2]! as List<ArgumentBuilder>,
    ];
  }

  @override
  Parser<ArgumentBuilder> argument() => super.argument().map(_argument);
  static ArgumentBuilder _argument(Object? value) {
    final tokens = value! as List<Object?>;

    return tokens[1]! as ArgumentBuilder
      ..extendedAttributes = tokens[0]! as List<Object>;
  }

  @override
  Parser<ArgumentBuilder> argumentRest() =>
      super.argumentRest().map(_argumentRest);
  static ArgumentBuilder _argumentRest(Object? value) {
    final tokens = value! as List<Object?>;
    final argument = ArgumentBuilder();

    if (tokens.length == 4) {
      argument
        ..isOptional = true
        ..type = tokens[1]! as WebIdlTypeBuilder
        ..name = tokens[2]! as String
        ..defaultTo = tokens[3];
    } else {
      argument
        ..type = tokens[0]! as WebIdlTypeBuilder
        ..isVariadic = tokens[1]! as bool
        ..name = tokens[2]! as String;
    }

    return argument;
  }

  @override
  Parser<bool> ellipsis() => super.ellipsis().map(_isToken);

  @override
  Parser<bool> booleanLiteral() => super.booleanLiteral().map(_booleanLiteral);
  static bool _booleanLiteral(Object? value) =>
      (value! as Token).value == 'true';

  @override
  Parser<double> floatLiteral() => super.floatLiteral().map(_floatLiteral);
  static double _floatLiteral(Object? value) {
    if (value is double) {
      return value;
    }

    final identifier = value! as Token;
    switch (identifier.value) {
      case '-Infinity':
        return double.negativeInfinity;
      case 'Infinity':
        return double.infinity;
      default /* 'NaN' */ :
        return double.nan;
    }
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
  Parser<EnumBuilder> enumeration() => super.enumeration().map(_enumeration);
  static EnumBuilder _enumeration(Object? value) {
    final tokens = value! as List<Object?>;

    return EnumBuilder()
      ..name = tokens[1]! as String
      ..values = tokens[3]! as List<String>;
  }

  @override
  Parser<List<String>> enumerationValueList() =>
      super.enumerationValueList().map(_enumerationValueList);
  static List<String> _enumerationValueList(Object? value) {
    final tokens = value! as List<Object?>;

    return <String>[
      tokens[0]! as String,
      ...tokens[1]! as List<String>,
    ];
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
    return <String>[
      tokens[0]! as String,
      ...tokens[1]! as List<String>,
    ];
  }

  @override
  Parser<TypeAliasBuilder> typeDefinition() =>
      super.typeDefinition().map(_typeDefinition);
  static TypeAliasBuilder _typeDefinition(Object? value) {
    final tokens = value! as List<Object?>;

    return TypeAliasBuilder()
      ..type = tokens[1]! as WebIdlTypeBuilder
      ..name = tokens[2]! as String;
  }

  //------------------------------------------------------------------
  // Types
  //------------------------------------------------------------------

  @override
  Parser<WebIdlTypeBuilder> type() => super.type().map(_type);
  static WebIdlTypeBuilder _type(Object? value) {
    if (value is WebIdlTypeBuilder) {
      return value;
    }

    final tokens = value! as List<Object?>;
    return (tokens[0]! as WebIdlTypeBuilder)..isNullable = tokens[1]! as bool;
  }

  @override
  Parser<WebIdlTypeBuilder> typeWithExtendedAttributes() =>
      super.typeWithExtendedAttributes().map(_typeWithExtendedAttributes);
  static WebIdlTypeBuilder _typeWithExtendedAttributes(Object? value) {
    final tokens = value! as List<Object?>;

    return (tokens[1]! as WebIdlTypeBuilder)
      ..extendedAttributes = tokens[0]! as List<Object>;
  }

  @override
  Parser<SingleTypeBuilder> singleType() =>
      super.singleType().map(_singleTypeBuilder);

  @override
  Parser<UnionTypeBuilder> unionType() => super.unionType().map(_unionType);
  static UnionTypeBuilder _unionType(Object? value) {
    final tokens = value! as List<Object?>;
    final tokenUnionMemberTypes = tokens[4]! as UnionTypeBuilder;

    tokenUnionMemberTypes.memberTypes = <WebIdlTypeBuilder>[
      tokens[1]! as WebIdlTypeBuilder,
      tokens[3]! as WebIdlTypeBuilder,
      ...tokenUnionMemberTypes.memberTypes,
    ];

    return tokenUnionMemberTypes;
  }

  @override
  Parser<WebIdlTypeBuilder> unionMemberType() =>
      super.unionMemberType().map(_unionMemberType);
  static WebIdlTypeBuilder _unionMemberType(Object? value) {
    final tokens = value! as List<Object?>;
    final token0 = tokens[0];
    if (token0 is UnionTypeBuilder) {
      return token0..isNullable = tokens[1]! as bool;
    }

    return (tokens[1]! as SingleTypeBuilder)
      ..extendedAttributes = token0! as List<Object>;
  }

  @override
  Parser<UnionTypeBuilder> unionMemberTypes() =>
      super.unionMemberTypes().map(_unionMemberTypes);
  static UnionTypeBuilder _unionMemberTypes(Object? value) {
    if (value == null) {
      return UnionTypeBuilder();
    }

    final tokens = value as List<Object?>;
    final tokenUnionMemberType = tokens[1]! as WebIdlTypeBuilder;
    final tokenUnionMemberTypes = tokens[2]! as UnionTypeBuilder;
    tokenUnionMemberTypes.memberTypes.insert(0, tokenUnionMemberType);

    return tokenUnionMemberTypes;
  }

  @override
  Parser<SingleTypeBuilder> distinguishableType() =>
      super.distinguishableType().map(_distinguishableType);
  static SingleTypeBuilder _distinguishableType(Object? value) {
    final tokens = value! as List<Object?>;
    final nullable = tokens.removeLast()! as bool;

    return _singleTypeBuilder(tokens[0])..isNullable = nullable;
  }

  @override
  Parser<SingleTypeBuilder> primitiveType() =>
      super.primitiveType().map(_singleTypeBuilder);

  @override
  Parser<SingleTypeBuilder> unrestrictedFloatType() =>
      super.unrestrictedFloatType().map(_unrestrictedFloatType);
  static SingleTypeBuilder _unrestrictedFloatType(Object? object) {
    final tokens = object! as List<Object?>;
    final tokenUnrestricted = tokens[0];
    final tokenFloatType = tokens[1]! as SingleTypeBuilder;

    if (tokenUnrestricted != null) {
      tokenFloatType.name =
          '${(tokenUnrestricted as Token).value} ${tokenFloatType.name}';
    }

    return tokenFloatType;
  }

  @override
  Parser<SingleTypeBuilder> floatType() =>
      super.floatType().map(_singleTypeBuilderFromToken);

  @override
  Parser<SingleTypeBuilder> unsignedIntegerType() =>
      super.unsignedIntegerType().map(_unsignedIntegerType);
  static SingleTypeBuilder _unsignedIntegerType(Object? value) {
    final tokens = value! as List<Object?>;
    final tokenUnsigned = tokens[0];
    final tokenIntegerType = tokens[1]! as SingleTypeBuilder;

    if (tokenUnsigned != null) {
      tokenIntegerType.name =
          '${(tokenUnsigned as Token).value} ${tokenIntegerType.name}';
    }

    return tokenIntegerType;
  }

  @override
  Parser<SingleTypeBuilder> integerType() =>
      super.integerType().map(_integerType);
  static SingleTypeBuilder _integerType(Object? object) {
    if (object is Token) {
      return _singleTypeBuilderFromToken(object);
    }

    final tokens = object! as List<Object?>;
    final tokenLong = tokens[0]! as Token;
    final tokenOptionalLong = tokens[1];
    var name = tokenLong.value as String;

    if (tokenOptionalLong != null) {
      name += ' ${(tokenOptionalLong as Token).value}';
    }

    return SingleTypeBuilder()..name = name;
  }

  @override
  Parser<SingleTypeBuilder> stringType() =>
      super.stringType().map(_singleTypeBuilderFromToken);

  @override
  Parser<SingleTypeBuilder> promiseType() =>
      super.promiseType().map(_singleTypeBuilderFromTokens);

  @override
  Parser<SingleTypeBuilder> recordType() =>
      super.recordType().map(_singleTypeBuilderFromTokens);

  @override
  Parser<bool> nullable() => super.nullable().map(_isToken);

  @override
  Parser<SingleTypeBuilder> bufferRelatedType() =>
      super.bufferRelatedType().map(_singleTypeBuilderFromToken);

  static SingleTypeBuilder _singleTypeBuilder(Object? value) {
    if (value is SingleTypeBuilder) {
      return value;
    } else if (value is List) {
      return _singleTypeBuilderFromTokens(value);
    } else {
      return _singleTypeBuilderFromToken(value);
    }
  }

  static SingleTypeBuilder _singleTypeBuilderFromTokens(Object? value) {
    final tokens = value! as List<Object?>;
    final typeArguments = <WebIdlTypeBuilder>[];
    final tokenCount = tokens.length;

    for (var i = 2; i < tokenCount; i += 2) {
      typeArguments.add(tokens[i]! as WebIdlTypeBuilder);
    }

    return _singleTypeBuilder(tokens[0]! as Token)
      ..typeArguments = typeArguments;
  }

  static SingleTypeBuilder _singleTypeBuilderFromToken(Object? value) {
    if (value is SingleTypeBuilder) {
      return value;
    }

    return SingleTypeBuilder()
      ..name = value is Token ? value.value! as String : value! as String;
  }

  static bool _isToken(Object? value) => value != null;

  //------------------------------------------------------------------
  // Extended Attributes
  //
  // The WebIDL grammar supports a more general definition for
  // extended attributes but notes that really only 5 variants are
  // actually used. So this only matches those 5 cases.
  //------------------------------------------------------------------

  @override
  Parser<List<Object>> extendedAttributeList() =>
      super.extendedAttributeList().map(_extendedAttributeList);
  static List<Object> _extendedAttributeList(Object? value) => const <Object>[];

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
