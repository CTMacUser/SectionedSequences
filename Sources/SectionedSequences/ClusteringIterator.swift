/*

  ClusteringIterator.swift
  SectionedSequences

  Created by Daryle Walker on 1/1/18.
  Copyright (c) 2018 Daryle Walker.
  Distributed under the MIT License.

  Iterator and sequence that return collections of the results from another iterator/sequence.

 */


// MARK: - Element-Clustering Iterator

/// An iterator that wraps another and vends fixed-size collections of the inner iterator's output.
public struct ClusteringIterator<Base: IteratorProtocol> {

    /// The wrapped iterator.
    public private(set) var elements: Base
    /// The count of inner elements per collection element, except possibly the last.
    public let span: Int

    /**
     Creates an instance wrapping another iterator and vending its elements a pack at a time.

     - Precondition: `span > 0`.

     - Parameter base: The iterator extracting (inner) elements.

     - Parameter span: The count of inner elements per collection element vended.  The last element may have a count shorter than this.

     - Postcondition:
         - `self.elements` is equivalent to `base`.
         - `self.span == span`.
     */
    public init(_ base: Base, span: Int) {
        precondition(span > 0)

        elements = base
        self.span = span
    }

}

// MARK: IteratorProtocol

extension ClusteringIterator: IteratorProtocol {

    public mutating func next() -> [Base.Element]? {
        var result = [Base.Element]()
        result.reserveCapacity(span)
        for _ in 0..<span {
            guard let latest = elements.next() else { break }

            result.append(latest)
        }
        guard !result.isEmpty else { return nil }

        return result
    }

}

// MARK: - Element-Clustering Sequence

/// A sequence that wraps another and vends fixed-size collections of the inner sequence's elements.
public struct ClusteringSequence<Base: Sequence> {

    /// The wrapped sequence.
    public private(set) var elements: Base
    /// The count of each collection, except possibly the last.
    public let span: Int

    /**
     Creates an instance wrapping another sequence and vending its elements a pack at a time.

     - Precondition: `span > 0`.

     - Parameter base: The sequence of source elements.

     - Parameter span: The count of inner elements per collection vended.  The last element may have a count shorter than this.

     - Postcondition:
         - `self.elements` is equivalent to `base`.
         - `self.span == span`.
     */
    public init(_ base: Base, span: Int) {
        precondition(span > 0)

        elements = base
        self.span = span
    }

}

// MARK: Sequence

extension ClusteringSequence: Sequence {

    public func makeIterator() -> ClusteringIterator<Base.Iterator> {
        return ClusteringIterator(elements.makeIterator(), span: span)
    }

}

extension ClusteringSequence {

    public var underestimatedCount: Int {
        let (blockCount, stragglerCount) = elements.underestimatedCount.quotientAndRemainder(dividingBy: span)
        return blockCount + stragglerCount.signum()
    }

}

extension ClusteringSequence where Base: RandomAccessCollection {

    public var underestimatedCount: Int {
        let (blockCount, stragglerCount) = elements.count.quotientAndRemainder(dividingBy: numericCast(span))
        return numericCast(blockCount + stragglerCount.signum())
    }

}
