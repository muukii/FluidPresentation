//
//  AppOtherViewController.swift
//  Demo
//
//  Created by Muukii on 2021/04/14.
//

import FluidPresentation
import TextureSwiftSupport
import UIKit

final class AppSearchViewController: StackScrollNodeViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Search"

    stackScrollNode.append(nodes: [

      Components.makeSelectionCell(
        title: "Open VC stacked",
        onTap: { [unowned self] in

          let other = MenuViewController()
          NavigatedFluidViewController(idiom: .presentation, bodyViewController: other)
            .fluidContext
            .present(from: self, animated: true, completion: nil)

        }
      )
    ])
  }
}

private final class MenuViewController: DisplayNodeViewController {

  private let stackScrollNode = StackScrollNode()

  private let child = ChildMenuViewController()

  override func viewDidLoad() {
    super.viewDidLoad()

    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }

    title = "Menu"

    definesPresentationContext = true

    stackScrollNode.append(nodes: [

      Components.makeTitleCell(title: "Parent"),

      Components.makeSelectionCell(
        title: "Open in FullScreen",
        onTap: { [unowned self] in

          let other = MenuViewController()
          NavigatedFluidViewController(idiom: .presentation, bodyViewController: other)
            .fluidContext
            .present(from: self, animated: true, completion: nil)

        }
      ),

      Components.makeSelectionCell(
        title: "Open in Context",
        onTap: { [unowned self] in

          let other = MenuViewController()
          NavigatedFluidViewController(idiom: .presentation, bodyViewController: other)
            .fluidContext
            .present(in: self, animated: true, completion: nil)

        }
      ),
    ])

    child: do {
      addChild(child)
      child.didMove(toParent: self)
    }

  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    LayoutSpec {
      VStackLayout {
        stackScrollNode
          .flexBasis(fraction: 0.5)
        child.node
          .flexGrow(1)
      }
    }
  }

}

private final class ChildMenuViewController: DisplayNodeViewController {

  private let stackScrollNode = StackScrollNode()

  override func viewDidLoad() {
    super.viewDidLoad()

    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }

    title = "Menu"

    definesPresentationContext = true

    stackScrollNode.append(nodes: [

      Components.makeTitleCell(title: "Child"),

      Components.makeSelectionCell(
        title: "Open in FullScreen",
        onTap: { [unowned self] in

          let other = MenuViewController()
          NavigatedFluidViewController(idiom: .presentation, bodyViewController: other)
            .fluidContext
            .present(from: self, animated: true, completion: nil)

        }
      ),

      Components.makeSelectionCell(
        title: "Open in Context",
        onTap: { [unowned self] in

          let other = MenuViewController()
          NavigatedFluidViewController(idiom: .presentation, bodyViewController: other)
            .fluidContext
            .present(in: self, animated: true, completion: nil)

        }
      ),

      Components.makeSelectionCell(
        title: "Open in Context Default",
        onTap: { [unowned self] in

          let other = MenuViewController()
          other.modalPresentationStyle = .currentContext
          self.present(other, animated: true, completion: nil)

        }
      ),
    ])

  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    LayoutSpec {
      stackScrollNode
    }
  }

}
