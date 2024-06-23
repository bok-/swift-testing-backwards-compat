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

#if compiler(<6.0)

import Foundation
@_spi(ForToolsIntegrationOnly) @testable import Testing
import XCTest

public extension XCTestScaffold {

    /// Run all tests for the given suite name and write output to the
    /// standard error stream.
    ///
    /// - Parameters:
    ///   - suite:    The `@Suite` to run tests for.
    ///   - testCase: An `XCTestCase` instance that hosts tests implemented using
    ///     the testing library.
    ///
    /// Output from the testing library is written to the standard error stream.
    /// The format of the output is not meant to be machine-readable and is
    /// subject to change.
    ///
    /// ### Configuring output
    ///
    /// By default, this function uses
    /// [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code) to
    /// colorize output if the environment and platform support them. To disable
    /// colorized output, set the [`NO_COLOR`](https://www.no-color.org)
    /// environment variable.
    ///
    /// On macOS, if the SF&nbsp;Symbols app is installed, SF&nbsp;Symbols are
    /// assumed to be present in the font used for rendering within the Unicode
    /// Private Use Area. To disable the use of SF&nbsp;Symbols on macOS, set the
    /// `SWT_SF_SYMBOLS_ENABLED` environment variable to `"false"` or `"0"`.
    ///
    /// ## See Also
    ///
    /// - <doc:TemporaryGettingStarted>
#if SWIFT_PM_SUPPORTS_SWIFT_TESTING
    @available(*, deprecated, message: "This version of Swift Package Manager supports running swift-testing tests directly. This function has no effect and will be removed in a future release.")
#else
    @available(swift, deprecated: 100000.0, message: "This function is provided temporarily to aid in integrating the testing library with existing tools such as Swift Package Manager. It will be removed in a future release.")
#endif
    static func runTestsInSuite(_ suite: Any.Type, hostedBy testCase: XCTestCase) async {
        let suiteTypeInfo = TypeInfo(describing: suite)
#if SWIFT_PM_SUPPORTS_SWIFT_TESTING
        let message = Event.ConsoleOutputRecorder.warning(
            "This version of Swift Package Manager supports running swift-testing tests directly. Ignoring call to \(#function).",
            options: .for(.stderr)
        )
#if SWT_TARGET_OS_APPLE && !SWT_NO_FILE_IO
        try? FileHandle.stderr.write(message)
#else
        print(message)
#endif
#else
        let testCase = UncheckedSendable(rawValue: testCase)
#if SWT_TARGET_OS_APPLE
        let isProcessLaunchedByXcode = Environment.variable(named: "XCTestSessionIdentifier") != nil
#endif

        var configuration = Configuration()
        configuration.isParallelizationEnabled = false
        configuration.testFilter = .init(membership: .including) { test in
            if test.isSuite && test.containingTypeInfo == suiteTypeInfo {
                return true
            }
            return false
        }
        configuration.eventHandler = { event, context in
            guard case let .issueRecorded(issue) = event.kind else {
                return
            }

#if SWT_TARGET_OS_APPLE
            if issue.isKnown {
                XCTExpectFailure {
                    testCase.rawValue.record(XCTIssue(issue, processLaunchedByXcode: isProcessLaunchedByXcode))
                }
            } else {
                testCase.rawValue.record(XCTIssue(issue, processLaunchedByXcode: isProcessLaunchedByXcode))
            }
#else
            // NOTE: XCTestCase.recordFailure(withDescription:inFile:atLine:expected:)
            // does not behave as it might appear. The `expected` argument determines
            // if the issue represents an assertion failure or a thrown error.
            if !issue.isKnown {
                testCase.rawValue.recordFailure(withDescription: String(describing: issue),
                                                inFile: issue.sourceLocation?._filePath ?? "<unknown>",
                                                atLine: issue.sourceLocation?.line ?? 0,
                                                expected: true)
            }
#endif
        }

        var options = Event.ConsoleOutputRecorder.Options()
#if !SWT_NO_FILE_IO
        options = .for(.stderr)
#endif
        options.isVerbose = (Environment.flag(named: "SWT_VERBOSE_OUTPUT") == true)

        await runTests(options: options, configuration: configuration)
#endif
    }

}

#endif // compiler(<6.0)
