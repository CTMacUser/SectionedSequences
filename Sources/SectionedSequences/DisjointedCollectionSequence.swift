/*

  DisjointedCollectionSequence.swift
  SectionedSequences

  Created by Daryle Walker on 1/2/18.
  Copyright (c) 2018 Daryle Walker.
  Distributed under the MIT License.

  Iterator and sequence that return fixed-size sub-collections from a collection.

 */


// MARK: - Sub-Collection Iterator

/// An iterator that wraps a collection and vends subsequent fixed-size sub-collections.
public struct DisjointedCollectionIterator<Base: Collection> {

    /// The wrapped collection.
    public private(set) var elements: Base
    /// The count of each sub-collection, except possibly the last.
    public let span: Base.IndexDistance
    /// The starting index of the next sub-collection.
    var start: Base.Index

    /**
     Creates an instance wrapping the given collection to vend sub-collections of its elements in-order, each with a count (except possibly the last) of the given span.

     - Precondition: `span > 0`.

     - Parameter base: The collection of all the elements.

     - Parameter span: The count of elements per sub-collection vended.  The last element may have a count shorter than this.

     - Postcondition:
         - `self.elements` is equivalent to `base`.
         - `self.span == span`.
         - The first sub-collection to return is at the start of `self.elements` (if not empty).
     */
    public init(_ base: Base, span: Base.IndexDistance) {
        precondition(span > 0)

        elements = base
        self.span = span
        start = elements.startIndex
    }

}

// MARK: IteratorProtocol

extension DisjointedCollectionIterator: IteratorProtocol {

    public mutating func next() -> Base.SubSequence? {
        guard start < elements.endIndex else { return nil }

        if let nextIndex = elements.index(start, offsetBy: span, limitedBy: elements.endIndex) {
            defer { start = nextIndex }
            return elements[start ..< nextIndex]
        } else {
            defer { start = elements.endIndex }
            return elements[start...]
        }
    }

}

// MARK: - Sub-Collection Sequence

/// A sequence over fixed-sized subsequent sub-sequences of a wrapped collection.
public struct DisjointedCollectionSequence<Base: Collection> {

    /// The wrapped collection.
    public private(set) var elements: Base
    /// The count of each sub-collection, except possibly the last.
    public let span: Base.IndexDistance

    /**
     Creates an instance wrapping the given collection to vend sub-collections of its elements in-order, each with a count (except possibly the last) of the given span.

     - Precondition: `span > 0`.

     - Parameter base: The collection of all the elements.

     - Parameter span: The count of elements per sub-collection vended.  The last element may have a count shorter than this.

     - Postcondition:
         - `self.elements` is equivalent to `base`.
         - `self.span == span`.
     */
    public init(_ base: Base, span: Base.IndexDistance) {
        precondition(span > 0)

        elements = base
        self.span = span
    }

}

// MARK: Sequence

extension DisjointedCollectionSequence: Sequence {

    public func makeIterator() -> DisjointedCollectionIterator<Base> {
        return DisjointedCollectionIterator(elements, span: span)
    }

}

extension DisjointedCollectionSequence {

    public var underestimatedCount: Int {
        return elements.isEmpty ? 0 : 1
    }

}

extension DisjointedCollectionSequence where Base: RandomAccessCollection {

    public var underestimatedCount: Int {
        let (blockCount, stragglerCount) = elements.count.quotientAndRemainder(dividingBy: span)
        return numericCast(blockCount + stragglerCount.signum())
    }

}

// MARK: - Sub-Collection Sequence Generator

extension Collection {

    /**
     Returns a sequence that generates the elements of this collection, in the same relative order, but segmented into sub-sequences, each with element counts of the given span.

     - Precondition: `span > 0`.

     - Parameter span: The count of elements per sub-collection vended.  The last element may have a count shorter than this.

     - Returns: The sequence of disjoint element sub-collections.
     */
    public func disjoint(eachSpanning span: Self.IndexDistance) -> DisjointedCollectionSequence<Self> {
        return DisjointedCollectionSequence(self, span: span)
    }

}
