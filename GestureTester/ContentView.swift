//
//  ContentView.swift
//  GestureTester
//
//  Created by Tieme on 18/10/2024.
//

import SwiftUI

struct Logo: Hashable {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var rotation: Double
}

struct ManipulationState: Equatable {
    var location: CGPoint?
    var magnification: Double?
    var rotation: Double?
}

typealias RotateMagnifyDragGesture = SimultaneousGesture<SimultaneousGesture<RotateGesture, MagnifyGesture>, DragGesture>

struct ContentView: View {
    @State var logo = Logo(
        x: UIScreen.main.bounds.width / 2,
        y: UIScreen.main.bounds.height / 2,
        width: 200,
        height: 200,
        rotation: 0
    )
    @GestureState var state: ManipulationState? = nil

    var body: some View {
        Image(uiImage: .swift)
            .resizable()
            .scaledToFit()
            .frame(
                width: logo.width * (state?.magnification ?? 1),
                height: logo.height * (state?.magnification ?? 1)
            )
            .rotationEffect(.degrees(logo.rotation + (state?.rotation ?? 0)))
            .position(
                x: state?.location.map { Double($0.x) } ?? logo.x,
                y: state?.location.map { Double($0.y) } ?? logo.y
            )
            .gesture(gesture(logo: logo))
            .onChange(of: state, { oldValue, newValue in
                if oldValue == nil {
                    print("Gesture started")
                }

                if let oldValue, newValue == nil {
                    print("Gesture ended")
                    gestureDidEnd(state: oldValue)
                }
            })
    }

    func gesture(logo: Logo) -> GestureStateGesture<RotateMagnifyDragGesture, ManipulationState?> {
        let rotationGesture = RotateGesture(minimumAngleDelta: .degrees(5))
        let magnifyGesture = MagnifyGesture(minimumScaleDelta: 0.1)
        let dragGesture = DragGesture(minimumDistance: 5)
        return rotationGesture
            .simultaneously(with: magnifyGesture)
            .simultaneously(with: dragGesture)
            .updating($state) { value, state, transaction in
                var rotation = value.first?.first?.rotation
                if let radians = rotation?.radians, radians.isNormal != true {
                    print("Rotation is not normal? \(radians)")
                    rotation = nil
                }

                state = ManipulationState(
                    location: value.second?.location,
                    magnification: value.first?.second.map { Double($0.magnification) },
                    rotation: rotation?.degrees
                )
            }
    }

    func gestureDidEnd(state: ManipulationState) {
        if let location = state.location {
            logo.x = location.x
            logo.y = location.y
        }

        // Snap logo to 15 degrees
        if let rotation = state.rotation {
            let totalRotation = logo.rotation + rotation
            logo.rotation = totalRotation - totalRotation.remainder(dividingBy: 15)
        }

        if let magnification = state.magnification {
            logo.width = logo.width * magnification
            logo.height = logo.height * magnification
        }
    }
}

extension ManipulationState: CustomStringConvertible {
    var description: String {
        [
            location.map { "location: \($0)" },
            magnification.map { "magnification: \($0)" },
            rotation.map { "rotation: \($0)" }
        ].compactMap { $0 }.joined(separator: ", ")
    }
}
