//
//  SpawnConfig.swift
//  RuProcess
//
//  Created by omochimetaru on 2017/03/31.
//
//

import RuFd

public struct SpawnConfig {
    public enum FileAction {
        case close
        case connect(to: FileDescriptor)
        case open(path: String, flag: OpenFlag, mode: OpenMode)
    }
    
    public init() {}
    
    public var fileActions: [FileDescriptor: FileAction] = [:]
}
