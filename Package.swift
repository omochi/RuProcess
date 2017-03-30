// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "RuProcess",
    dependencies: [
        .Package(url: "https://github.com/omochi/RuPosixError.git",
                 versions: "0.1.0" ..< "1.0.0")
    ]
)
