import XCTest
@testable import SectionedSequencesTests


XCTMain([
    testCase(ClusteringIteratorTests.allTests),
    testCase(DisjointedCollectionSequenceTests.allTests),
])
