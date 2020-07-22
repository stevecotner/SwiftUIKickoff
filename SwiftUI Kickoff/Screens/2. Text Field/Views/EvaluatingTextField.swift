//
//  EvaluatingTextField.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/14/20.
//

import Combine
import Poet
import SwiftUI

protocol Evaluating_TextField: Evaluating where Action: EvaluatorAction_TextField {}

protocol EvaluatorAction_TextField: EvaluatorAction {
    static func textFieldDidChange(text: String, elementName: EvaluatorElement) -> Self
}

struct EvaluatingTextField<E: Evaluating_TextField>: View {
    private let evaluator: E
    @ObservedObject var text = Observable("")
    @Passable private var passableText: String? = ""
    private let placeholder: String
    private let elementName: EvaluatorElement
    
    var textSink: AnyCancellable?
    
    init(evaluator: E,
         placeholder: String,
         elementName: EvaluatorElement,
         initialText: String? = nil,
         passableText: Passable<String>? = nil) {
        self.evaluator = evaluator
        self.placeholder = placeholder
        self.elementName = elementName
        if let passableText = passableText {
            _passableText = passableText
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack(spacing: 10) {
                    TextField(placeholder, text: $text.wrappedValue)
                        .disableAutocorrection(true)
                        .onReceive(text.objectWillChange) {
                            evaluator.evaluate(.textFieldDidChange(text: text.wrappedValue, elementName: elementName))
                        }

                    TextFieldClearButton(text: _text.wrappedValue, passableText: $passableText)
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.primary.opacity(0.05))
                )
                .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 50))
            }
        }
        .padding(.bottom, 10)
        
        .onReceive(self.$passableText.subject) { (string) in
            if let string = string {
                self.text.wrappedValue = string
            }
        }
    }
}

struct TextFieldClearButton: View {
    @ObservedObject var text: Observable<String>
    var passableText: Passable<String>
    
    var body: some View {
        Button(action: {
            self.passableText.wrappedValue = ""
        }) {
            Image(systemName: "multiply.circle.fill")
                .resizable()
                .frame(width: 14, height: 14)
                .opacity((text.wrappedValue.isEmpty) ? 0 : 0.3)
                .foregroundColor(.primary)
        }
    }
}
