import XCTest
@testable import SectionedSequencesTests


XCTMain([
    testCase(ClusteringSequenceTests.allTests),
    testCase(DisjointedCollectionSequenceTests.allTests),
    testCase(ChunkedCollectionTests.allTests),
])
