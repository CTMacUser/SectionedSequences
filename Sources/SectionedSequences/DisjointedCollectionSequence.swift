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
    public private(set) var base: Base
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
         - `self.base` is equivalent to `base`.
         - `self.span == span`.
         - The first sub-collection to return is at the start of `self.base` (if not empty).
     */
    public init(_ base: Base, span: Base.IndexDistance) {
        precondition(span > 0)

        self.base = base
        self.span = span
        start = base.startIndex
    }

}

// MARK: IteratorProtocol

extension DisjointedCollectionIterator: IteratorProtocol {

    public mutating func next() -> Base.SubSequence? {
        guard start < base.endIndex else { return nil }

        let nextIndex = base.index(start, offsetBy: span, limitedBy: base.endIndex) ?? base.endIndex
        defer { start = nextIndex }
        return base[start ..< nextIndex]
    }

}

// MARK: - Sub-Collections from a Collection

extension Collection {

    /**
     Returns a collection made of fixed-size sub-collections of this collection's elements in-order.

     - Precondition: `span > 0`.

     - Parameter span: The count of elements per inner collection.  The last inner collection may have a count shorter than this.

     - Returns: The collection of disjoint element collections.
     */
    public func disjoint(eachSpanning span: IndexDistance) -> [SubSequence] {
        return Array(IteratorSequence(DisjointedCollectionIterator(self, span: span)))
    }

}

// MARK: - Sub-Collection Sequence

/// A sequence over fixed-sized subsequent sub-sequences of a wrapped collection.
public struct DisjointedCollectionSequence<Base: Collection> {

    /// The wrapped collection.
    public private(set) var base: Base
    /// The count of each sub-collection, except possibly the last.
    public let span: Base.IndexDistance

    /**
     Creates an instance wrapping the given collection to vend sub-collections of its elements in-order, each with a count (except possibly the last) of the given span.

     - Precondition: `span > 0`.

     - Parameter base: The collection of all the elements.

     - Parameter span: The count of elements per sub-collection vended.  The last element may have a count shorter than this.

     - Postcondition:
         - `self.base` is equivalent to `base`.
         - `self.span == span`.
     */
    public init(_ base: Base, span: Base.IndexDistance) {
        precondition(span > 0)

        self.base = base
        self.span = span
    }

}

// MARK: Sequence

extension DisjointedCollectionSequence: Sequence {

    public func makeIterator() -> DisjointedCollectionIterator<Base> {
        return DisjointedCollectionIterator(base, span: span)
    }

}

extension DisjointedCollectionSequence {

    public var underestimatedCount: Int {
        return base.isEmpty ? 0 : 1
    }

}

extension DisjointedCollectionSequence where Base: RandomAccessCollection {

    public var underestimatedCount: Int {
        let (blockCount, stragglerCount) = base.count.quotientAndRemainder(dividingBy: span)
        return numericCast(blockCount + stragglerCount.signum())
    }

}

// MARK: LazySequenceProtocol

extension DisjointedCollectionSequence: LazySequenceProtocol {}

// MARK: - Sub-Collection Sequence Generator

extension LazyCollectionProtocol {

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
