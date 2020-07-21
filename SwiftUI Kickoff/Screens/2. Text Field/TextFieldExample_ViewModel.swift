//
//  TextFieldExample_ViewModel.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/14/20.
//

import Combine
import Foundation
import Poet

extension TextFieldExample {
    
    class ViewModel {
        @Observable var namedAction: NamedAction<Action>?
        @Passable var passableText: String?
        
        enum Element: EvaluatorElement {
            case textField
        }
        
        deinit {
            debugPrint("deinit TextFieldExample viewmodel")
        }
    }
}

// Mark: Actions

extension TextFieldExample.ViewModel: Evaluating, Evaluating_TextField {
    enum Action: EvaluatorAction, EvaluatorAction_TextField {
        case _textFieldDidChange(text: String, elementName: EvaluatorElement)
        case typeHello
        
        // Xcode 12.0 beta 2:
        // Using static func here (instead of an enum case) avoids a crash. Swift 5.3 has a problem with its current implementation of enum cases as protocol witnesses. Strings passed in as arguments get freed from the heap prematurely if they are above a certain size.
        static func textFieldDidChange(text: String, elementName: EvaluatorElement) -> Self {
            return ._textFieldDidChange(text: text, elementName: elementName)
        }
    }
    
    func evaluate(_ action: Action?) {
        breadcrumb(action)
        
        switch action {
            
        // Text Field
            
        case ._textFieldDidChange(let text, let elementName):
            guard let elementName = elementName as? Element else { return }
            switch elementName {
            case .textField:
                print("text: \(text)")
            }
            
        case .typeHello:
            passableText = "Hello"
            
        case .none:
            break
        }
    }
    
    func test(_ string: String) {
        print("test string: \(string)")
    }
}
