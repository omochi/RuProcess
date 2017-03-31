// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "RuProcessMetaTest",
    dependencies: [
        .Package(url: "../../RuProcess", majorVersion: 0),
        .Package(url: "https://github.com/omochi/RuString.git", majorVersion: 0)
    ]
)
