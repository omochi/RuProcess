//
//  ProcessSpawner.swift
//  RuProcess
//
//  Created by omochimetaru on 2017/03/31.
//
//

import Darwin
import RuHeapBuffer
import RuPosixError
import RuFd

public class ProcessSpawner {
    public enum FileAction {
        case close(FileDescriptor)
        case connect(FileDescriptor, to: FileDescriptor)
        case open(FileDescriptor, path: String, flag: OpenFlag, mode: OpenMode)
    }

    public init(command: [String]) {
        self.command = command
    }

    public var command: [String]
    public var fileActions: [FileAction] = []

    public func spawn() throws -> Process {
        var pid: pid_t = 0

        let commandCStr = command.map { HeapCString(string: $0) }

        var args: [UnsafeMutablePointer<CChar>?] = []
        args.append(contentsOf: commandCStr.map { $0.pointer })
        args.append(nil)

        var actions: posix_spawn_file_actions_t?
        var ret = posix_spawn_file_actions_init(&actions)
        guard ret == 0 else {
            throw PosixError(code: ret)
        }
        defer {
            let ret = posix_spawn_file_actions_destroy(&actions)
            precondition(ret == 0, PosixError(code: ret).description)
        }

        for action in fileActions {
            switch action {
            case let .close(fd):
                let ret = posix_spawn_file_actions_addclose(&actions, fd.fd)
                guard ret == 0 else {
                    throw PosixError(code: ret)
                }
            case let .open(fd, path, flag, mode):
                let ret = posix_spawn_file_actions_addopen(
                    &actions, fd.fd,
                    path, flag.rawValue, mode.rawValue)
                guard ret == 0 else {
                    throw PosixError(code: ret)
                }
            case let .connect(fd, to):
                let ret = posix_spawn_file_actions_adddup2(&actions, fd.fd, to.fd)
                guard ret == 0 else {
                    throw PosixError(code: ret)
                }
            }
        }

        ret = posix_spawnp(&pid,
                           args[0],
                           &actions,
                           nil,
                           &args,
                           nil)
        guard ret == 0 else {
            throw PosixError(code: ret)
        }

        return Process(id: pid)
    }
}
