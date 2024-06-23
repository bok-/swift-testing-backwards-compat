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

import Example
import Testing
import XCTest

#if compiler(<6)

final class EchoTestCase: XCTestCase {
    func testSwiftTesting() async {
        await XCTestScaffold.runTestsInSuite(EchoTests.self, hostedBy: self)
    }
}

#endif

@Suite
private struct EchoTests {

    @Test(
        "Returns what we put in",
        arguments: [
            123, 456, 789, 1011, 1213
        ]
    )
    func returnsInputIntegers(value: Int) {
        #expect(echo(value) == value)
    }

}
