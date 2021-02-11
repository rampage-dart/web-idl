// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:petitparser/petitparser.dart';

import 'grammar.dart';

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

      if (token.value == '[') {
        // Matches [ ]
        return const <Object?>[];
      } else {
        // Matches { }
        return const <String, Object?>{};
      }
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
  // Lexical tokens
  //------------------------------------------------------------------

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
