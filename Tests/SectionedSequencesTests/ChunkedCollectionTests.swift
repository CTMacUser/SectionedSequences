/*

  ChunkedCollectionTests.swift
  SectionedSequencesTests

  Created by Daryle Walker on 1/6/18.
  Copyright (c) 2018 Daryle Walker.
  Distributed under the MIT License.

 */

import XCTest
@testable import SectionedSequences


class ChunkedCollectionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // Test the full property initializer.
    func testPropertyInitializer() {
        let a = [1, 2, 3, 4, 5]
        let ca = ChunkedCollection(a, span: 2, targetStartIndex: a.index(after: a.startIndex), targetEndIndex: a.index(before: a.endIndex))
        XCTAssertEqual(a, ca.base)
        XCTAssertEqual(ca.span, 2)
        XCTAssertEqual(ca.target, ca.base.index(after: ca.base.startIndex) ..< ca.base.index(before: ca.base.endIndex))
    }

    // Test the regular container & span initializer.
    func testRegularInitializer() {
        let d = [1: "one", 2: "dos"]
        let cd = ChunkedCollection(d, span: 1)
        XCTAssertEqual(d, cd.base)
        XCTAssertEqual(cd.span, 1)
        XCTAssertEqual(cd.target, cd.base.startIndex ..< cd.base.endIndex)
    }

    // Test the type-exclusive properties.
    func testCoreProperties() {
        // Test the targeted wrapped sub-collection.
        let a = [1, 2, 3, 4, 5]
        let ca = ChunkedCollection(a, span: 2, targetStartIndex: a.index(after: a.startIndex), targetEndIndex: a.index(before: a.endIndex))
        XCTAssertEqual(Array(ca.wrappedElements), [2, 3, 4])
    }

    // Test iteration.
    func testIterator() {
        // Test an iteration run.
        let a = [1, 2, 3, 4, 5]
        let ca = ChunkedCollection(a, span: 2, targetStartIndex: a.index(after: a.startIndex), targetEndIndex: a.index(before: a.endIndex))
        XCTAssertTrue(Array(IteratorSequence(ca)).map { Array($0) }.elementsEqual([[2, 3], [4]], by: ==))

        // Test iteration steps.
        var ca2 = ChunkedCollection(a, span: 2)
        XCTAssertEqual(ca2.wrappedElements.count, 5)
        XCTAssertEqual(ca2.next().map { Array($0) }!, [1, 2])
        XCTAssertEqual(ca2.wrappedElements.count, 3)
        XCTAssertEqual(ca2.next().map { Array($0) }!, [3, 4])
        XCTAssertEqual(ca2.wrappedElements.count, 1)
        XCTAssertEqual(ca2.next().map { Array($0) }!, [5])
        XCTAssertEqual(ca2.wrappedElements.count, 0)
        XCTAssertNil(ca2.next())
    }

    // Test using the sequence for its purpose.
    func testSequencing() {
        let a = [1, 2, 3, 4, 5]
        let ca = ChunkedCollection(a, span: 2, targetStartIndex: a.index(after: a.startIndex), targetEndIndex: a.index(before: a.endIndex))
        XCTAssertTrue(Array(ca).map { Array($0) }.elementsEqual([[2, 3], [4]], by: ==))
    }

    // Test getting a sequence's underestimate of the wrapped count.
    func testSequenceCount() {
        // Empty, sub-random-access collection
        var d = [Int: String]()
        let s1 = ChunkedCollection(d, span: 2)
        XCTAssertEqual(s1.underestimatedCount, 0)

        // Non-empty, sub-random-access collection
        d = [1: "1", 2: "two", 3: "tres"]
        let s2 = ChunkedCollection(d, span: 2)
        XCTAssertEqual(s2.underestimatedCount, 1)  // not 2

        // Empty, random-access collection
        var a = [Int]()
        let s3 = ChunkedCollection(a, span: 2)
        XCTAssertEqual(s3.underestimatedCount, 0)

        // Non-empty, random-access collection
        a = [1, 2, 3, 4, 5]
        let s4 = ChunkedCollection(a, span: 2)
        XCTAssertEqual(s4.underestimatedCount, 3)
    }

    // Test using a collection's index members
    func testCollectionIndexing() {
        // Correspondance between inner and outer indices.
        let a = [1, 2, 3, 4, 5]
        let ca = ChunkedCollection(a, span: 2)
        XCTAssertEqual(ca.startIndex, ca.base.startIndex)
        XCTAssertEqual(ca.endIndex, ca.base.endIndex)

        // Single-step advancing.
        let caSecond = ca.index(after: ca.startIndex)
        XCTAssertEqual(ca.base.distance(from: ca.startIndex, to: caSecond), +2)
        XCTAssertEqual(ca.base.distance(from: caSecond, to: ca.startIndex), -2)
        XCTAssertEqual(ca.distance(from: ca.startIndex, to: caSecond), +1)
        XCTAssertEqual(ca.distance(from: caSecond, to: ca.startIndex), -1)
        let caThird = ca.index(after: caSecond)
        XCTAssertEqual(ca.base.distance(from: caSecond, to: caThird), +2)
        XCTAssertEqual(ca.base.distance(from: caThird, to: caSecond), -2)
        XCTAssertEqual(ca.distance(from: caSecond, to: caThird), +1)
        XCTAssertEqual(ca.distance(from: caThird, to: caSecond), -1)
        XCTAssertEqual(ca.base.distance(from: ca.startIndex, to: caThird), +4)
        XCTAssertEqual(ca.base.distance(from: caThird, to: ca.startIndex), -4)
        XCTAssertEqual(ca.distance(from: ca.startIndex, to: caThird), +2)
        XCTAssertEqual(ca.distance(from: caThird, to: ca.startIndex), -2)

        XCTAssertEqual(ca.index(after: caThird), ca.endIndex)
        XCTAssertEqual(ca.base.distance(from: caThird, to: ca.endIndex), +1)
        XCTAssertEqual(ca.base.distance(from: ca.endIndex, to: caThird), -1)
        XCTAssertEqual(ca.distance(from: caThird, to: ca.endIndex), +1)
        XCTAssertEqual(ca.distance(from: ca.endIndex, to: caThird), -1)
        XCTAssertEqual(ca.base.distance(from: caSecond, to: ca.endIndex), +3)
        XCTAssertEqual(ca.base.distance(from: ca.endIndex, to: caSecond), -3)
        XCTAssertEqual(ca.distance(from: caSecond, to: ca.endIndex), +2)
        XCTAssertEqual(ca.distance(from: ca.endIndex, to: caSecond), -2)

        XCTAssertEqual(ca.base.distance(from: ca.startIndex, to: ca.endIndex), +5)
        XCTAssertEqual(ca.base.distance(from: ca.endIndex, to: ca.startIndex), -5)
        XCTAssertEqual(ca.distance(from: ca.startIndex, to: ca.endIndex), +3)
        XCTAssertEqual(ca.distance(from: ca.endIndex, to: ca.startIndex), -3)

        // Same-index distance.
        XCTAssertEqual(ca.base.distance(from: ca.startIndex, to: ca.startIndex), 0)
        XCTAssertEqual(ca.distance(from: ca.startIndex, to: ca.startIndex), 0)
        XCTAssertEqual(ca.base.distance(from: caSecond, to: caSecond), 0)
        XCTAssertEqual(ca.distance(from: caSecond, to: caSecond), 0)
        XCTAssertEqual(ca.base.distance(from: caThird, to: caThird), 0)
        XCTAssertEqual(ca.distance(from: caThird, to: caThird), 0)
        XCTAssertEqual(ca.base.distance(from: ca.endIndex, to: ca.endIndex), 0)
        XCTAssertEqual(ca.distance(from: ca.endIndex, to: ca.endIndex), 0)

        // Advancing past the end.
        XCTAssertEqual(ca.index(after: ca.endIndex), ca.endIndex)

        // Multi-step advancing.
        XCTAssertEqual(ca.index(ca.startIndex, offsetBy: +3), ca.endIndex)
        XCTAssertEqual(ca.index(ca.endIndex, offsetBy: -3), ca.startIndex)
        XCTAssertEqual(ca.index(ca.startIndex, offsetBy: 0), ca.startIndex)
        XCTAssertEqual(ca.index(ca.endIndex, offsetBy: 0), ca.endIndex)
    }

    // Test using a collection's subscript members.
    func testCollectionDereference() {
        // Single-element subscripting.
        let a = [1, 2, 3, 4, 5]
        let ca = ChunkedCollection(a, span: 2)
        XCTAssertEqual(ca[ca.startIndex], [1, 2])
        let caSecond = ca.index(after: ca.startIndex)
        XCTAssertEqual(ca[caSecond], [3, 4])
        let caThird = ca.index(after: caSecond)
        XCTAssertEqual(ca[caThird], [5])

        // Range subscripting.
        let emptyCa = ca[caSecond ..< caSecond]
        XCTAssertTrue(emptyCa.isEmpty)
        XCTAssertEqual(emptyCa.startIndex, caSecond)
        let middleCa = ca[caSecond ..< caThird]
        XCTAssertEqual(middleCa.count, 1)
        XCTAssertEqual(middleCa.startIndex, caSecond)
        XCTAssertEqual(middleCa.endIndex, caThird)
        XCTAssertEqual(middleCa.first!, [3, 4])
        let nonFirstCa = ca[caSecond ..< ca.endIndex]
        XCTAssertEqual(nonFirstCa.count, 2)
        XCTAssertEqual(nonFirstCa.startIndex, caSecond)
        XCTAssertEqual(nonFirstCa.index(after: nonFirstCa.startIndex), caThird)
        XCTAssertEqual(nonFirstCa.endIndex, ca.endIndex)
        XCTAssertEqual(nonFirstCa[caSecond], [3, 4])
        XCTAssertEqual(nonFirstCa[caThird], [5])
    }

    // Test getting a collection's sub-collection collection
    func testCollectionChunked() {
        let d = [1: "1", 2: "two", 3: "tres"]
        let chunkedD = d.lazy.chunked(withChunkSize: 2)
        XCTAssertEqual(chunkedD.count, 2)
        XCTAssertEqual(chunkedD.first?.count, 2)
        XCTAssertEqual(chunkedD[chunkedD.index(after: chunkedD.startIndex)].count, 1)

        let a = 1...5
        let chunkedA = a.lazy.chunked(withChunkSize: 2)
        XCTAssertEqual(chunkedA.count, 3)
        XCTAssertTrue(chunkedA[chunkedA.startIndex].elementsEqual([1, 2]))
        XCTAssertTrue(chunkedA[chunkedA.index(after: chunkedA.startIndex)].elementsEqual([3, 4]))
        XCTAssertTrue(chunkedA[chunkedA.index(chunkedA.endIndex, offsetBy: -1)].elementsEqual([5]))
        XCTAssertTrue(chunkedA.elements.map { Array($0) }.elementsEqual([[1, 2], [3, 4], [5]], by: ==))
    }

    // List of tests for Linux.
    static var allTests = [
        ("testPropertyInitializer", testPropertyInitializer),
        ("testRegularInitializer", testRegularInitializer),
        ("testCoreProperties", testCoreProperties),

        ("testIterator", testIterator),

        ("testSequencing", testSequencing),
        ("testSequenceCount", testSequenceCount),

        ("testCollectionIndexing", testCollectionIndexing),
        ("testCollectionDereference", testCollectionDereference),

        ("testCollectionChunked", testCollectionChunked),
    ]

}
