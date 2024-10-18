//
//  ContentView.swift
//  GestureTester
//
//  Created by Tieme on 18/10/2024.
//

import SwiftUI

struct Logo: Hashable {
    var width: CGFloat
    var height: CGFloat
    var rotation: Double
}

struct ManipulationState: Equatable {
    var magnification: Double?
    var rotation: Double?
}

typealias RotateMagnifyGesture = SimultaneousGesture<RotateGesture, MagnifyGesture>

struct ContentView: View {
    @State var logo = Logo(
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
            .gesture(gesture(logo: logo))
            .onChange(of: state, { oldValue, newValue in
                if oldValue == nil, let newValue {
                    print("Gesture started \(newValue)")
                }

                if let oldValue, let newValue {
                    print("Gesture updated \(oldValue) -> \(newValue)")
                }

                if let oldValue, newValue == nil {
                    print("Gesture ended")
                    gestureDidEnd(state: oldValue)
                }
            })
    }

    func gesture(logo: Logo) -> GestureStateGesture<RotateMagnifyGesture, ManipulationState?> {
        let rotationGesture = RotateGesture(minimumAngleDelta: .degrees(5))
        let magnifyGesture = MagnifyGesture(minimumScaleDelta: 0.1)
        return rotationGesture
            .simultaneously(with: magnifyGesture)
            .updating($state) { value, state, transaction in
                var rotation = value.first?.rotation
                if let radians = rotation?.radians, radians.isNormal != true {
                    print("Rotation is not normal? \(radians)")
                    rotation = nil
                }

                state = ManipulationState(
                    magnification: value.second.map { Double($0.magnification) },
                    rotation: rotation?.degrees
                )
            }
    }

    func gestureDidEnd(state: ManipulationState) {
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
            magnification.map { String(format: "magnify: %0.2f", $0) },
            rotation.map { String(format: "rotate: %0.2f", $0) }
        ].compactMap { $0 }.joined(separator: ", ")
    }
}
