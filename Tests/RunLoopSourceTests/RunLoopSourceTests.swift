//
//  RunLoopSourceTest.swift
//
//  Created by yoshi-kou on 2017/11/15.
//  Copyright © 2017 ysn551. All rights reserved.
//

import XCTest
@testable import RunLoopSource

class RunLoopSourceTests: XCTestCase {

    static var allTests = [
        ("testCreateRunLoopSource", testCreateRunLoopSource),
        ("testInvalidRunLoopSource", testInvalidRunLoopSource), //releasememory
        ("testAddRunLoop", testAddRunLoop),
        ("testRemoveRunLoop", testRemoveRunLoop)
    ]


    class TestInfo {}

    func testCreateRunLoopSource() {
        let info = TestInfo()
        let runLoopSource1 = RunLoopSource(info: info)
        XCTAssertNotNil(runLoopSource1)

        let runLoopSource2 = RunLoopSource(info: info, schedule: nil, perform: nil, cancel: nil)
        XCTAssertNotNil(runLoopSource2)

    }

    // Release RunLoopSource instance test by invalidate()
    func testInvalidRunLoopSource() {
        let info = TestInfo()
        weak var runLoopSource: RunLoopSource? = nil
        do {
            runLoopSource = RunLoopSource(info: info)
            runLoopSource?.invalidate()
        }
        XCTAssertNil(runLoopSource)
    }

    func testAddRunLoop() {
        let info = TestInfo()
        let runLoopSource = RunLoopSource(info: info)

        let runLoop = RunLoop.current
        runLoop.add(runLoopSource, forMode: .defaultRunLoopMode)

        XCTAssertTrue(CFRunLoopContainsSource(runLoop.getCFRunLoop(), runLoopSource.getCFRunLoopSource(), CFRunLoopMode.defaultMode))

    }

     func testRemoveRunLoop() {
        let info = TestInfo()
        let runLoopSource = RunLoopSource(info: info)
        
        let runLoop = RunLoop.current
        runLoop.add(runLoopSource, forMode: .defaultRunLoopMode)
        do {
        }
        runLoop.remove(runLoopSource, forMode: .defaultRunLoopMode)
        XCTAssertNil(runLoopSource.getCFRunLoopSource())
    }

}
