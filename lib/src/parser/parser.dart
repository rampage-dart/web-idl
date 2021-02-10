// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

import 'package:petitparser/petitparser.dart';

import '../grammar.dart';

/// WebIDL parser.
class WebIdlParser extends GrammarParser {
  /// Creates an instance of the [WebIdlParser] class.
  WebIdlParser() : super(WebIdlParserDefinition());
}

/// WebIDL parser definition.
///
/// Parser for the [WebIDL specification](https://heycam.github.io/webidl).
class WebIdlParserDefinition extends WebIdlGrammarDefinition {
  //------------------------------------------------------------------
  // Lexical tokens
  //------------------------------------------------------------------

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
}
