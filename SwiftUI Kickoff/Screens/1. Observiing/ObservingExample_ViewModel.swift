//
//  ObservingExample_ViewModel.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/13/20.
//

import Combine
import Foundation
import Poet

extension ObservingExample {
    
    class ViewModel {
        @Observable var namedAction: NamedAction<Action>?
        @Observable var feedback: String?
        
        deinit {
            debugPrint("deinit ExampleA viewmodel")
        }
    }
}

// Mark: Actions

extension ObservingExample.ViewModel: Evaluating, Evaluating_ViewCycle {
    enum Action: EvaluatorAction, EvaluatorAction_ViewCycle {
        case printHello
        case printHi
        case onAppear
        case onDisappear
    }
    
    func evaluate(_ action: Action?) {
        breadcrumb(action)
        
        switch action {
        
        case .printHello:
            printHello()
            
        case .printHi:
            printHi()
            
        // View Cycle
        
        case .onAppear:
            showInitialState()
            
        case .onDisappear:
            break
            
        case .none:
            break
        }
    }
    
    func showInitialState() {
        namedAction = NamedAction(name: "Hello", action: .printHello)
        feedback = "Tap the button to see a different greeting."
    }
    
    func printHello() {
        print("Hello")
        toggleAction()
    }
    
    func printHi() {
        print("Hi")
        toggleAction()
    }
    
    func toggleAction() {
        if namedAction?.action == .printHello {
            namedAction = NamedAction(name: "Hi", action: Action.printHi)
            feedback = "Now the button says “Hi.”"
        } else {
            namedAction = NamedAction(name: "Hello", action: Action.printHello)
            feedback = "Now it says “Hello.”"
        }
    }
    
}
