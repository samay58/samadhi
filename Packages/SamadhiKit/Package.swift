// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SamadhiKit",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "SamadhiDomain", targets: ["SamadhiDomain"]),
        .library(name: "SamadhiMotion", targets: ["SamadhiMotion"]),
        .library(name: "SamadhiAudio", targets: ["SamadhiAudio"]),
        .library(name: "SamadhiDesign", targets: ["SamadhiDesign"]),
    ],
    targets: [
        .target(name: "SamadhiDomain"),
        .target(name: "SamadhiMotion", dependencies: ["SamadhiDomain"]),
        .target(name: "SamadhiAudio", dependencies: ["SamadhiDomain"]),
        .target(name: "SamadhiDesign", dependencies: ["SamadhiDomain", "SamadhiAudio"]),
        .executableTarget(
            name: "TempoCorpusValidator",
            dependencies: ["SamadhiAudio", "SamadhiDomain"],
            path: "Tools/TempoCorpusValidator",
            resources: [.process("Corpus.json")]
        ),
        .testTarget(name: "SamadhiDomainTests", dependencies: ["SamadhiDomain"]),
        .testTarget(name: "SamadhiAudioTests", dependencies: ["SamadhiAudio", "SamadhiDomain"]),
        .testTarget(name: "SamadhiMotionTests", dependencies: ["SamadhiMotion"]),
    ]
)
