//
//  Login-Screen.swift
//  Poet
//
//  Created by Stephen E. Cotner on 5/28/20.
//  Copyright © 2020 Steve Cotner. All rights reserved.
//

import Poet
import SwiftUI

struct LoginExample: MenuScreenPresentable {
    var title: String = "Login"
    var description: String = "Text Validation. Networking. Busy Indicator. Testing."
    var id: UUID = UUID()
    func screen() -> AnyView {
        return AnyView(Self.Screen())
    }
}

extension LoginExample {
    struct Screen: View {
        
        typealias Action = Evaluator.Action
        
        let evaluator: Evaluator
        let translator: Translator
        
        init() {
            evaluator = Evaluator()
            translator = evaluator.translator
        }
        
        @State var navBarHidden: Bool = true
        
        var body: some View {
            ZStack {
                VStack(spacing: 0) {
                    Text("Login")
                        .font(Font.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 22)

                    Spacer().frame(height: 36)
                    
                    VStack {
                        
                        // Username Text Field
                        ValidatingTextField(
                            evaluator: evaluator,
                            placeholder: "Username",
                            elementName: Evaluator.Element.usernameTextField,
                            passableText: translator.$passableUsername,
                            isSecure: false,
                            validation: translator.$usernameValidation
                        )
                        
                        // Password Text Field
                        ValidatingTextField(
                            evaluator: evaluator,
                            placeholder: "Password",
                            elementName: Evaluator.Element.passwordTextField,
                            passableText: translator.$passablePassword,
                            isSecure: true,
                            validation: translator.$passwordValidation
                        )
                        
                        Spacer().frame(height: 20)
                        
                        Button("Use Correct Credentials") {
                            self.evaluator.evaluate(Action.useCorrectCredentials)
                        }
                        .buttonStyle(PillButtonStyle(background: .green))
                    }.animation(.linear)
                    
                    Spacer()
                    
                    // Bottom Button
                    ObservingBottomButton(namedDisableableAction: self.translator.$bottomButtonAction, evaluator: evaluator)
                }
                
                AlertPresenter(translator.$alert)
                BusyPresenter(translator.$busy)
            }.onAppear {
                self.evaluator.evaluate(.onAppear)
            }
                
        }
    }
}
