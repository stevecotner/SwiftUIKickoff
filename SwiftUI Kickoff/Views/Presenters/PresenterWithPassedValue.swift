//
//  PresenterWithPassedValue.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/19/20.
//

import Poet
import SwiftUI

struct PresenterWithPassedValue<PassedType, Content>: View where Content : View {
    let passable: Passable<PassedType>
    var content: (PassedType) -> Content
    var shouldShowDismissButton: Bool
    @ObservedObject var passedValue = Observable<PassedType?>(nil)
    @State var isShowing = false
    @Environment(\.operatingSystem) var operatingSystem: OperatingSystem
    
    init(_ passable: Passable<PassedType>, shouldShowDismissButton: Bool = true, @ViewBuilder content: @escaping (PassedType) -> Content) {
        self.passable = passable
        self.content = content
        self.shouldShowDismissButton = shouldShowDismissButton
    }
    
    var body: some View {
        Spacer()
            .sheet(isPresented: self.$isShowing,
                   content: {
                    ZStack {
                        if let passedValue = self.passedValue.wrappedValue {
                            self.content(passedValue)
                        }
                        
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
                    .onDisappear {
                        self.passable.wrappedValue = nil
                        self.passedValue.wrappedValue = nil
                    }
                   }
            )
            
        .onReceive(passable.subject) { value in
            if let value = value {
                self.passedValue.wrappedValue = value
                self.isShowing = true
            }
        }
    }
}
