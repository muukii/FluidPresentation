//
//  RootViewController.swift
//  Demo
//
//  Created by Muukii on 2021/04/14.
//

import Foundation
import TextureSwiftSupport
import TinyConstraints

final class AppRootViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    let tab = AppTabBarController()
    addChild(tab)
    view.addSubview(tab.view)
    tab.view.edgesToSuperview()
    tab.didMove(toParent: self)

  }
}
