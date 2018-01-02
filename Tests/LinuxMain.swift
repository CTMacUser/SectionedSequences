import XCTest
@testable import SectionedSequencesTests


XCTMain([
    testCase(SectionedSequencesTests.allTests),
    testCase(ClusteringIteratorTests.allTests),
])
