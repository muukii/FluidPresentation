
import Foundation
import XCTest

final class NavigationItemKVOTests: XCTestCase {

  func testKVO() {

    let navigationItem = UINavigationItem()

    let titleExpectation = expectation(description: "")

    navigationItem.observe(\.title, options: [.new]) { item, _ in

    }


  }

}
