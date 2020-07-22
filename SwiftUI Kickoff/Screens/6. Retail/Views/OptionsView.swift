//
//  OptionsView.swift
//  Poet
//
//  Created by Stephen E. Cotner on 5/21/20.
//  Copyright © 2020 Steve Cotner. All rights reserved.
//

import Poet
import SwiftUI

protocol Evaluating_OptionToggling: Evaluating where Action: EvaluatorAction_OptionToggling {}

protocol EvaluatorAction_OptionToggling: EvaluatorAction {
    static func toggleOption(_ option: String) -> Self
}

struct OptionsView<E: Evaluating_OptionToggling>: View {
    @Observed var options: [String]
    @Observed var preference: String
    let evaluator: E
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(options, id: \.self) { option in
                VStack(alignment: .leading, spacing: 0) {
                    OptionView(option: option, preference: self.preference, evaluator: self.evaluator)
                    Spacer().frame(height: 16)
                }
            }
            Spacer().frame(height: 18)
        }
    }
}

struct OptionView<E: Evaluating_OptionToggling>: View {
    let option: String
    let preference: String
    let evaluator: E
    
    var body: some View {
        let isSelected = self.option == self.preference
        return Button(self.option) {
            self.evaluator.evaluate(.toggleOption(option))
        }
        .buttonStyle(OptionButtonStyle(isSelected: isSelected))
        .padding(0)
        .foregroundColor(.primary)
    }
}

struct OptionButtonStyle: ButtonStyle {
    let isSelected: Bool
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .opacity(.leastNonzeroMagnitude)
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: configuration.isPressed ? 23 : isSelected ? 25 : 24, height: configuration.isPressed ? 23 : isSelected ? 25 : 24)
                        .padding(EdgeInsets(top: configuration.isPressed ? 1 : isSelected ? 0 : 0.5, leading: configuration.isPressed ? 40 : isSelected ? 39 : 39.5, bottom: configuration.isPressed ? 1 : isSelected ? 0 : 0.5, trailing: 0))
                        .animation(.linear(duration: 0.1))

                    configuration.label
                        .font(Font.headline)
                        .layoutPriority(20)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(EdgeInsets(top: 0.5, leading: 76, bottom: 0, trailing: 76))
                }
                .foregroundColor(Color.primary.opacity(configuration.isPressed ? 0.3 : 1))
                
                Spacer()
            }
        }
    }
}
