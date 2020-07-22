//
//  Login-Translator.swift
//  Poet
//
//  Created by Stephen E. Cotner on 5/28/20.
//  Copyright © 2020 Steve Cotner. All rights reserved.
//

import Combine
import Poet
import SwiftUI

extension LoginExample {

    class Translator {
        
        typealias Evaluator = LoginExample.Evaluator
        typealias Action = Evaluator.Action
        typealias State = Evaluator.State
        
        // Observable Display State
        @Observable var usernameValidation: TextValidation = TextValidation([])
        @Observable var passwordValidation: TextValidation = TextValidation([])
        @Observable var bottomButtonAction: NamedDisableableAction<Action>?
        
        // Passable State
        @Passable var alert: AlertConfiguration?
        @Passable var passableUsername: String?
        @Passable var passablePassword: String?
        @Passable var busy: Bool?
        
        // Passthrough Behavior
        private var stateSink: AnyCancellable?
        
        init(_ state: Passable<State>) {
            stateSink = state.subject.sink { [weak self] value in
                if let value = value {
                    self?.translate(state: value)
                }
            }
        }
    }
}

extension LoginExample.Translator {
    func translate(state: State) {
        switch state {
            
        case .login(let state):
            translateLogin(state)
        }
    }
    
    func translateLogin(_ state: Evaluator.LoginState) {
        // Set observable display state
        usernameValidation = state.usernameValidation
        passwordValidation = state.passwordValidation
        
        let enabled = state.usernameValidation.isValid && state.passwordValidation.isValid
        
        withAnimation(Animation.linear.delay(0.25)) {
            bottomButtonAction = NamedDisableableAction(name: "Sign in", enabled: enabled, action: Action.signIn)
        }
    }
}
