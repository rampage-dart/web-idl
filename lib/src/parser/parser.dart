// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:petitparser/petitparser.dart';

import 'grammar.dart';
import 'type_builder.dart';

/// WebIDL parser.
class WebIdlParser extends GrammarParser {
  /// Creates an instance of the [WebIdlParser] class.
  WebIdlParser() : super(WebIdlParserDefinition());
}

/// WebIDL parser definition.
///
/// Parser for the [WebIDL specification](https://heycam.github.io/webidl).
class WebIdlParserDefinition extends WebIdlGrammarDefinition {
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

  //------------------------------------------------------------------
  // Types
  //------------------------------------------------------------------

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
  Parser<bool> nullable() => super.nullable().map(_nullable);
  static bool _nullable(Object? value) => value != null;

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
}
