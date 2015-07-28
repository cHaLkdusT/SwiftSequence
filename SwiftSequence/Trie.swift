// MARK: Definition

/**
A Trie is a set-like data structure. It stores *sequences* of hashable elements, though.
Lookup, insertion, and deletion are all *O(n)*, where *n* is the length of the sequence.

*/

public struct Trie<Element : Hashable> {
  private var children: [Element:Trie<Element>]
  private var endHere : Bool
  public init() {
    children = [:]
    endHere  = false
  }
}

extension Trie : CustomDebugStringConvertible {
  public var debugDescription: String {
    return ", ".join(contents.map {"".join($0.map { String(reflecting: $0) })})
  }
}

// MARK: Init

extension Trie {
  private init<G : GeneratorType where G.Element == Element>(var gen: G) {
    if let head = gen.next() {
      (children, endHere) = ([head:Trie(gen:gen)], false)
    } else {
      (children, endHere) = ([:], true)
    }
  }
}

extension Trie {
  private mutating func insert
    <G : GeneratorType where G.Element == Element>
    (var gen: G) {
      if let head = gen.next() {
        children[head]?.insert(gen) ?? {children[head] = Trie(gen: gen)}()
      } else {
        endHere = true
      }
  }
}

extension Trie {
  public init<
    S : SequenceType, IS : SequenceType where
    S.Generator.Element == IS,
    IS.Generator.Element == Element
    >(_ seq: S) {
      var trie = Trie()
      for word in seq { trie.insert(word) }
      self = trie
  }
}

public extension Trie {
  public init
    <S : SequenceType where S.Generator.Element == Element>
    (_ seq: S) {
      self.init(gen: seq.generate())
  }
  public mutating func insert
    <S : SequenceType where S.Generator.Element == Element>
    (seq: S) {
      insert(seq.generate())
  }
}

// MARK: SequenceType

extension Trie {
  public var contents: [[Element]] {
    return children.flatMap {
      (head: Element, child: Trie<Element>) -> [[Element]] in
      return child.contents.map { [head] + $0 } + (child.endHere ? [[head]] : [])
    }
  }
}

extension Trie: SequenceType {
  public func generate() -> IndexingGenerator<[[Element]]>  {
    return contents.generate()
  }
}

// MARK: Methods

extension Trie {
  private func completions
    <G : GeneratorType where G.Element == Element>
    (var start: G) -> [[Element]] {
      return start.next().map {
        head in
        children[head]?
          .completions(start)
          .map { [head] + $0 } ?? []
        } ?? contents
  }
  
  public func completions<S : SequenceType where S.Generator.Element == Element>(start: S) -> [[Element]] {
    return completions(start.generate())
  }
}

// MARK: Set Methods

public extension Trie {
  private func contains
    <G : GeneratorType where G.Element == Element>
    (var gen: G) -> Bool {
      return gen.next().map{self.children[$0]?.contains(gen) ?? false} ?? endHere
  }
  public func contains
    <S : SequenceType where S.Generator.Element == Element>
    (seq: S) -> Bool {
      return contains(seq.generate())
  }

  private mutating func remove
    <G : GeneratorType where G.Element == Element>
    (var gen: G) {
      if let head = gen.next() {
        children[head]?.remove(gen)
      } else {
        endHere = false
      }
  }
  public mutating func remove
    <S : SequenceType where S.Generator.Element == Element>
    (seq: S) {
      remove(seq.generate())
  }

  public mutating func unionInPlace(with: Trie<Element>) {
    for (head, child) in with.children {
      children[head]?.unionInPlace(child) ?? {children[head] = child}()
    }
  }

  public mutating func exclusiveOrInPlace<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) {
      for toRemove in sequence { remove(toRemove) }
  }

  public func intersect<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) -> Trie<Element> {
      var ret = Trie()
      for element in sequence where contains(element) { ret.insert(element) }
      return ret
  }

  public func isDisjointWith<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) -> Bool { return !sequence.contains(self.contains) }
}

// MARK: More effecient implementations

extension Trie {
  public func map<S : SequenceType>(@noescape transform: [Element] -> S) -> Trie<S.Generator.Element> {
    return Trie<S.Generator.Element>(contents.map(transform))
  }
}

extension Trie {
  public func flatMap<S : SequenceType>(@noescape transform: [Element] -> S?) -> Trie<S.Generator.Element> {
    var ret = Trie<S.Generator.Element>()
    for case let seq? in contents.map(transform) { ret.insert(seq) }
    return ret
  }
  public func flatMap<T>(@noescape transform: [Element] -> Trie<T>) -> Trie<T> {
    var ret = Trie<T>()
    for trie in contents.map(transform) { ret.unionInPlace(trie) }
    return ret
  }
}

extension Trie {
  public func filter(@noescape includeElement: [Element] -> Bool) -> Trie<Element> {
    var ret = Trie()
    for element in contents where includeElement(element) { ret.insert(element) }
    return ret
  }
}

extension Trie {
  public var count: Int {
    return children.values.reduce(endHere ? 1 : 0) { $0 + $1.count }
  }
}