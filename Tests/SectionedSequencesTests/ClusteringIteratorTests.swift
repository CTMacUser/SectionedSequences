/*

  ClusteringIteratorTests.swift
  SectionedSequencesTests

  Created by Daryle Walker on 1/1/18.
  Copyright (c) 2018 Daryle Walker.
  Distributed under the MIT License.

 */

import XCTest
@testable import SectionedSequences


class ClusteringIteratorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // Test the default initializer.
    func testInitialState() {
        let a = 1...5
        let i = ClusteringIterator(a.makeIterator(), span: 2)
        XCTAssertEqual(Array(IteratorSequence(i.elements)), Array(IteratorSequence(a.makeIterator())))
        XCTAssertEqual(i.span, 2)
    }

    // Test empty source iterator.
    func testEmptyIterator() {
        let e = EmptyCollection<String>()
        let i = ClusteringIterator(e.makeIterator(), span: 3)
        XCTAssertTrue(Array(IteratorSequence(i)).isEmpty)
    }

    // Test when the span doesn't fit evenly with the inner iterator's element count.
    func testInexactIteration() {
        let a = 1...5
        let i = ClusteringIterator(a.makeIterator(), span: 2)
        let sectionedA = Array(IteratorSequence(i))
        XCTAssertEqual(sectionedA.count, 3)  // Assertion function can't work with arrays of arrays.
        XCTAssertEqual(sectionedA[0], [1, 2])
        XCTAssertEqual(sectionedA[1], [3, 4])
        XCTAssertEqual(sectionedA[2], [5])
    }

    // Test when the span evenly fits with the inner iterator's element count.
    func testFittedIteration() {
        let a = 1...20
        let i = ClusteringIterator(a.makeIterator(), span: 5)
        let sectionedA = Array(IteratorSequence(i))
        XCTAssertEqual(sectionedA.count, 4)
        XCTAssertEqual(sectionedA[0], [1, 2, 3, 4, 5])
        XCTAssertEqual(sectionedA[1], [6, 7, 8, 9, 10])
        XCTAssertEqual(sectionedA[2], [11, 12, 13, 14, 15])
        XCTAssertEqual(sectionedA[3], [16, 17, 18, 19, 20])
    }

    // List of tests for Linux.
    static var allTests = [
        ("testInitialState", testInitialState),
        ("testEmptyIterator", testEmptyIterator),
        ("testInexactIteration", testInexactIteration),
        ("testFittedIteration", testFittedIteration),
    ]

}
