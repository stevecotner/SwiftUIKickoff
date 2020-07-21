//
//  DismissReceiver.swift
//  RetailDemo
//
//  Created by Stephen E. Cotner on 6/28/20.
//

import Poet
import SwiftUI

struct DismissReceiver: View {
    var passablePlease: PassablePlease
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    init(_ passablePlease: PassablePlease) {
        self.passablePlease = passablePlease
    }
    
    var body: some View {
        Spacer().frame(width: .leastNonzeroMagnitude, height: .leastNonzeroMagnitude)
            .onReceive(passablePlease.subject) { _ in
                self.presentationMode.wrappedValue.dismiss()
            }
    }
}
