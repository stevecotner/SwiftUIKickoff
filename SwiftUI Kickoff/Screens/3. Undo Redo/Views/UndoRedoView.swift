//
//  UndoRedoView.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/19/20.
//

import Poet
import SwiftUI

protocol Evaluating_UndoRedo : Evaluating where Self.Action : EvaluatorAction_UndoRedo {}

protocol EvaluatorAction_UndoRedo: EvaluatorAction {
    static var undo: Self { get }
    static var redo: Self { get }
}

struct UndoRedoView<E: Evaluating_UndoRedo>: View {
    let evaluator: E
    @Observed var hasUndoHistory: Bool
    @Observed var hasRedoHistory: Bool
    @Environment(\.operatingSystem) var operatingSystem: OperatingSystem
    var body: some View {
        HStack {
            Button(action: {
                evaluator.evaluate(.undo)
            }) {
                Image(systemName: "arrow.uturn.left")
                    .font(.subheadline)
                    .opacity(hasUndoHistory ? 1 : 0.2)
                    .frame(width: operatingSystem == .macOS ? 20 : 30, height: operatingSystem == .macOS ? 20 : 30)
                    
            }
            .buttonStyle(UndoRedoButtonStyle())
            .allowsHitTesting(hasUndoHistory)
            
            Spacer().frame(width: 24)
            
            Button(action: {
                evaluator.evaluate(.redo)
            }) {
                Image(systemName: "arrow.uturn.right")
                    .font(.subheadline)
                    .opacity(hasRedoHistory ? 1 : 0.2)
                    .frame(width: operatingSystem == .macOS ? 20 : 30, height: operatingSystem == .macOS ? 20 : 30)
            }
            .buttonStyle(UndoRedoButtonStyle())
            .allowsHitTesting(hasRedoHistory)
        }
    }
    
    struct UndoRedoButtonStyle: ButtonStyle {
        @Environment(\.operatingSystem) var operatingSystem: OperatingSystem
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .background(
                    Circle()
                        .size(width: operatingSystem == .macOS ? 20 : 30, height: operatingSystem == .macOS ? 20 : 30)
                        .fill(Color.black)
                        .opacity(configuration.isPressed ? 0.2 : 0.05)
                        .animation(.spring(response: 0.25, dampingFraction: 0.55, blendDuration: 0), value: configuration.isPressed)
                )
        }
    }
}
