This project is an EXAMPLE demonstrating backwards compatibility for [swift-testing](https://github.com/apple/swift-testing) and how you might be able to support it when running under Xcode 16 (Swift 6) and Xcode 15.4 (Swift 5.10).

>[!Important]
>This example project comes with no warranty. The versions of swift-testing used are considered pre-release so use it in production at your own risk.

## Background

Swift Testing has been in development as an open source project since September 2023, and probably longer internally. WWDC 2024 announced that it would be distributed with Xcode 16 and was the future for testing on the platform. If you somehow landed here without hearing about that you can learn more about Swift Testing and Xcode 16 at the following:

- [Swift Testing](https://developer.apple.com/documentation/testing) (Apple Developer Documentation)
- [Swift Testing](https://github.com/apple/swift-testing) (Open Source Package)
- [Meet Swift Testing](https://developer.apple.com/wwdc24/10179) (WWDC24 session)
- [Go further with Swift Testing](https://developer.apple.com/wwdc24/10195) (WWDC24 session)

## Backwards compatibility

Swift Testing has been one of the most popular announcements in my team from WWDC 24. A lot of people were looking forward to it, and some were too impatient to wait until Xcode 16 is made generally available in September or so and wanted to see if we can adopt it right now.

The TLDR here is: you can!

Swift Testing 0.7.0 was the last release to support Swift 5.10 (this post describes the plan to move to Swift 6 as a minimum), and it includes scaffolding that allows you to trigger `@Test`s  from XCTest. This is not risk free however, and those risks are detailed below.

### What's in this example package

This package includes code allowing you to use Swift Testing with both Xcode 16 and Xcode 15.4 (theoretically 15.3 too but I haven't tested that). Here's a brief description of whats included:

- `Package.swift`: The default Package.swift file targeting Swift 6+. Put your normal dependencies and targets here.
- `Package@swift-5.10.swift`: A Package.swift target Swift 5.10. This is basically a duplicate of the normal Package.swift but adds a dependency on swift-testing @ 0.7.0 and the Swift/Cxx settings they use.
- `Sources/Example/Echo.swift`: Some code so the package isn't empty.
- `Tests/ExampleTests/EchoTests.swift`: Example tests that run on both Xcode 15.4 and Xcode 16.
- `Tests/ExampleTests/TestRunner.swift`: A helper that copy/pastes the `XCTestScaffold.runAllTests()` method but adds a test filter so you can run a specific suite of tests.
### How it works

Per `EchoTests.swift`, we can create `@Test` and `@Suite` like normal and for Xcode 16 that's all we need. For Xcode 15.4 we need to shim those tests into XCTest using the following:

```swift
#if compiler(<6)
final class EchoTestCase: XCTestCase {
    func testSwiftTesting() async {
        await XCTestScaffold.runTestsInSuite(EchoTests.self, hostedBy: self)
    }
}
#endif
```

This creates an `XCTestCase` that XCTest will pick up like normal, and a single test method that uses our `XCTestScaffold` extension to run all of the tests in a single `@Suite`. Swift Testing provides a method that lets you run every `@Test` across the target, but I think its nicer to be able to have separate test cases for each suite instead of one failed test for the entire project.

## Risks / downsides

This approach is not without its risks. At the time of writing Swift Testing has moved on to version 0.10.0 and I assume this is the version that is bundled with Xcode 16. There are (minimal) API differences between 0.7.0 and 0.10.0 but there are a number of behavioural differences you might hit between Xcode 16 and Xcode 15.4 with the open source package. The main differences are listed below but note this list is not exhaustive:

- In Xcode 16 you will still see the `XCTestScaffold`-based test cases in the test navigator but they won't be run because they are compiled out. The tests themselves are run directly.
- Exit tests are not available in 0.7.0 (macOS / Linux only)
- Source location capture is slightly different (individual arguments for `fileID:filePath:line:column:` vs `sourceLocation:`) though this shouldn't have much impact on your API unless you write your own wrappers.
- Some `Configuration.TestFilter` options have changed, but you're probably not using those unless you're invoking tests manually.
- In 0.10.0 Collections are passed in to the macro using closures.
- `Trait.serial` was renamed to `Trait.serialized`
- `Trait.bug()` now takes a [bug identifier](https://developer.apple.com/documentation/testing/bugidentifiers) instead of a bug relationship enum.
- Test time limits do not support precisions less than 1 minute in 0.10.0.
- Using XCTest assertions (eg. `XCAssertEqual`) within `@Test`s is apparently supported under Xcode 16 but while they appear to work under 15.4 the behaviour is undefined ([source](https://hachyderm.io/@grynspan/112663373351028570)). This one isn't really a problem for me as my goal is to hasten the removal of XCTest from my codebase, not keep it on life support.
- Code generated by `@Test` by the Swift 6 compiler is not backwards compatible to 5.10 due to swift-syntax differences ([source](https://hachyderm.io/@grynspan/112663399612590974)).
- `@Test` functions on generic types are disallowed by Swift 6 ([source](https://hachyderm.io/@grynspan/112663427084355601)).

This list is non-exhaustive and I'll endeavour to keep it up to date if I learn of any more differences.

## License 

This example oroject is available under the MIT license. See the [LICENSE](https://github.com/unsignedapps/Vexil/blob/main/LICENSE) file for more info.