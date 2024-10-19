import SwiftUI

struct Model: Equatable {
    var rotation: Angle = .zero
    var magnification: CGFloat = 1.0
}

struct ContentView: View {
    @GestureState private var gestureState = Model()

    var simultaneousGesture: some Gesture {
        SimultaneousGesture(
            RotateGesture(minimumAngleDelta: .degrees(5)),
            MagnifyGesture(minimumScaleDelta: 0.1)
        )
        .updating($gestureState) { value, state, _ in
            if let rotation = value.first {
                state.rotation = rotation.rotation
            }
            if let magnification = value.second {
                state.magnification = magnification.magnification
            }
        }
        .onChanged { value in
            if let rotation = value.first?.rotation {
                print("Rotation onChange: \(rotation.degrees) degrees")
            }
            if let magnification = value.second?.magnification {
                print("Magnification onChange: \(magnification)")
            }

        }
        .onEnded { value in
            if let rotation = value.first?.rotation {
                print("Rotation ended at: \(rotation.degrees) degrees")
            }
            if let magnification = value.second?.magnification {
                print("Magnification ended at: \(magnification)")
            }
        }
    }

    var body: some View {
        Rectangle()
            .fill(Color.orange)
            .frame(width: 200, height: 200)
            .shadow(radius: 10)
            .scaleEffect(gestureState.magnification)
            .rotationEffect(gestureState.rotation)
            .gesture(simultaneousGesture)
            .onChange(of: gestureState) {
                print(gestureState)
            }
    }
}
