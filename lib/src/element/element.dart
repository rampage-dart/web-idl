// Copyright (c) 2020 the Rampage Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

/// The base class for all of the constructs within the WebIDL element model.
///
/// The element model depicts the semantics of the WebIDL format. It represents
/// things declared with a [name].
abstract class Element {
  /// The name of this element, or the empty string if the element does not have
  /// a name.
  String get name;
}
