//
//  SelectableCapsuleButton.swift
//  Poet
//
//  Created by Stephen E. Cotner on 5/21/20.
//  Copyright © 2020 Steve Cotner. All rights reserved.
//

import SwiftUI

struct SelectableCapsuleButton: View {
    let title: String
    let isSelected: Bool
    let imageName: String
    let action: (() -> Void)?
    @Environment(\.operatingSystem) var operatingSystem: OperatingSystem
    
    var body: some View {
        return Button(action: { self.action?() }) {
            
            HStack(spacing: 0) {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.white) // systemBackground
                    .frame(
                        width: self.isSelected ? 12 : 0,
                        height: self.isSelected ? 12 : 0)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                    .animation( self.isSelected ? (.spring(response: 0.37, dampingFraction: 0.4, blendDuration: 0.825)) : .linear(duration: 0.2), value: self.isSelected)
                    .layoutPriority(0)
                Text(title)
                    .font(Font.system(.headline))
                    .foregroundColor( self.isSelected ? Color.white : .primary) // systemBackground
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(EdgeInsets(top: 10, leading: (isSelected ? 8 : 4), bottom: 10, trailing: 0))
                    .layoutPriority(2)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 22))
            .layoutPriority(1)
        }
        .buttonStyle(SelectableCapsuleButtonStyle(isSelected: isSelected))
        .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0), value: self.isSelected)
    }
}

struct SelectableCapsuleButtonStyle: ButtonStyle {
    let isSelected: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                AnyView(
                    Capsule()
                        .fill(Color.primary.opacity(configuration.isPressed ? 0.3 : self.isSelected ? 1 : 0.05))
                    )
            )
            
    }
}
