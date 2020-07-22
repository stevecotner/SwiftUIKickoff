//
//  ObservingBottomButton.swift
//  RetailDemo
//
//  Created by Stephen E. Cotner on 6/28/20.
//

import Poet
import SwiftUI

struct ObservingBottomButton<E: Evaluating>: View {
    @Observed var namedDisableableAction: NamedDisableableAction<E.Action>?
    let evaluator: E?
    @ObservedObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        GeometryReader() { geometry in
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Button(action: {
                        self.evaluator?.evaluate(self.namedDisableableAction?.action)
                    }) {
                        
                        Text(
                            self.namedDisableableAction?.name ?? "")
                            .animation(.none)
                            .font(Font.headline)
                            .frame(width: geometry.size.width - 100)
                    }
                    .disabled(self.namedDisableableAction?.enabled == false)
                    .buttonStyle(BottomButtonStyle(background: .black))
                    Spacer(minLength: 0)
                }
            }
        }
        
        .opacity(
            self.namedDisableableAction?.action == nil ? 0 : 1
        )
        .modifier(OffsetForKeyboard(isActionNil: self.namedDisableableAction?.action == nil, keyboardHeight: self.keyboard.currentHeight))
    }
    
    struct OffsetForKeyboard: ViewModifier {
        let isActionNil: Bool
        let keyboardHeight: CGFloat
        
        func body(content: Content) -> some View {
            content
                .offset(x: 0, y: isActionNil ? 150 : -16)
                .offset(x: 0, y: -keyboardHeight)
                .animation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0), value: isActionNil)
                .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0), value: keyboardHeight == 0)
        }
    }
}

struct BottomButtonStyle: ButtonStyle {
    enum BackgroundConfiguration {
        case white
        case gray
        case black
        
        func backgroundColor(isPressed: Bool) -> Color {
            switch self {
            case .white:
                return Color.white.opacity(isPressed ? 0.35 : 1)
            case .gray:
                return Color.black.opacity(isPressed ? 0.08 : 0.05)
            case .black:
                return Color.black.opacity(isPressed ? 0.35 : 1)
            }
        }
        
        func foregroundColor(isPressed: Bool) -> Color {
            switch self {
            case .white:
                return Color.black.opacity(isPressed ? 0.25 : 1)
            case .gray:
                return Color.black.opacity(isPressed ? 0.25 : 1)
            case .black:
                return Color.white.opacity(isPressed ? 0.8 : 1)
            }
        }
    }
    
    let background: BackgroundConfiguration
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(
                background.foregroundColor(isPressed: configuration.isPressed)
        )
        .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18))
        .background(
            Capsule()
                .fill(
                    background.backgroundColor(isPressed: configuration.isPressed)
            )
                .opacity(1)
        )
    }
}
