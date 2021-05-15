// Copyright (c) 2021 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

/// A keyword in the WebIDL specification.
class Keyword {
  const Keyword._(this.token);

  /// The token associated with the keyword.
  final String token;
}

/// The `async` keyword.
const async = Keyword._('async');

/// The `attribute` keyword.
const attribute = Keyword._('attribute');

/// The `callback` keyword.
const callback = Keyword._('callback');

/// The `const` keyword.
const constant = Keyword._('const');

/// The `constructor` keyword.
const constructor = Keyword._('constructor');

/// The `deleter` keyword.
const deleter = Keyword._('deleter');

/// The `dictionary` keyword.
const dictionary = Keyword._('dictionary');

/// The `enum` keyword.
const enumeration = Keyword._('enum');

/// The `getter` keyword.
const getter = Keyword._('getter');

/// The `includes` keyword.
const includes = Keyword._('includes');

/// The `inherit` keyword.
const inherit = Keyword._('inherit');

/// The `interface` keyword.
const interface = Keyword._('interface');

/// The `iterable` keyword.
const iterable = Keyword._('iterable');

/// The `maplike` keyword.
const maplike = Keyword._('maplike');

/// The `mixin` keyword.
const mixin = Keyword._('mixin');

/// The `namespace` keyword.
const namespace = Keyword._('namespace');

/// The `partial` keyword.
const partial = Keyword._('partial');

/// The `readonly` keyword.
const readonly = Keyword._('readonly');

/// The `required` keyword.
const required = Keyword._('required');

/// The `setlike` keyword.
const setlike = Keyword._('setlike');

/// The `setter` keyword.
const setter = Keyword._('setter');

/// The `static` keyword.
const static = Keyword._('static');

/// The `stringifier` keyword.
const stringifier = Keyword._('stringifier');

/// The `typedef` keyword.
const typedef = Keyword._('typedef');

/// The `unrestricted` keyword.
const unrestricted = Keyword._('unrestricted');
