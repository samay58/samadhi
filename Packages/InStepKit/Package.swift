// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "InStepKit",
    platforms: [.iOS(.v26), .macOS(.v15)],
    products: [
        .library(name: "InStepDomain", targets: ["InStepDomain"]),
        .library(name: "InStepMotion", targets: ["InStepMotion"]),
        .library(name: "InStepAudio", targets: ["InStepAudio"]),
        .library(name: "InStepDesign", targets: ["InStepDesign"]),
        .library(name: "InStepDiagnostics", targets: ["InStepDiagnostics"]),
    ],
    targets: [
        .target(name: "InStepDomain"),
        .target(name: "InStepMotion", dependencies: ["InStepDomain"]),
        .target(name: "InStepAudio", dependencies: ["InStepDomain"]),
        .target(name: "InStepDesign", dependencies: ["InStepDomain", "InStepAudio"]),
        .target(name: "InStepDiagnostics", dependencies: ["InStepDomain"]),
        .testTarget(name: "InStepDomainTests", dependencies: ["InStepDomain"]),
    ]
)

