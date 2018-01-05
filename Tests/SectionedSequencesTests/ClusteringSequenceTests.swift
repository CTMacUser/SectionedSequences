/*

  ClusteringSequenceTests.swift
  SectionedSequencesTests

  Created by Daryle Walker on 1/1/18.
  Copyright (c) 2018 Daryle Walker.
  Distributed under the MIT License.

 */

import XCTest
@testable import SectionedSequences


class ClusteringSequenceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // Test the iterator initializer.
    func testIteratorInitializer() {
        let a = 1...5
        let i = ClusteringIterator(a.makeIterator(), span: 2)
        XCTAssertEqual(Array(IteratorSequence(i.base)), Array(IteratorSequence(a.makeIterator())))
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

    // Test the sequence's initializer.
    func testSequenceInitializer() {
        let a = 1...5
        let s = ClusteringSequence(a, span: 2)
        XCTAssertEqual(s.base, a)
        XCTAssertEqual(s.span, 2)
    }

    // Test using the sequence for its purpose.
    func testSequencing() {
        let a = 1...5
        let s = ClusteringSequence(a, span: 2)
        let b = Array(s)
        XCTAssertTrue(b.elementsEqual([[1, 2], [3, 4], [5]], by: ==))
    }

    // Test getting a sequence's underestimate of the wrapped count.
    func testSequenceCount() {
        // Empty, non-random-access-collection
        var d = [Int: String]()
        let s1 = ClusteringSequence(d, span: 2)
        XCTAssertEqual(s1.underestimatedCount, 0)

        // Non-empty, non-random-access-collection
        d = [1: "1", 2: "two", 3: "tres"]
        let s2 = ClusteringSequence(d, span: 2)
        XCTAssertLessThanOrEqual(s2.underestimatedCount, 2)

        // Empty, random-access collection
        var a = [Int]()
        let s3 = ClusteringSequence(a, span: 2)
        XCTAssertEqual(s3.underestimatedCount, 0)

        // Non-empty, random-access collection
        a = [1, 2, 3, 4, 5]
        let s4 = ClusteringSequence(a, span: 2)
        XCTAssertEqual(s4.underestimatedCount, 3)
    }

    // Test getting the sequence's collection sequence
    func testSequenceClustered() {
        let d = [1: "1", 2: "two", 3: "tres"]
        let clusteredD = Array(d.lazy.clustered(eachSpanning: 2))
        XCTAssertEqual(clusteredD.map { $0.count }, [2, 1])

        let a = 1...5
        let clusteredA = Array(a.lazy.clustered(eachSpanning: 2))
        XCTAssertTrue(clusteredA.elementsEqual([[1, 2], [3, 4], [5]], by: ==))
    }

    // List of tests for Linux.
    static var allTests = [
        ("testIteratorInitializer", testIteratorInitializer),
        ("testEmptyIterator", testEmptyIterator),
        ("testInexactIteration", testInexactIteration),
        ("testFittedIteration", testFittedIteration),

        ("testSequenceInitializer", testSequenceInitializer),
        ("testSequencing", testSequencing),
        ("testSequenceCount", testSequenceCount),

        ("testSequenceClustered", testSequenceClustered),
    ]

}
