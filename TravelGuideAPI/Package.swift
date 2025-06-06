// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TravelGuideAPI",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // 💧 Vapor Web Framework
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
        // 🗄 Fluent ORM
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🐘 PostgreSQL Driver
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        // 🔐 JWT
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
        // ⚙️ NIO
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor") // ✅ XCTVapor está dentro de Vapor
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }

/*
// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TravelGuideAPI",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // JWT
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
        // DotEnv
        //.package(url: "https://github.com/swift-server/swift-dotenv.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "JWT", package: "jwt"),
                //.product(name: "DotEnv", package: "swift-dotenv")
            ],
            swiftSettings: swiftSettings
        ),
         .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
*/
