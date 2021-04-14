//
//  AppTabBarController.swift
//  Demo
//
//  Created by Muukii on 2021/04/14.
//

import UIKit

final class AppTabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    viewControllers = [
      UINavigationController(rootViewController: AppSearchViewController()),
      UINavigationController(rootViewController: AppOtherController()),
    ]
  }

}
