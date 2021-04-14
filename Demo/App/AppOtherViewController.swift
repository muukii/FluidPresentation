//
//  AppOtherViewController.swift
//  Demo
//
//  Created by Muukii on 2021/04/14.
//

import UIKit
import TextureSwiftSupport
import FluidPresentation

final class AppOtherController: StackScrollNodeViewController {

  override func viewDidLoad() {

    super.viewDidLoad()

    definesPresentationContext = true

    stackScrollNode.append(nodes: [
      Components.makeTitleCell(title: "Other"),

      Components.makeSelectionCell(title: "Open", onTap: { [unowned self] in

        let controller = AppNotificationController().wrappingNavigatedFluidViewController(idiom: .navigationPush())

        controller.dismissingInteractions = [.init(trigger: .screen, startFrom: .left)]

        controller.modalPresentationStyle = .currentContext

        self.present(controller, animated: true, completion: nil)
      })
    ])
  }
}
