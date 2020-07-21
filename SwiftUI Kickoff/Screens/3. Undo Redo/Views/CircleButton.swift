//
//  CircleButton.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/19/20.
//

import Poet
import SwiftUI

struct CircleButton: View {
    let title: String
    @Observable var isSelected: Bool = false
    var action: () -> Void = {}
    
    init(_ title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(title, action: action)
        .font(Font.subheadline.bold())
        .buttonStyle(CircleButtonStyle(isSelected: $isSelected))
    }
    
    struct CircleButtonStyle: ButtonStyle {
        @Observed var isSelected: Bool
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(width: 40, height: 40)
                .foregroundColor(isSelected ? Color.white : .primary )
                .background(
                    Capsule()
                        .fill(Color.black)
                        .padding(configuration.isPressed ? 3.5 : isSelected ? 0 : 2)
                        .opacity(configuration.isPressed ? 0.25 : isSelected ? 1 : 0.04)
                        .animation(.spring(response: 0.25, dampingFraction: 0.6, blendDuration: 0), value: configuration.isPressed)
                )
        }
    }
}
