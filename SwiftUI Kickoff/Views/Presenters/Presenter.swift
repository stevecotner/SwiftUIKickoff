//
//  Presenter.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/18/20.
//

import Foundation
import Poet
import SwiftUI

struct Presenter<Content>: View where Content : View {
    let passablePlease: PassablePlease
    var content: () -> Content
    var shouldShowDismissButton: Bool
    @State var isShowing: Bool = false
    @Environment(\.operatingSystem) var operatingSystem: OperatingSystem
       
    init(_ passablePlease: PassablePlease, shouldShowDismissButton: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.passablePlease = passablePlease
        self.shouldShowDismissButton = shouldShowDismissButton
    }
    
    var body: some View {
        Spacer()
            .sheet(isPresented: self.$isShowing) {
                ZStack {
                    self.content()
                    if shouldShowDismissButton {
                        VStack {
                            DismissButton(orientation: .left)
                            Spacer()
                        }
                    }
                }
                    .frame(
                        minWidth: operatingSystem == .macOS ? 500 : nil,
                        minHeight: operatingSystem == .macOS ? 700 : nil
                    )
            }
            .onReceive(passablePlease.subject) { _ in
                self.isShowing = true
            }
    }
}

struct DismissButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let orientation: Orientation
    @Environment(\.operatingSystem) var operatingSystem: OperatingSystem

    enum Orientation {
        case left
        case right
        case none
    }
    
    init(orientation: Orientation) {
        self.orientation = orientation
    }
    
    var body: some View {
        HStack {
            if orientation == .right {
                Spacer()
            }
            Button(
                action: {
                    self.presentationMode.wrappedValue.dismiss()
            })
            {
                Image(systemName: "xmark")
                    .foregroundColor(Color.primary)
                    .font(Font.system(size: operatingSystem == .macOS ? 11 : 14, weight: .regular))
            }
            .buttonStyle(DismissButtonStyle())
            .padding(operatingSystem == .macOS ? 14 : 16)
            if orientation == .left {
                Spacer()
            }
        }
    }
    
    struct DismissButtonStyle: ButtonStyle {
        @Environment(\.operatingSystem) var operatingSystem: OperatingSystem
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(width: operatingSystem == .macOS ? 20 : 30, height: operatingSystem == .macOS ? 20 : 30)
                .background(
                    Capsule()
                        .fill(Color.black)
                        .opacity(configuration.isPressed ? 0.2 : 0.05)
                        .animation(.spring(response: 0.25, dampingFraction: 0.55, blendDuration: 0), value: configuration.isPressed)
                )
        }
    }
    
}
