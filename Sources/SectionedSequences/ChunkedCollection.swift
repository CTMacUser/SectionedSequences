/*

  ChunkedCollection.swift
  SectionedSequences

  Created by Daryle Walker on 1/6/18.
  Copyright (c) 2018 Daryle Walker.
  Distributed under the MIT License.

  Collection that returns fixed-size sub-collections of a wrapped collection.

 */


// MARK: - Chunked Collection

/// A collection whose elements are fixed-sized sub-collections of the wrapped collection.
public struct ChunkedCollection<Base: Collection> {

    /// The wrapped collection.
    var base: Base
    /// The count of each sub-collection, except possibly the last.
    public let span: Base.IndexDistance
    /// The range of wrapped elements considered for access.
    var target: Range<Base.Index>

    /**
     Creates an instance wrapping the given collection, to vend sub-collections of its targeted elements in-order, each with a count (except possibly the last) of the given span.

     - Precondition:
        - `span > 0`.
        - `base.startIndex <= targetStartIndex <= targetEndIndex <= base.endIndex`.

     - Parameter base: The collection of all the elements.

     - Parameter span: The count of elements per sub-collection vended.  The last element may have a count shorter than this.

     - Parameter targetStartIndex: The starting index for the subset of the collection to actually be included as sub-collection elements.

     - Parameter targetEndIndex: The one-past-the-end index for the subset of the collection to actually be included as sub-collection elements.

     - Postcondition:
        - `self.base` is equivalent to `base`.
        - `self.span == span`.
        - All vended elements of `base` have indices within `[targetStartIndex, targetEndIndex)`.  The indices *i* that can be dereferenced by this instance have `base.distance(from: targetStartIndex, to: i) % span == 0`.  A sub-collection element is extracted from `base[i ..< (base.index(i, offsetBy: span, limitedBy: targetEndIndex) ?? targetEndIndex)]`.
     */
    init(_ base: Base, span: Base.IndexDistance, targetStartIndex: Base.Index, targetEndIndex: Base.Index) {
        precondition(span > 0)
        precondition(base.startIndex <= targetStartIndex)
        precondition(targetStartIndex <= targetEndIndex)
        precondition(targetEndIndex <= base.endIndex)

        self.base = base
        self.span = span
        self.target = targetStartIndex ..< targetEndIndex
    }

    /**
     Creates an instance wrapping the given collection, to vend sub-collections of all of its elements in-order, each with a count (except possibly the last) of the given span.

     - Precondition: `span > 0`.

     - Parameter base: The collection of all the elements.

     - Parameter span: The count of elements per sub-collection vended.  The last element may have a count shorter than this.

     - Postcondition:
        - `self.base` is equivalent to `base`.
        - `self.span == span`.

     - SeeAlso: init(_:span:targetStartIndex:targetEndIndex:)
     */
    public init(_ base: Base, span: Base.IndexDistance) {
        self.init(base, span: span, targetStartIndex: base.startIndex, targetEndIndex: base.endIndex)
    }

}

// MARK: Custom Properties

extension ChunkedCollection {

    /// The targeted elements of the wrapped collection.
    public var wrappedElements: Base.SubSequence {
        return base[target]
    }

}

// MARK: IteratorProtocol

extension ChunkedCollection: IteratorProtocol {

    public mutating func next() -> Base.SubSequence? {
        guard !target.isEmpty else { return nil }

        let nextIndex = index(after: startIndex)
        defer { target = nextIndex ..< target.upperBound }
        return base[startIndex ..< nextIndex]
    }

}

// MARK: Sequence

extension ChunkedCollection: Sequence {}

extension ChunkedCollection {

    public var underestimatedCount: Int {
        return target.isEmpty ? 0 : 1
    }

}

extension ChunkedCollection where Base: RandomAccessCollection {

    public var underestimatedCount: Int {
        let (blockCount, stragglerCount) = base.distance(from: target.lowerBound, to: target.upperBound).quotientAndRemainder(dividingBy: span)
        return numericCast(blockCount + stragglerCount.signum())
    }

}

// MARK: Collection

extension ChunkedCollection: Collection {

    public var startIndex: Base.Index {
        return target.lowerBound
    }

    public var endIndex: Base.Index {
        return target.upperBound
    }

    public subscript(position: Base.Index) -> Base.SubSequence {
        var s = self[position ..< endIndex]
        return s.next()!
    }

    public subscript(bounds: Range<Base.Index>) -> ChunkedCollection {
        return ChunkedCollection(base, span: span, targetStartIndex: bounds.lowerBound, targetEndIndex: bounds.upperBound)
    }

    public func index(after i: Base.Index) -> Base.Index {
        return index(i, offsetBy: +1)
    }

    public func distance(from start: Base.Index, to end: Base.Index) -> IndexDistance {
        let (dq, dr) = base.distance(from: start, to: end).quotientAndRemainder(dividingBy: span)
        return numericCast(dq + dr.signum())
    }

    public func index(_ i: Base.Index, offsetBy n: Int) -> Base.Index {
        if i == endIndex, n < 0 {
            let stragglerCount = numericCast(count) % span
            if stragglerCount != 0 {
                let p = base.index(i, offsetBy: -stragglerCount)
                return index(p, offsetBy: n + 1)
            }
        }
        let limit = (n >= 0) ? target.upperBound : target.lowerBound
        return base.index(i, offsetBy: numericCast(n) * span, limitedBy: limit) ?? limit
    }

}

// MARK: LazyCollectionProtocol

extension ChunkedCollection: LazyCollectionProtocol {}

// MARK: - Collection of Sub-Collections Generator

extension LazyCollectionProtocol {

    /**
     Returns a collection that groups the elements of this collection, in the same relative order, into sub-sequences with a fixed span.

     - Precondition: `span > 0`.

     - Parameter span: The count of elements per sub-collection vended.  The last element may have a count shorter than this.

     - Returns: The collection of disjoint element sub-collections.
     */
    public func chunked(withChunkSize span: Self.IndexDistance) -> ChunkedCollection<Self> {
        return ChunkedCollection(self, span: span)
    }

}
