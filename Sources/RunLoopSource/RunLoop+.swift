//
//  RunLoop+.swift
//
//  Created by yoshi-kou on 2017/11/15.
//  Copyright © 2017 ysn551. All rights reserved.
//

import Foundation

public extension RunLoop {
    public func add(_ source: RunLoopSource, forMode mode: RunLoopMode) {
        let cfRunLoop = self.getCFRunLoop()
        let cfSource  = source.getCFRunLoopSource()
        let cfMode    = CFRunLoopMode(mode.rawValue as CFString)
        CFRunLoopAddSource(cfRunLoop, cfSource, cfMode)
    }
    
    public func remove(_ source: RunLoopSource, forMode mode: RunLoopMode) {
        let cfRunLoop = self.getCFRunLoop()
        let cfSource  = source.getCFRunLoopSource()
        let cfMode    = CFRunLoopMode(mode.rawValue as CFString)
        CFRunLoopRemoveSource(cfRunLoop, cfSource, cfMode)
    }
    
}
