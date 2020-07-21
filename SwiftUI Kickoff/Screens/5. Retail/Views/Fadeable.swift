//
//  Fadeable.swift
//  RetailDemo
//
//  Created by Stephen E. Cotner on 6/28/20.
//

import Foundation
import SwiftUI

struct Fadeable<Content>: View where Content : View {
    @State var isShowing: Bool = false
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .opacity(isShowing ? 1 : 0)
            .onDisappear() {
                withAnimation(Animation.linear(duration: 0.3)) {
                    self.isShowing = false
                }
        }
            .onAppear() {
                withAnimation(Animation.linear(duration: 0.3).delay(0.45)) {
                    self.isShowing = true
                }
        }
    }
}
