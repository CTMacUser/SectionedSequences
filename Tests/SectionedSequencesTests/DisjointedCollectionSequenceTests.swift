/*

  DisjointedCollectionSequenceTests.swift
  SectionedSequencesTests

  Created by Daryle Walker on 1/2/18.
  Copyright (c) 2018 Daryle Walker.
  Distributed under the MIT License.

 */

import XCTest
@testable import SectionedSequences


class DisjointedCollectionSequenceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // Test the iterator's initializer.
    func testIteratorInitialState() {
        let a = 1...5
        let i = DisjointedCollectionIterator(a, span: 2)
        XCTAssertEqual(i.base, a)
        XCTAssertEqual(i.span, 2)
        XCTAssertEqual(i.start, a.startIndex)
    }

    // Test the iterator on an empty collection.
    func testIteratorEmptyCollection() {
        var i = DisjointedCollectionIterator(EmptyCollection<String>(), span: 2)
        XCTAssertNil(i.next())
    }

    // Test the iterator on a collection whose length is an exact multiple of the span.
    func testIteratorFittedCollection() {
        let a = 1...6
        var i = DisjointedCollectionIterator(a, span: 3)
        XCTAssertTrue(i.next()?.elementsEqual(1...3) ?? false)
        XCTAssertTrue(i.next()?.elementsEqual(4...6) ?? false)
        XCTAssertNil(i.next())
    }

    // Test the iterator on a collection whose length isn't divisible by the span.
    func testIteratorUnfittingCollection() {
        let a = 1...8
        var i = DisjointedCollectionIterator(a, span: 3)
        XCTAssertTrue(i.next()?.elementsEqual(1...3) ?? false)
        XCTAssertTrue(i.next()?.elementsEqual(4...6) ?? false)
        XCTAssertTrue(i.next()?.elementsEqual(7...8) ?? false)
        XCTAssertNil(i.next())
    }

    // Test the sequence's initializer.
    func testSequenceInitialState() {
        let a = 1...5
        let s = DisjointedCollectionSequence(a, span: 2)
        XCTAssertEqual(s.base, a)
        XCTAssertEqual(s.span, 2)
    }

    // Test using the sequence for its purpose.
    func testSequencing() {
        let a = 1...5
        let s = DisjointedCollectionSequence(a, span: 2)
        let b = Array(s)
        XCTAssertEqual(b.count, 3)
        XCTAssertTrue(b[0].elementsEqual([1, 2]))
        XCTAssertTrue(b[1].elementsEqual([3, 4]))
        XCTAssertTrue(b[2].elementsEqual([5]))
    }

    // Test getting a sequence's underestimate of the wrapped count.
    func testSequenceCount() {
        // Empty, sub-random-access collection
        var d = [Int: String]()
        let s1 = DisjointedCollectionSequence(d, span: 2)
        XCTAssertEqual(s1.underestimatedCount, 0)

        // Non-empty, sub-random-access collection
        d = [1: "1", 2: "two", 3: "tres"]
        let s2 = DisjointedCollectionSequence(d, span: 2)
        XCTAssertEqual(s2.underestimatedCount, 1)  // not 2

        // Empty, random-access collection
        var a = [Int]()
        let s3 = DisjointedCollectionSequence(a, span: 2)
        XCTAssertEqual(s3.underestimatedCount, 0)

        // Non-empty, random-access collection
        a = [1, 2, 3, 4, 5]
        let s4 = DisjointedCollectionSequence(a, span: 2)
        XCTAssertEqual(s4.underestimatedCount, 3)
    }

    // Test getting the sub-collection sequence from the collection
    func testCollectionDisjointed() {
        let d = [1: "1", 2: "two", 3: "tres"]
        let disjointedD = Array(d.disjoint(eachSpanning: 2))
        XCTAssertEqual(disjointedD.count, 2)
        XCTAssertEqual(disjointedD.first?.count, 2)
        XCTAssertEqual(disjointedD.last?.count, 1)

        let a = 1...5
        let disjointedA = Array(a.disjoint(eachSpanning: 2))
        XCTAssertEqual(disjointedA.count, 3)
        XCTAssertTrue(disjointedA[0].elementsEqual([1, 2]))
        XCTAssertTrue(disjointedA[1].elementsEqual([3, 4]))
        XCTAssertTrue(disjointedA[2].elementsEqual([5]))
    }

    // List of tests for Linux.
    static var allTests = [
        ("testIteratorInitialState", testIteratorInitialState),
        ("testIteratorEmptyCollection", testIteratorEmptyCollection),
        ("testIteratorFittedCollection", testIteratorFittedCollection),
        ("testIteratorUnfittingCollection", testIteratorUnfittingCollection),

        ("testSequenceInitialState", testSequenceInitialState),
        ("testSequencing", testSequencing),
        ("testSequenceCount", testSequenceCount),

        ("testCollectionDisjointed", testCollectionDisjointed),
    ]

}
