# SectionedSequences

Sequences that wrap other sequences and vend their sub-sequences (of a set size).

For a given *sequencing source*, its *chunked sequence* with a parameter *N* as the *span* is a sequence of collections, where the first element is a collection of the first *N* elements of the original sequence, the second element is the second group of *N* elements, *etc.*  If the source sequence is finite and has a length that is not evenly divisible by *N*, then the last element of the chunked sequence has a element count less than *N*.

## Installation

Use the [Swift Package Manager](https://github.com/apple/swift-package-manager) to incorporate this repository as a library.  Or download a copy and add the applicable files to your project directly.

## Type Overview

The `ClusteringIterator` iterator type can be initialized with another iterator and a given span.  Its `next()` method returns an `Array` of elements from the wrapped iterator, by calling its `next()` until the set span of elements have been extracted or `nil` was returned.

The `ClusteringSequence` sequence type is initialized with another sequence and a given span.  It uses an internal `ClusteringIterator` to extract its elements as `Array`s of the inner element type.

The `Sequence` and `LazySequenceProtocol` protocols have been extended to provide eager and lazy versions of `clustered(eachSpanning:)`, which return sequences wrapping the receiver.

The `DisjointedCollectionIterator` iterator type can be initialized with a collection and a given span.  Instead of `Array` instances, this iterator's `next()` returns sub-collections as `SubSequence`s of the wrapped collection type.  The initializer for the corresponding sequence type, `DisjointedCollectionSequence`, also takes a collection and span, while the type vends the same kind of elements.  The `Collection` and `LazyCollectionProtocol` protocols have been extended to provide eager and lazy versions of `disjoint(eachSpanning:)`, which return sequences wrapping the receiver.

The `ChunkedCollection` collection type can be used to wrap a collection for sub-sequence elements in a way that permits multiple passes.  Its (`public`) initializer works like the others with a target collection and given span.  It serves as its own iterator and sub-sequence type.  It conforms to `LazyCollectionProtocol` and said protocol has been extended to generate chunked collections of a receiver with the `chunked(withChunkSize:)` method.
