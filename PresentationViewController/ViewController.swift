//
// Copyright (c) 2021 Hiroshi Kimura(Muukii) <muukii.app@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import FluidViewController
import SwiftUI
import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func onTapAnyLeft(_ sender: Any) {

    let controller = SampleViewController(behaviors: [.init(trigger: .any, startFrom: .left)])

    present(controller, animated: true, completion: nil)

  }

  @IBAction func onTapEdgeLeft(_ sender: Any) {

    let controller = SampleViewController(behaviors: [.init(trigger: .edge, startFrom: .left)])

    present(controller, animated: true, completion: nil)

  }
}

struct ContentView: View {

  var onTapDismiss: () -> Void
  var onTapPush: () -> Void
  var onTapPresent: () -> Void

  var body: some View {

    ZStack {

      Color.purple
        .edgesIgnoringSafeArea(.all)

      ScrollView(.vertical, showsIndicators: true) {
        VStack {

          Text("Good morning")

          Button("Dismiss") {
            onTapDismiss()
          }

          Button("Push") {
            onTapPush()
          }

          Button("Present") {
            onTapPresent()
          }

          ScrollView(.horizontal, showsIndicators: true) {
            HStack {
              ForEach(0..<30) { (i) in

                Rectangle()
                  .frame(width: 50, height: 50, alignment: .center)
                  .foregroundColor(.orange)

              }
            }
          }

          ForEach(0..<10) { i in
            Text("Section")
            ScrollView(.horizontal, showsIndicators: true) {
              HStack {
                ForEach(0..<30) { (i) in

                  Rectangle()
                    .frame(width: 100, height: 100, alignment: .center)
                    .foregroundColor(.orange)
                }
              }
            }
            .id(i)
          }

        }
      }

    }
  }

}
