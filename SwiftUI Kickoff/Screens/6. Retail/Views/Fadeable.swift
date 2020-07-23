//
//  Fadeable.swift
//  RetailDemo
//
//  Created by Stephen E. Cotner on 6/28/20.
//

import Foundation
import SwiftUI

struct Fadeable<Content>: View where Content : View {
    var content: () -> Content
    var delay: Double
    @State private var isShowing: Bool = false
    
    init(delay: Double = 0.45, @ViewBuilder content: @escaping () -> Content) {
        self.delay = delay
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
                withAnimation(Animation.linear(duration: 0.3).delay(delay)) {
                    self.isShowing = true
                }
        }
    }
}
