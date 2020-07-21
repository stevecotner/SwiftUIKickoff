//
//  BezelPresenter.swift
//  SwiftUI Kickoff
//
//  Created by Stephen E. Cotner on 7/21/20.
//

import Poet
import SwiftUI

struct BezelPresenter: View {
    @Passable var configuration: BezelConfiguration?
    
    init(_ configuration: Passable<BezelConfiguration>) {
        _configuration = configuration
    }
    
    var body: some View {
        BezelView($configuration)
    }
}

struct BezelView: View {
    
    @Passable var configuration: BezelConfiguration?
    
    @State private var text: String = ""
    @State private var textSize: BezelView.TextSize = .medium
    @State private var opacity: Double = 0
    
    init(_ configuration: Passable<BezelConfiguration>) {
        _configuration = configuration
    }
    
    enum TextSize: CGFloat {
        case small = 20
        case medium = 32
        case big = 128
    }
    
    enum Layout {
        static var fullOpacity = 1.0
        static var zeroOpacity = 0.0
        static var fadeInDuration = 0.125
        static var fadeOutWaitInMilliseconds = Int(fadeInDuration * 1000.0) + 700
        static var fadeOutDuration = 0.75
        
        static var verticalPadding: CGFloat = 30
        static var horizontalPadding: CGFloat = 38
        static var bezelCornerRadius: CGFloat = 10
        static var bezelBlurRadius: CGFloat = 12
    }
    
    var body: some View {
        VStack {
            VStack {
                
                // Note: this will only display text on a single line unless the text contains line breaks
                
                Text(text)
                    .font(Font.system(size: textSize.rawValue))
                    .padding(EdgeInsets(
                        top: Layout.verticalPadding,
                        leading: Layout.horizontalPadding,
                        bottom: Layout.verticalPadding,
                        trailing: Layout.horizontalPadding))
                    .frame(minWidth: .zero, maxWidth: 340, minHeight: .zero, maxHeight: 340)
                    .fixedSize(horizontal: true, vertical: true)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.95)) // systemBackground
                        .padding(10)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.primary.opacity(0.12))
                        .padding(10)
                    .mask(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .padding(10)
                            .opacity(0.95)
                    )
                }
                
            )
        }
        .opacity(opacity)
            .onReceive($configuration.subject) { (configuration) in
                if let configuration = configuration {
                    text = configuration.text
                    textSize = configuration.textSize
                    
                    withAnimation(.linear(duration: Layout.fadeInDuration)) {
                        self.opacity = Layout.fullOpacity
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(Layout.fadeOutWaitInMilliseconds))) {
                        withAnimation(.linear(duration: Layout.fadeOutDuration)) {
                            self.opacity = Layout.zeroOpacity
                        }
                    }
                }
        }
        .allowsHitTesting(false)
    }
}

struct BezelConfiguration {
    var text: String
    var textSize: BezelView.TextSize
}
