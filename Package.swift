// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "RuProcess",
    dependencies: [
        .Package(url: "https://github.com/omochi/RuPosixError.git",
                 majorVersion: 0),
        .Package(url: "https://github.com/omochi/RuHeapBuffer.git",
                 majorVersion: 0),
        .Package(url: "https://github.com/omochi/RuFd.git",
                 majorVersion: 0)
    ]
)
