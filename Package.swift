// swift-tools-version:5.1
import PackageDescription



var platformDependentTargets = [PackageDescription.Target]()
var platformDependentProducts = [PackageDescription.Product]()
var platformDependentOfficeKitDependencies = [Target.Dependency]()
var platformDependentOfficectlDependencies = [Target.Dependency]()

#if canImport(DirectoryService) && canImport(OpenDirectory)
platformDependentTargets.append(.target(name: "officectl_odproxy", dependencies: ["OfficeKit", "Vapor", "Yaml", "JWTKit", "LegibleError", "GenericJSON"]))
platformDependentProducts.append(.executable(name: "officectl_odproxy", targets: ["officectl_odproxy"]))
#endif

#if !canImport(Darwin)
platformDependentTargets.append(.systemLibrary(name: "CNCurses", pkgConfig: "ncurses", providers: [.apt(["libncurses-dev"]), .brew(["ncurses"])]))
platformDependentOfficectlDependencies.append("CNCurses")
#endif

#if !canImport(Security)
/* See the Crypto.swift for this */
platformDependentOfficeKitDependencies.append("JWTKit")
#endif


/* We try and use OpenLDAP from Homebrew instead of the system one if possible
 * (the system one is deprecated, but there are no alternatives; OpenDirectory
 * simply does not do what OpenLDAP does).
 * Note the project compiles if the system OpenLDAP is used, but you’ll get a
 * lot of useless warnings. */


let package = Package(
	name: "officectl",
	platforms: [
		.macOS(.v10_15)
	],
	products: [
		.library(name: "OfficeKit", targets: ["OfficeKit"]),
		.executable(name: "officectl", targets: ["officectl"])
	] + platformDependentProducts,
	dependencies: [
		.package(url: "https://github.com/happn-tech/URLRequestOperation.git", from: "1.1.7"),
		.package(url: "https://github.com/happn-tech/RetryingOperation.git", from: "1.1.4"),
		.package(url: "https://github.com/happn-tech/SemiSingleton.git", from: "2.0.0"),
		.package(url: "https://github.com/apple/swift-nio.git", from: "2.6.0"),
		.package(url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
		.package(url: "https://github.com/klaas/Guaka.git", .upToNextMinor(from: "0.3.0")),
		.package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-beta"),
		.package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-beta"),
		.package(url: "https://github.com/vapor/open-crypto.git", from: "4.0.0-beta"),
//		.package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
		.package(url: "https://github.com/behrang/YamlSwift.git", from: "3.0.0"),
		.package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0-beta"),
		.package(url: "https://github.com/vapor/console-kit.git", from: "4.0.0-beta"),
		.package(url: "https://github.com/happn-tech/EmailValidator.git", .branch("master")),
		.package(url: "https://github.com/zoul/generic-json-swift.git", from: "1.2.0"),
		.package(url: "https://github.com/mxcl/LegibleError.git", from: "1.0.0")
	],
	targets: [
		.systemLibrary(name: "COpenLDAP", providers: [.apt(["libldap2-dev"]), .brew(["openldap"])]),
		.systemLibrary(name: "COpenSSL", pkgConfig: "openssl", providers: [.apt(["openssl", "libssl-dev"]), .brew(["openssl@1.1"])]),
		
		.target(name: "GenericStorage", dependencies: []),
		
		.target(name: "ServiceKit", dependencies: []),
		
		.target(
			name: "OfficeKit",
			dependencies: [
				/* Dependencies in the project */
				"COpenLDAP", "GenericStorage", "ServiceKit",
				/* happn dependencies */
				"RetryingOperation", "URLRequestOperation", "SemiSingleton", "EmailValidator",
				/* External dependencies */
				"NIO", "Logging", "OpenCrypto", "GenericJSON", "Yaml"
			] + platformDependentOfficeKitDependencies
		),
		.testTarget(name: "OfficeKitTests", dependencies: ["OfficeKit"]),
		
		.target(
			name: "officectl",
			dependencies:
				["OfficeKit", "COpenSSL", "Vapor", "Leaf", "OpenCrypto", "ConsoleKit", "Guaka", "Yaml", "JWTKit", "LegibleError"] +
				platformDependentOfficectlDependencies,
			linkerSettings: [.linkedLibrary("ncurses", .when(platforms: [.macOS]))]
		)
		
	] + platformDependentTargets
)
