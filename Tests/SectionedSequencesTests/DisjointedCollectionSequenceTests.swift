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
        XCTAssertEqual(i.elements, a)
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

    // List of tests for Linux.
    static var allTests = [
        ("testIteratorInitialState", testIteratorInitialState),
        ("testIteratorEmptyCollection", testIteratorEmptyCollection),
        ("testIteratorFittedCollection", testIteratorFittedCollection),
        ("testIteratorUnfittingCollection", testIteratorUnfittingCollection),
    ]

}
