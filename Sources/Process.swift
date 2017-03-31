//
//  Process.swift
//  RuProcess
//
//  Created by omochimetaru on 2017/03/30.
//
//

import Darwin
import RuPosixError
import RuHeapBuffer
import RuFd

public class Process {
    public struct Status {
        public init(value: Int32) {
            self._value = value
        }

        public var exited: Bool {
            return _status == 0
        }
        public var exitStatus: Int32? {
            return exited ? (_value >> 8) & 0x000000ff : nil
        }

        public var signaled: Bool {
            return !_stopped && !exited
        }
        public var terminateSignal: Int32? {
            return signaled ? _status : nil
        }
        public var coredump: Bool {
            return signaled ? (_value & 0o200) != 0 : false
        }

        public var continued: Bool {
            return _stopped && _stopSignal == 0x13
        }

        public var stopped: Bool {
            return _stopped && _stopSignal != 0x13
        }
        public var stopSignal: Int32? {
            return stopped ? _stopSignal : nil
        }

        private var _status: Int32 {
            return _value & 0o177
        }
        private var _stopped: Bool {
            return _status == 0o177
        }
        private var _stopSignal: Int32 {
            return _value >> 8
        }

        private var _value: Int32
    }

    public init(id: pid_t) {
        self.id = id
    }
    
    public let id: pid_t

    public func wait() throws -> Status {
        var status: Int32 = 0
        let ret = Darwin.waitpid(id, &status, 0)
        if ret == -1 {
            throw PosixError(code: errno)
        }
        return Status(value: status)
    }

    public static func spawn(command: [String],
                             config: SpawnConfig = SpawnConfig())
        throws -> Process
    {
        var pid: pid_t = 0

        let commandCStr = command.map { HeapCString(string: $0) }
        
        var args: [UnsafeMutablePointer<CChar>?] = []
        args.append(contentsOf: commandCStr.map { $0.baseAddress })
        args.append(nil)
        
        var fileActions: posix_spawn_file_actions_t?
        var ret = posix_spawn_file_actions_init(&fileActions)
        guard ret == 0 else {
            throw PosixError(code: ret)
        }
        defer {
            let ret = posix_spawn_file_actions_destroy(&fileActions)
            precondition(ret == 0, PosixError(code: ret).description)
        }

        for (fd, action) in config.fileActions {
            switch action {
            case .close:
                let ret = posix_spawn_file_actions_addclose(&fileActions, fd.fd)
                guard ret == 0 else {
                    throw PosixError(code: ret)
                }
            case let .open(path, flag, mode):
                let ret = posix_spawn_file_actions_addopen(
                    &fileActions, fd.fd,
                    path, flag.rawValue, mode.rawValue)
                guard ret == 0 else {
                    throw PosixError(code: ret)
                }
            case let .connect(to):
                let ret = posix_spawn_file_actions_adddup2(&fileActions, fd.fd, to.fd)
                guard ret == 0 else {
                    throw PosixError(code: ret)
                }
            }
        }

        ret = posix_spawnp(&pid,
                           args[0],
                           &fileActions,
                           nil,
                           &args,
                           nil)
        guard ret == 0 else {
            throw PosixError(code: ret)
        }
        
        return Process(id: pid)
    }

    public static func exec(command: [String]) throws -> Status {
        let proc = try spawn(command: command, config: SpawnConfig())
        return try proc.wait()
    }
}
