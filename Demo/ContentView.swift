//
// Copyright (c) 2021 Copyright (c) 2021 Eureka, Inc.
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

import SwiftUI

var count = 0

struct ContentView: View {

  enum Action {
    case dismiss
    case push
    case pushNavigationBar
    case pushInCurrentContext
    case present
    case presentInCurrentContext
    case makePresentationContext(Bool)
  }

  @State private var isPresentationContext = false

  var onAction: (Action) -> Void

  var body: some View {

    ZStack {

      Color(white: 1, opacity: 1)
        .edgesIgnoringSafeArea(.all)

      ScrollView(.vertical, showsIndicators: true) {
        VStack {

          Text("\(count)")
            .font(.title)

          Text("Good morning")

          Group {

            Button("Dismiss") {
              onAction(.dismiss)
            }

            Toggle.init(
              "Make PresentationContext",
              isOn: .init(
                get: {
                  isPresentationContext
                },
                set: { value in
                  onAction(.makePresentationContext(value))
                  isPresentationContext = value
                }
              )
            )

            Button("Push - FullScreen") {
              onAction(.push)
            }

            Button("Push - FullScreen - Navigation") {
              onAction(.pushNavigationBar)
            }

            Button("Push - CurrentContext") {
              onAction(.pushInCurrentContext)
            }

            Button("Present - FullScreen") {
              onAction(.present)
            }

            Button("Present - CurrentContext") {
              onAction(.presentInCurrentContext)
            }

          }
          .padding(.horizontal, 20)
          ScrollView(.horizontal, showsIndicators: true) {
            HStack {
              ForEach(0..<10) { (i) in

                Rectangle()
                  .frame(width: 50, height: 50, alignment: .center)
                  .foregroundColor(Color(white: 0.90, opacity: 1))

              }
            }
          }

          ForEach(0..<6) { i in
            Text("Section")
            ScrollView(.horizontal, showsIndicators: true) {
              HStack {
                ForEach(0..<10) { (i) in

                  Rectangle()
                    .frame(width: 100, height: 100, alignment: .center)
                    .foregroundColor(Color(white: 0.90, opacity: 1))
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
