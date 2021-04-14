//
//  AppOtherViewController.swift
//  Demo
//
//  Created by Muukii on 2021/04/14.
//

import UIKit
import TextureSwiftSupport

final class AppSearchViewController: StackScrollNodeViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Search"

    stackScrollNode.append(nodes: [

      Components.makeTitleCell(title: "Search"),

      Components.makeSelectionCell(title: "Open", onTap: {


      })
    ])
  }
}
