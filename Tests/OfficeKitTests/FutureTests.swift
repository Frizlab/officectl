/*
 * FutureTests.swift
 * OfficeKitTests
 *
 * Created by François Lamboley on 08/01/2019.
 */

import XCTest
@testable import OfficeKit

import Async
import NIO



class FutureTests : XCTestCase {
	
	let queue = DispatchQueue(label: "test queue")
	let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
	var eventLoop: EventLoop {
		return eventLoopGroup.next()
	}
	
	func testWaitAll1() throws {
		let f1 = futureSucceeding(in: .milliseconds(500), id: 1, eventLoop: eventLoop)
		let f2 = futureFailing(in: .milliseconds(250), eventLoop: eventLoop)
		let f3 = futureSucceeding(in: .milliseconds(750), id: 3, eventLoop: eventLoop)
		let r = try EventLoopFuture.waitAll([f1, f2, f3], eventLoop: eventLoop).wait()
		XCTAssertEqual(r.count, 3)
		XCTAssertEqual(r[0].result, 1)
		XCTAssertNotNil(r[1].error)
		XCTAssertEqual(r[2].result, 3)
	}
	
	private func futureSucceeding(in delay: DispatchTimeInterval, id: Int, eventLoop: EventLoop) -> EventLoopFuture<Int> {
		let promise = eventLoop.newPromise(Int.self)
		
		queue.asyncAfter(deadline: .now() + delay, execute: {
			promise.succeed(result: id)
		})
		
		return promise.futureResult
	}
	
	private func futureFailing(in delay: DispatchTimeInterval, eventLoop: EventLoop) -> EventLoopFuture<Int> {
		let promise = eventLoop.newPromise(Int.self)
		
		queue.asyncAfter(deadline: .now() + delay, execute: {
			promise.fail(error: InternalError())
		})
		
		return promise.futureResult
	}
	
}
