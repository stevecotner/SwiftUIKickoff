//
//  Login-Evaluator.swift
//  Poet
//
//  Created by Stephen E. Cotner on 5/28/20.
//  Copyright © 2020 Steve Cotner. All rights reserved.
//

import Combine
import Poet
import SwiftUI

extension LoginExample {
    class Evaluator {
        
        // Translator
        lazy var translator: Translator = Translator($state)
        var performer: LoginPerforming = Performer()
        
        // Current State
        @Passable var state: State?
        
        // Sink
        var loginSink: AnyCancellable?
        
        enum Element: EvaluatorElement {
            case usernameTextField
            case passwordTextField
        }
    }
}

// MARK: State

extension LoginExample.Evaluator {
    enum State: EvaluatorState {
        case login(LoginState)
    }
    
    struct LoginState {
        var enteredUsername: String
        var usernameValidation: TextValidation
        var enteredPassword: String
        var passwordValidation: TextValidation
    }
}

// MARK: Actions

extension LoginExample.Evaluator: Evaluating, Evaluating_ViewCycle, Evaluating_TextField {
    enum Action: EvaluatorAction, EvaluatorAction_ViewCycle, EvaluatorAction_TextField {
        case onAppear
        case onDisappear
        case signIn
        case useCorrectCredentials
        case _textFieldDidChange(text: String, elementName: EvaluatorElement)
        
        static func textFieldDidChange(text: String, elementName: EvaluatorElement) -> Self {
            return ._textFieldDidChange(text: text, elementName: elementName)
        }
    }
    
    func evaluate(_ action: Action?) {
        breadcrumb(action)
        
        switch action {
        
        case .onAppear:
            showLogin()
            
        case .onDisappear:
            break
            
        case .signIn:
            signIn()
            
        case .useCorrectCredentials:
            useCorrectCredentials()
            
        case ._textFieldDidChange(let text, let elementName):
            textFieldDidChange(text: text, elementName: elementName)
            
        case .none:
            break
        }
    }
    
    func showLogin() {
        let state = LoginState(
            enteredUsername: "",
            usernameValidation: usernameValidation(),
            enteredPassword: "",
            passwordValidation: passwordValidation()
        )
        self.state = .login(state)
    }
    
    private func signIn() {
        guard case let .login(currentState) = state else { return }
        
        #if os(iOS)
        UIApplication.shared.endEditing()
        #elseif os(macOS)
        NSApplication.shared.endEditing()
        #endif
        
        self.translator.busy = true
        
        loginSink = performer.login(
            username: currentState.enteredUsername,
            password: currentState.enteredPassword
            )?.sink(receiveCompletion: { (completion) in
                
            switch completion {
                
            case .failure(let error):
                self.showLoginFailureAlert(with: error)
                
            case .finished:
                break
            }
            
            self.translator.busy = false
            self.loginSink?.cancel()
            
        }, receiveValue: { (authenticationResult) in
            self.showLoginSucceededAlert(with: authenticationResult)
        })
    }
    
    private func useCorrectCredentials() {
        translator.username = "postman"
        translator.password = "password"
    }

    // MARK: Text Field Evaluating

    func textFieldDidChange(text: String, elementName: EvaluatorElement) {
        guard case var .login(state) = state else { return }
        
        if let elementName = elementName as? Element {
            switch elementName {
                
            case .usernameTextField:
                state.enteredUsername = text
                state.usernameValidation.validate(text: text)
                
            case .passwordTextField:
                state.enteredPassword = text
                state.passwordValidation.validate(text: text)
            }
            
            self.state = .login(state)
        }
    }
    
    // MARK: Validating
    
    func usernameValidation() -> TextValidation {
        return TextValidation([
            lengthCondition(5),
            specialCharacterCondition(["=", ",", "\"", "'", "\\", "?", "!", "%"])
        ])
    }
    
    func passwordValidation() -> TextValidation {
        return TextValidation([
            lengthCondition(6),
            specialCharacterCondition(["=", ",", ".", "\"", "'", "\\", "@"])
        ])
    }
    
    func lengthCondition(_ length: Int) -> TextValidation.Condition {
        return TextValidation.Condition(message: "Must be at least \(length) characters long") {
            return $0.count >= length
        }
    }
    
    func specialCharacterCondition(_ badCharacters: [String]) -> TextValidation.Condition {
        return TextValidation.Condition(message: "No special characters: \(badCharacters.joined(separator: " "))") {
            let splitString = Array($0).map { String($0) }
            return splitString.contains(where: badCharacters.contains) == false
        }
    }

    // MARK: Handling Login Success and Failure
    
    private func showLoginSucceededAlert(with authenticationResult: AuthenticationResult) {
        translator.alert = AlertConfiguration(
            title: "Login Succeeded!",
            message:
            """
            Authenticated: \(authenticationResult.authenticated)
            """
        )
    }
    
    private func showLoginFailureAlert(with networkingError: NetworkingError) {
        var message = networkingError.shortName
        
        switch networkingError {
        case .unauthorized:
            message.append("\n\nCheck that you've entered your username and password correctly.")
        default:
            break
        }
        
        translator.alert = AlertConfiguration(
            title: "Login Failed",
            message: message
        )
    }
}

#if os(iOS)
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

#if os(macOS)
extension NSApplication {
    func endEditing() {
        sendAction(#selector(NSResponder.resignFirstResponder), to: nil, from: nil)
    }
}
#endif
