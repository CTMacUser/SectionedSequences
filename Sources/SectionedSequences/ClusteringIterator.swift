/*

  ClusteringIterator.swift
  SectionedSequences

  Created by Daryle Walker on 1/1/18.
  Copyright (c) 2018 Daryle Walker.
  Distributed under the MIT License.

  An iterator that returns collections of the results from another iterator.

 */


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
