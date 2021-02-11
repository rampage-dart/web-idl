// Copyright (c) 2020 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

/// Represents a type defined in the WebIDL specification.
abstract class WebIdlType {
  /// Whether the type is nullable.
  bool get isNullable;
}
