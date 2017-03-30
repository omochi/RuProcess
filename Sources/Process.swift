//
//  Process.swift
//  RuProcess
//
//  Created by omochimetaru on 2017/03/30.
//
//

import Darwin
import RuPosixError

public class Process {
    public init(id: pid_t) {
        self.id = id
    }
    
    public let id: pid_t

    public static func spawn(command: [String]) throws -> Process {
        var pid: pid_t = 0

        let commandCStr = command.map { HeapCString(string: $0) }
        
        var args: [UnsafeMutablePointer<CChar>?] = []
        args.append(contentsOf: commandCStr.map { $0.pointer })
        args.append(nil)

        let ret = posix_spawnp(&pid,
                               args[0],
                               nil,
                               nil,
                               &args,
                               nil)
        if ret != 0 {
            throw PosixError(code: ret)
        }
        
        return Process(id: pid)
    }

    public static func exec(command: [String]) -> Int {
        return command.count
    }
}
