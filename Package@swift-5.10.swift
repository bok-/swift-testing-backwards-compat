// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-testing-backwards-compat",
    products: [
        .library(name: "Example", targets: ["Example"]),
    ],
    dependencies: [
        // Normal package dependencies
        .package(url: "https://github.com/apple/swift-testing.git", exact: "0.7.0"),
    ],
    targets: [
        .target(name: "Example"),
        .testTarget(
            name: "ExampleTests",
            dependencies: [
                .target(name: "Example"),
                .product(name: "Testing", package: "swift-testing"),
            ],
            cxxSettings: .packageSettings,
            swiftSettings: .packageSettings
        ),
    ]
)

extension Array where Element == PackageDescription.SwiftSetting {
  /// Settings intended to be applied to every Swift target in this package.
  /// Analogous to project-level build settings in an Xcode project.
  static var packageSettings: Self {
    availabilityMacroSettings + [
      .enableExperimentalFeature("StrictConcurrency"),
      .enableUpcomingFeature("ExistentialAny"),

      .enableExperimentalFeature("AccessLevelOnImport"),
      .enableUpcomingFeature("InternalImportsByDefault"),

      .define("SWT_TARGET_OS_APPLE", .when(platforms: [.macOS, .iOS, .macCatalyst, .watchOS, .tvOS, .visionOS])),

      .define("SWT_NO_FILE_IO", .when(platforms: [.wasi])),
    ]
  }

  /// Settings which define commonly-used OS availability macros.
  ///
  /// These leverage a pseudo-experimental feature in the Swift compiler for
  /// setting availability definitions, which was added in
  /// [apple/swift#65218](https://github.com/apple/swift/pull/65218).
  private static var availabilityMacroSettings: Self {
    [
      .enableExperimentalFeature("AvailabilityMacro=_mangledTypeNameAPI:macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0"),
      .enableExperimentalFeature("AvailabilityMacro=_backtraceAsyncAPI:macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0"),
      .enableExperimentalFeature("AvailabilityMacro=_clockAPI:macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0"),
      .enableExperimentalFeature("AvailabilityMacro=_regexAPI:macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0"),
      .enableExperimentalFeature("AvailabilityMacro=_swiftVersionAPI:macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0"),

      .enableExperimentalFeature("AvailabilityMacro=_distantFuture:macOS 99.0, iOS 99.0, watchOS 99.0, tvOS 99.0"),
    ]
  }
}

extension Array where Element == PackageDescription.CXXSetting {
  /// Settings intended to be applied to every C++ target in this package.
  /// Analogous to project-level build settings in an Xcode project.
  static var packageSettings: Self {
    [
      .define("_SWT_TESTING_LIBRARY_VERSION", to: #""unknown (Swift 5.10 toolchain)""#),
    ]
  }
}
