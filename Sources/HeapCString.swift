//
//  CStringBuffer.swift
//  RuProcess
//
//  Created by omochimetaru on 2017/03/31.
//
//

class HeapCString {
    init(string: String) {
        var str = string.utf8CString
        
        var pointer: UnsafeMutablePointer<CChar>!
        var size: Int = 0
        str.withUnsafeMutableBufferPointer {
            size = $0.count
            pointer = UnsafeMutablePointer<CChar>.allocate(capacity: size)
            pointer.initialize(from: $0.baseAddress!, count: size)
        }
        
        self.pointer = pointer
        self.size = size
    }
    
    deinit {
        pointer.deallocate(capacity: size)
    }
    
    let pointer: UnsafeMutablePointer<CChar>
    let size: Int
}
