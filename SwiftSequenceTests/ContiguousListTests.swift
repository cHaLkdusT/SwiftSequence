import Foundation
import XCTest
@testable import SwiftSequence

class ContiguousListTests: XCTestCase {
  
  func testIndex() {
    
    let x = ContiguousListIndex(Int(arc4random_uniform(10000)))
    
    XCTAssert(x.distanceTo(x.successor()) == 1)
    
    XCTAssert(x.distanceTo(x.predecessor()) == -1)
    
    let y = ContiguousListIndex(Int(arc4random_uniform(10000)))
    
    XCTAssert(x.advancedBy(x.distanceTo(y)) == y)
    
    XCTAssert(x == x)
    
    XCTAssert(x.successor() > x)
    
    XCTAssert(x.predecessor() < x)
    
    XCTAssert(x.advancedBy(0) == x)
    
    XCTAssert(x.advancedBy(1) == x.successor())
    
    XCTAssert(x.advancedBy(-1) == x.predecessor())
    
    let m = Int(arc4random_uniform(10000)) - 5000
    
    XCTAssert(x.distanceTo(x.advancedBy(m)) == m)
    
  }
  
  func testIndexing() {
    
    let expectation = [1, 2, 3, 4, 5]
    
    let reality = ContiguousList(expectation)
    
    XCTAssert(expectation[expectation.endIndex.predecessor()] == reality[reality.endIndex.predecessor()])
    
    XCTAssert(expectation[expectation.startIndex] == reality[reality.startIndex])
    
    XCTAssert(expectation.count == reality.count)
    
    XCTAssert(expectation.elementsEqual(reality.indices.map{reality[$0]}))
    
  }
  
  func testIndexGetting() {
    
    let expectation = [Int](0...100)
    
    let reality = ContiguousList(expectation)
    
    for i in expectation.indices {
      XCTAssert(expectation[i] == reality[i])
    }
    
  }
  
  func testIndexSetting() {
    
    let array = [Int](0...10)
    
    let list = ContiguousList(array)
    
    for i in array.indices {
      
      var (expectation, reality) = (array, list)
      
      let n = Int(arc4random_uniform(10000))
      
      expectation[i] = n
      
      reality[i] = n
      
      XCTAssert(expectation.elementsEqual(reality))
    }
  }
  
  func testArrayLiteralConvertible() {
    
    let expectation = [1, 2, 3, 4, 5]
    
    let reality: ContiguousList = [1, 2, 3, 4, 5]
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testDebugDescription() {
    
    let expectation = [1, 2, 3, 4, 5].debugDescription
    
    let reality = ContiguousList(1...5).debugDescription
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  func testRemoveFirst() {
    
    let expectation = [Int](2...5)
    
    var reality = ContiguousList(1...5)
    
    XCTAssertEqual(reality.removeFirst(), 1)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testFirst() {
    
    let expectation = [Int](1...5)
    
    let reality = ContiguousList(expectation)
    
    XCTAssert(expectation.first == reality.first)
    
  }

  func testLast() {
    
    let expectation = [Int](1...5)
    
    let reality = ContiguousList(expectation)
    
    XCTAssert(expectation.last == reality.last)
    
  }
  
  func testEmtpy() {
    
    XCTAssert(ContiguousList<Int>().isEmpty)
    
  }
  
  func testSlice() {
    
    let array = [Int](0...100)
    
    let list = ContiguousList(array)
    
    let listRanges = (list.indices.map { $0...$0.successor().successor() })[0..<50]
    
    let arrayRanges = (array.indices.map { $0...$0.successor().successor() })[0..<50]
    
    for (arRange, liRange) in zip(arrayRanges, listRanges) {
      
      XCTAssert(array[arRange].elementsEqual(list[liRange]))
      
    }
  }
  
  func testSliceSet() {
    
    let array = [Int](0...100)
    
    let list = ContiguousList(array)
    
    let listRanges = (list.indices.map { $0...$0.successor().successor() })[0..<50]
    
    let arrayRanges = (array.indices.map { $0...$0.successor().successor() })[0..<50]
    
    for (arRange, liRange) in zip(arrayRanges, listRanges) {
      
      var (expectation, reality) = (array, list)
      
      expectation[arRange] = [5, 2, 8]
      
      reality[liRange] = [5, 2, 8]
      
      XCTAssert(expectation.elementsEqual(reality))
      
    }
  }
  
  func testPrepend() {
    
    let expectation = 0...10
    
    var reality = ContiguousList(1...10)
    
    reality.prepend(0)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testIntSlice() {
    
    let array = [Int](0...100)
    
    let list = ContiguousList(array)
    
    for range in (array.indices.map{$0...($0 + 4)})[0..<50] {
      
      XCTAssert(array[range].elementsEqual(list[range]))
      
    }
  }
  
  func testIntSliceSet() {
    
    let array = [Int](0...100)
    
    let list = ContiguousList(array)
    
    for range in (array.indices.map{$0...($0 + 4)})[0..<50] {
      
      var (expectation, reality) = (array, list)
      
      expectation[range] = [5, 2, 8]
      
      reality[range] = [5, 2, 8]
      
      XCTAssert(expectation.elementsEqual(reality))
    }
    
  }
  
  func testReverse() {
    
    let expectation = (0...10).reverse()
    
    let reality = ContiguousList(0...10).reverse()
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testReplaceRange() {
    
    let array = [Int](0...100)
    
    let list = ContiguousList(array)
    
    let listRanges = (list.indices.map { $0...$0.successor().successor() })[0..<50]
    
    let arrayRanges = (array.indices.map { $0...$0.successor().successor() })[0..<50]
    
    for (arRange, liRange) in zip(arrayRanges, listRanges) {
      
      var (expectation, reality) = (array, list)
      
      
      expectation.replaceRange(arRange, with: [5, 2, 8, 3, 5, 4, 1, 7])
      
      reality.replaceRange(liRange, with: [5, 2, 8, 3, 5, 4, 1, 7])
      
      XCTAssert(expectation.elementsEqual(reality))
      
    }
  }
  
}