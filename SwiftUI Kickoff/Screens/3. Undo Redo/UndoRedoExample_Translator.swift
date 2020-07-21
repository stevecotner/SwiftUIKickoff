//
//  UndoRedoExample_Translator.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/12/20.
//

import Combine
import Foundation
import Poet
import SwiftUI

extension UndoRedoExample {
    
    class Translator {
        
        typealias Evaluator = UndoRedoExample.Evaluator
        typealias State = Evaluator.State
        typealias Action = Evaluator.Action
        
        // Observable Display State
        @Observable var title: String?
        @Observable var instruction: String?
        @Observable var namedAction: NamedAction<Action>?
        @Observable var imageName: String?
        @Observable var imageColor: Color?
        @Observable var selectedButton: ButtonOption = .none
        @Observed var hasUndoHistory: Bool
        @Observed var hasRedoHistory: Bool
        
        enum ButtonOption {
            case a
            case b
            case c
            case none
        }
        
        // State Sink
        private var stateSink: AnyCancellable?
        
        init(_ state: Passable<State>, hasUndoHistory: Observed<Bool>, hasRedoHistory: Observed<Bool>) {
            _hasUndoHistory = hasUndoHistory
            _hasRedoHistory = hasRedoHistory
            stateSink = state.subject.sink { [weak self] value in
                if let value = value {
                    self?.translate(state: value)
                }
            }
        }
        
        deinit {
            debugPrint("deinit UndoRedoExample translator")
        }
    }
}

extension UndoRedoExample.Translator {
    func translate(state: State) {
        switch state {
            
        case .greeting(let state):
            translateGreetingState(state)
            
        case .counting(let state):
            translateCountingState(state)
            
        case .picture(let state):
            translatePictureState(state)
        }
    }
    
    func translateGreetingState(_ state: Evaluator.GreetingState) {
        title = "Greeting"
        instruction = "Tap the greeting to see another one."
        namedAction = state.namedAction
        imageName = nil
        withAnimation(.spring(response: 0.25, dampingFraction: 0.6, blendDuration: 0)) {
            selectedButton = .a
        }
    }
    
    func translateCountingState(_ state: Evaluator.CountingState) {
        title = "Counting"
        instruction = "Tap the number to increment the count."
        namedAction = NamedAction(name: String(state.count), action: state.action)
        imageName = nil
        withAnimation(.spring(response: 0.25, dampingFraction: 0.6, blendDuration: 0)) {
            selectedButton = .b
        }
    }
    
    func translatePictureState(_ state: Evaluator.PictureState) {
        title = "Picture"
        instruction = nil
        namedAction = NamedAction(name: "Change color", action: state.action)
        imageName = state.imageName
        imageColor = state.imageColor
        withAnimation(.spring(response: 0.25, dampingFraction: 0.6, blendDuration: 0)) {
            selectedButton = .c
        }
    }
}
