//===----------------------------------------------------------------------===//
//
// This source file is part of an example project demonstrating backwards
// compatibility with swift-testing and Xcode 15.4 / Swift 5.10.
//
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

/// Just returns the value you provide
public func echo<T>(_ value: T) -> T {
    value
}
