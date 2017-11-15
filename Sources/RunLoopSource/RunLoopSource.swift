//
//  RunLoopSource.swift
//
//  Created by yoshi-kou on 2017/11/15.
//  Copyright © 2017 ysn551. All rights reserved.
//

import Foundation

public class RunLoopSource {
    public typealias Info = AnyObject
    
    var info: Info!
    public var schedule: ((Info) -> ())?
    public var perform:  ((Info) -> ())?
    public var cancel:   ((Info) -> ())?
    
    fileprivate var cfsource: CFRunLoopSource! = nil
    
    /**
     Creates a new RunLoopSource.

     - parameters:
     時に渡されるインスタンス
       - info: the instance passed on call handle methods, schedule and peform, cancel.
       - schedule: the callback function called when the creating RunloopSource instance was added to the runLoop.
       - perform: the callback function called when this instance of signal occurs
       - cancel: the callback function called when this instance was removed or invalidated.
     */
    public init(info: Info, schedule: ((Info) -> ())? = nil, perform: ((Info) -> ())? = nil, cancel: ((Info) -> ())? = nil) {
        self.info    = info
        self.schedule = schedule
        self.perform  = perform
        self.cancel   = cancel
        self.cfsource = self.makeRunLoopSouce()
    }
    
    public var isInvalidat: Bool {
        guard self.cfsource != nil else { return true }
        return CFRunLoopSourceIsValid(self.cfsource)
    }
    
    public func invalidate() {
        guard self.cfsource != nil else { return }
        CFRunLoopSourceInvalidate(self.cfsource)
        self.release()
    }
    

    /**
     Calls the perform methods on the thread of the registed runloop.
     */
    public func signal() {
        CFRunLoopSourceSignal(self.cfsource)
    }
    

    func getCFRunLoopSource() -> CFRunLoopSource? {
        guard self.cfsource != nil else { return nil }
        return self.cfsource
    }
    
    
    private func makeRunLoopSouce() -> CFRunLoopSource {
        var context = CFRunLoopSourceContext()
        context.version = 0
        
        context.info = UnsafeMutableRawPointer.allocate(bytes: MemoryLayout<RunLoopSource>.size, alignedTo: MemoryLayout<RunLoopSource>.alignment)
        
        // retains self
        context.info.initializeMemory(as: RunLoopSource.self, to: self)
        
        // A scheduling callback for the run loop source. This callback is called when the source is added to a run loop mode. Can be NULL.
        context.schedule = RunLoopSourceScheduleRoutine
        
        // A perform callback for the run loop source. This callback is called when the source has fired.
        context.perform = RunLoopSourcePerformRoutine
        
        // A cancel callback for the run loop source. This callback is called when the source is removed from a run loop mode. Can be NULL.
        context.cancel = RunLoopSourceCancelRoutine
        
        return CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context)
    }
    
    fileprivate func release() {
        guard self.cfsource != nil else { return }
        defer {
            self.cfsource = nil
            self.info     = nil
        }
        
        var sourceContext = CFRunLoopSourceContext()
        CFRunLoopSourceGetContext(self.cfsource, &sourceContext)
        
        let opaquePointer = OpaquePointer(sourceContext.info)
        let unsafePointer = UnsafeMutablePointer<RunLoopSource>(opaquePointer)
        unsafePointer?.deinitialize(count: 1)
        unsafePointer?.deallocate(capacity: 1)
    }
}


// MARK: - CFRunLoopSource Routines

// Called on the same thread as the added RunLoop When RunLoopSource was added
private func RunLoopSourceScheduleRoutine(_ info: UnsafeMutableRawPointer?, _ runLoop: CFRunLoop?, _runLoopMode: CFRunLoopMode?) {
    guard let info = info else { return }
    let runLoopSource = info.load(as: RunLoopSource.self)
    runLoopSource.schedule?(runLoopSource.info)
}

// Called on the same thread as the added RunLoop When signal occurred
private func RunLoopSourcePerformRoutine(info: UnsafeMutableRawPointer?) -> Void {
    guard let info = info else { return }
    let runLoopSource = info.load(as: RunLoopSource.self)
    runLoopSource.perform?(runLoopSource.info)
}

// Called upon removed RunLoopSource on the same thread.
private func RunLoopSourceCancelRoutine(_ info: UnsafeMutableRawPointer?, _ runLoop: CFRunLoop?, runLoopMode: CFRunLoopMode?) {
    guard let info = info else { return }
    let runLoopSource = info.load(as: RunLoopSource.self)
    runLoopSource.cancel?(runLoopSource.info)
    runLoopSource.release()
}
