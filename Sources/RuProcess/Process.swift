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
    public struct StatusError : Error, CustomStringConvertible {
        public init(status: Status) {
            self.status = status
        }

        public let status: Status

        public var description: String {
            return "Process.StatusError(\(status))"
        }
    }

    public struct Status : CustomStringConvertible {
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

        public var stopped: Bool {
            return _stopped && _stopSignal != 0x13
        }
        public var stopSignal: Int32? {
            return stopped ? _stopSignal : nil
        }

        public var continued: Bool {
            return _stopped && _stopSignal == 0x13
        }

        public func shouldSuccess() throws {
            if exitStatus == .some(0) {
                return
            }
            throw StatusError(status: self)
        }

        public var description: String {
            if exited {
                return "Status(exited: \(exitStatus!)"
            }
            if signaled {
                return "Status(signaled: \(terminateSignal!), coredump=\(coredump))"
            }
            if stopped {
                return "Status(stopped: \(stopSignal!))"
            }
            if continued {
                return "Status(continued)"
            }
            return "Status(unknown: \(_value))"
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
        let options: Int32 = WNOHANG | WUNTRACED
        let ret = Darwin.waitpid(id, &status, options)
        if ret == -1 {
            throw PosixError(code: errno)
        }
        return Status(value: status)
    }

    public static func exec(command: [String]) throws -> Status {
        let spawner = ProcessSpawner(command: command)
        let proc = try spawner.spawn()
        return try proc.wait()
    }

    public static func capture(command: [String]) throws -> [UInt8] {
        let spawner = ProcessSpawner(command: command)
        let pipe = try Pipe.create()
        spawner.fileActions.append(.connect(pipe.writer, to: .stdout))
        let proc = try spawner.spawn()
        let data: [UInt8] = try pipe.reader.read()
        try proc.wait().shouldSuccess()
        return data
    }
}


