import SwiftUI

struct ContentView: View {

  enum Action {
    case dismiss
    case push
    case pushInCurrentContext
    case present
    case presentInCurrentContext
    case makePresentationContext(Bool)
  }

  @State private var isPresentationContext = false

  var onAction: (Action) -> Void

  var body: some View {

    ZStack {

      Color(white: 0.95, opacity: 1)
        .edgesIgnoringSafeArea(.all)

      ScrollView(.vertical, showsIndicators: true) {
        VStack {

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
              ForEach(0..<30) { (i) in

                Rectangle()
                  .frame(width: 50, height: 50, alignment: .center)
                  .foregroundColor(Color(white: 0.90, opacity: 1))

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
