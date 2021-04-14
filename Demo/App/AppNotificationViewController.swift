//
//  AppNotificationViewController.swift
//  Demo
//
//  Created by Muukii on 2021/04/14.
//

import Foundation

final class AppNotificationController: StackScrollNodeViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    stackScrollNode.append(nodes: [
      Components.makeTitleCell(title: "Notifications")
    ])
  }
}
