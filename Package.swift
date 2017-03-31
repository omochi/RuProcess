// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "RuProcess",
    targets: [
        Target(name: "RuProcess"),
        Target(name: "MetaTest_exec_pwd",
               dependencies: [ "RuProcess" ]),
        Target(name: "MetaTest_capture_ls",
               dependencies: [ "RuProcess" ])
    ],
    dependencies: [
        .Package(url: "https://github.com/omochi/RuPosixError.git",
                 majorVersion: 0),
        .Package(url: "https://github.com/omochi/RuHeapBuffer.git",
                 majorVersion: 0),
        .Package(url: "https://github.com/omochi/RuString.git",
                 majorVersion: 0),
        .Package(url: "https://github.com/omochi/RuFd.git",
                 majorVersion: 0)
    ]

)
