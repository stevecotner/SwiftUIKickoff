//
//  TextField_Screen.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/14/20.
//

import Combine
import Poet
import SwiftUI

struct PassablesExample: MenuScreenPresentable {
    var title: String = "Passables"
    var description: String = "Showing alerts and bezels"
    var id: UUID = UUID()
    func screen() -> AnyView {
        return AnyView(Self.Screen())
    }
}

extension PassablesExample {
    struct Screen: View {
        
        let viewModel: ViewModel
        
        init() {
            viewModel = ViewModel()
        }
        
        var body: some View {
            ZStack {
                VStack(spacing: 16) {
                    
                    // Title
                    Text("Passables")
                        .font(.headline)
                    
                    Spacer().frame(height: 10)
                    
                    Group {
                        Button("Show Alert")
                        {
                            viewModel.evaluate(.showAlert)
                        }
                        
                        Button("Show Complicated Alert")
                        {
                            viewModel.evaluate(.showComplicatedAlert)
                        }
                        
                        Button("Show Emoji Bezel")
                        {
                            viewModel.evaluate(.showEmojiBezel)
                        }
                        
                        Button("Show Text Bezel")
                        {
                            viewModel.evaluate(.showTextBezel)
                        }
                    }
                    .buttonStyle(PillButtonStyle(background: .gray))
                    
                }
                
                AlertPresenter(viewModel.$alert)
                BezelPresenter(viewModel.$bezel)
            }
        }
    }
}

struct PassablesExampleScreen_Previews: PreviewProvider {
    static var previews: some View {
        PassablesExample.Screen()
    }
}

struct PillButtonStyle: ButtonStyle {
    enum BackgroundConfiguration {
        case white
        case gray
        case black
        case green
        
        func backgroundColor(isPressed: Bool) -> Color {
            switch self {
            case .white:
                return Color.white.opacity(isPressed ? 0.35 : 1)
            case .gray:
                return Color.black.opacity(isPressed ? 0.08 : 0.05)
            case .black:
                return Color.black.opacity(isPressed ? 0.35 : 1)
            case .green:
                return Color.green.opacity(isPressed ? 0.35 : 1)
            }
        }
        
        func foregroundColor(isPressed: Bool) -> Color {
            switch self {
            case .white:
                return Color.black.opacity(isPressed ? 0.5 : 1)
            case .gray:
                return Color.black.opacity(isPressed ? 0.7 : 1)
            case .black:
                return Color.white.opacity(isPressed ? 0.7 : 1)
            case .green:
                return Color.white.opacity(isPressed ? 0.7 : 1)
            }
        }
    }
    
    let background: BackgroundConfiguration
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(
                background.foregroundColor(isPressed: configuration.isPressed)
        )
        .padding(EdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 18))
        .background(
            Capsule()
                .fill(
                    background.backgroundColor(isPressed: configuration.isPressed)
            )
                .opacity(1)
        )
    }
}
