//
//  ContentView.swift
//  GestureTester
//
//  Created by Tieme on 18/10/2024.
//

import SwiftUI

struct ContentView: View {
    struct ManipulationState: Equatable {
        var magnification: CGFloat?
        var rotation: Angle?
    }

    @State var rectangleWidth: CGFloat = 200.0
    @State var rectangleHeight: CGFloat = 200.0
    @State var rectangleRotation: CGFloat = 0

    @GestureState var state: ManipulationState? = nil

    var body: some View {
        Rectangle()
            .fill(.orange)
            .shadow(radius: 10)
            .frame(
                width: rectangleWidth * (state?.magnification ?? 1),
                height: rectangleHeight * (state?.magnification ?? 1)
            )
            .rotationEffect(.degrees(rectangleRotation + (state?.rotation?.degrees ?? 0)))
            .gesture(gesture)
            .onChange(of: state, { oldValue, newValue in
                if oldValue == nil, let newValue {
                    print("Gesture started nil -> (\(newValue))")
                }

                if let oldValue, let newValue {
                    print("Gesture updated (\(oldValue)) -> (\(newValue))")
                }

                if let oldValue, newValue == nil {
                    print("Gesture ended, (\(oldValue)) -> nil")
                    gestureDidEnd(state: oldValue)
                }
            })
    }

    var gesture: GestureStateGesture<SimultaneousGesture<RotateGesture, MagnifyGesture>, ManipulationState?> {
        SimultaneousGesture(
            RotateGesture(minimumAngleDelta: .degrees(5)),
            MagnifyGesture(minimumScaleDelta: 0.1)
        )
            .updating($state) { value, state, transaction in
                var rotation = value.first?.rotation
                if let radians = rotation?.radians, radians.isNormal != true {
                    print("Rotation is not normal? \(radians)")
                    rotation = nil
                }

                state = ManipulationState(
                    magnification: value.second?.magnification,
                    rotation: rotation
                )
            }
    }

    func gestureDidEnd(state: ManipulationState) {
        // Snap rectangle to 15 degrees
        if let rotation = state.rotation {
            let totalRotation = rectangleRotation + rotation.degrees
            rectangleRotation = totalRotation - totalRotation.remainder(dividingBy: 15)
        }

        if let magnification = state.magnification {
            rectangleWidth = rectangleWidth * magnification
            rectangleHeight = rectangleHeight * magnification
        }
    }
}

extension ContentView.ManipulationState: CustomStringConvertible {
    var description: String {
        [
            magnification.map { String(format: "magnify: %0.2f", $0) },
            rotation.map { String(format: "rotate: %0.2f", $0.degrees) }
        ].compactMap { $0 }.joined(separator: ", ")
    }
}
