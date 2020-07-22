//
//  ValidatingTextField.swift
//  SwiftUI Kickoff
//
//  Created by Stephen E. Cotner on 7/21/20.
//

import Combine
import Poet
import SwiftUI

struct ValidatingTextField<E: Evaluating_TextField>: View {
    private let evaluator: E
    @ObservedObject var text = Observable("")
    @Passable private var passableText: String? = ""
    private let placeholder: String
    private let elementName: EvaluatorElement
    private let isSecure: Bool
    private let keyboardType: KeyboardType
    @Observed var validation: TextValidation
    
    // Internal state
    @State private var shouldShowValidationMessage = false
    @State private var shouldShowValidationMark = false
    @State private var shouldShowCheckmark = false
    @State private var shouldShowExclamationMark = false
    
    private let validIconImageName: String = "checkmark.circle"
    private let invalidIconImageName: String = "exclamationmark.circle"
    private let validColor: Color = Color.green // systemGreen
    private let invalidColor: Color = Color.red // systemRed
    
    enum KeyboardType {
        case defaultKeyboard
        case numberKeyboard
    }
    
    init(evaluator: E,
         placeholder: String,
         elementName: EvaluatorElement,
         initialText: String? = nil,
         passableText: Passable<String>? = nil,
         isSecure: Bool,
         keyboardType: KeyboardType = .defaultKeyboard,
         validation: Observed<TextValidation>)
    {
        self.evaluator = evaluator
        self.placeholder = placeholder
        self.elementName = elementName
        if let passableText = passableText {
            _passableText = passableText
        }
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        _validation = validation
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack(spacing: 10) {
                    if isSecure {
                        SecureField(placeholder, text: $text.wrappedValue)
                            .disableAutocorrection(true)
                            .keyboardType(
                                {
                                    switch keyboardType {
                                    case .numberKeyboard:
                                        return .decimalPad
                                    case .defaultKeyboard:
                                        return .default
                                    }
                                }()
                            )
                    } else {
                        TextField(placeholder, text: $text.wrappedValue)
                            .disableAutocorrection(true)
                            .keyboardType(
                                {
                                    switch keyboardType {
                                    case .numberKeyboard:
                                        return .decimalPad
                                    case .defaultKeyboard:
                                        return .default
                                    }
                                }()
                            )
                    }

                    TextFieldClearButton(text: _text.wrappedValue, passableText: _passableText)
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.primary.opacity(0.05))
                )
                .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 50))
                .onReceive(text.objectWillChange) {
                    evaluator.evaluate(.textFieldDidChange(text: text.wrappedValue, elementName: elementName))
                }
                
                HStack {
                    Spacer()
                    ZStack {
                        
                        if shouldShowCheckmark {
                            Image(systemName: validIconImageName)
                                .resizable()
                                .opacity(shouldShowCheckmark ? 1 : 0)
                                .frame(width: shouldShowCheckmark ? 21 : 15, height: shouldShowCheckmark ? 21 : 15)
                                .animation(.spring(response: 0.1, dampingFraction: 0.6, blendDuration: 0), value: shouldShowCheckmark)
                                .foregroundColor(validColor)
                        }
                        
                        if shouldShowExclamationMark {
                            Image(systemName: invalidIconImageName)
                                .resizable()
                                .opacity(shouldShowExclamationMark ? 1 : 0)
                                .frame(width: shouldShowExclamationMark ? 21 : 15, height: shouldShowExclamationMark ? 21 : 15)
                                .animation(.spring(response: 0.1, dampingFraction: 0.6, blendDuration: 0), value: shouldShowExclamationMark)
                                .foregroundColor(invalidColor)
                        }
                            
                        EmptyView()
                    }
                    
                    .frame(width: 21, height: 21)
                    Spacer().frame(width:20)
                }
            }
            
            HStack {
                Spacer().frame(width: 50)
                Group {
                    if shouldShowValidationMessage {
                        Text(validation.message)
                            .font(Font.caption.bold())
                            .foregroundColor(invalidColor)
                            .fixedSize(horizontal: true, vertical: true)
                            .padding(.top, 10)
                            .animation(.none)
                            .transition(.opacity)
                    }
                }
                .animation(.linear)
                Spacer()
            }
        }
        .padding(.bottom, 10)
        
        .onReceive(text.objectDidChange.debounce(for: 0.4, scheduler: DispatchQueue.main)) {
            let isValid = validation.isValid
            if self.text.wrappedValue.isEmpty {
                self.shouldShowValidationMessage = false
                self.shouldShowValidationMark = false
                self.shouldShowCheckmark = false
                self.shouldShowExclamationMark = false
                return
            }
            self.shouldShowValidationMark = true
            self.shouldShowValidationMessage = (isValid == false)
            self.shouldShowCheckmark = isValid
            self.shouldShowExclamationMark = (isValid == false)
        }
        
        .onReceive(self.$passableText.subject) { (string) in
            if let string = string {
                self.text.wrappedValue = string
            }
        }
    }
}
