//
//  UndoRedoExample_Evaluator.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/12/20.
//

import Combine
import Foundation
import Poet
import SwiftUI

extension UndoRedoExample {
    class Evaluator {
        
        // Translator
        lazy var translator: Translator = Translator($state, hasUndoHistory: history.$hasUndoHistory, hasRedoHistory: history.$hasRedoHistory)
        
        // State
        @Passable var state: State?
        lazy var history = StateHistory($state)
        
        deinit {
            debugPrint("deinit UndoRedoExample evaluator")
        }
    }
}

// MARK: State

extension UndoRedoExample.Evaluator {
    enum State: EvaluatorState {
        case greeting(GreetingState)
        case counting(CountingState)
        case picture(PictureState)
    }
    
    struct GreetingState {
        var namedAction: NamedAction<Action>
    }
    
    struct CountingState {
        var count: Int
        var action: Action
    }
    
    struct PictureState {
        var imageName: String
        var imageColor: Color
        var action: Action
    }
}

// Mark: Actions

extension UndoRedoExample.Evaluator: Evaluating, Evaluating_ViewCycle, Evaluating_UndoRedo {
    enum Action: EvaluatorAction, EvaluatorAction_ViewCycle, EvaluatorAction_UndoRedo {
        // Greeting
        case showGreeting
        case printHello
        case printHi
        case printHey
        // Counting
        case showCounting
        case increment
        // Picture
        case showPicture
        case changePictureColor
        // View Cycle
        case onAppear
        case onDisappear
        // History
        case undo
        case redo
    }
    
    func evaluate(_ action: Action?) {
        breadcrumb(action)
        
        switch action {
        
        // Greeting
            
        case .showGreeting:
            showGreetingState()
            
        case .printHello:
            printHello()
            
        case .printHi:
            printHi()
            
        case .printHey:
            printHey()
            
        // Counting
            
        case .showCounting:
            showCountingState()
            
        case .increment:
            increment()
            
        // Picture
        
        case .showPicture:
            showPictureState()
            
        case .changePictureColor:
            changePictureColor()
            
        // View Cycle
        
        case .onAppear:
            showGreetingState()
            
        case .onDisappear:
            break
            
        // History
        
        case .undo:
            history.undo()
            
        case .redo:
            history.redo()
            
        case .none:
            break
        }
    }
    
    // MARK: Greeting
    
    func showGreetingState() {
        if case .greeting = state { return }
        
        let state = GreetingState(
            namedAction: NamedAction(name: "Hello", action: .printHello)
        )
        self.state = .greeting(state)
    }
    
    func printHello() {
        print("You tapped 'Hello'")
        toggleGreeting()
    }
    
    func printHi() {
        print("You tapped 'Hi'")
        toggleGreeting()
    }
    
    func printHey() {
        print("You tapped 'Hey'")
        toggleGreeting()
    }
    
    func toggleGreeting() {
        guard case let .greeting(state) = state else { return }
        
        var newAction: NamedAction<Action>
        
        if state.namedAction.action == .printHello {
            newAction = NamedAction(name: "Hi", action: Action.printHi)
        } else if state.namedAction.action == .printHi {
            newAction = NamedAction(name: "Hey", action: Action.printHey)
        } else {
            newAction = NamedAction(name: "Hello", action: Action.printHello)
        }
        
        let newState = GreetingState(
            namedAction: newAction
        )
        self.state = .greeting(newState)
    }
    
    // MARK: Counting
    
    func showCountingState() {
        if case .counting = state { return }
        
        let state = CountingState(
            count: 0,
            action: .increment
        )
        self.state = .counting(state)
    }
    
    func increment() {
        guard case var .counting(state) = state else { return }
        
        state.count += 1
        self.state = .counting(state)
    }
    
    // MARK: Picture
    
    func showPictureState() {
        if case .picture = state { return }
        
        let state = PictureState(
            imageName: "photo",
            imageColor: .blue,
            action: .changePictureColor
        )
        self.state = .picture(state)
    }
    
    func changePictureColor() {
        guard case var .picture(state) = state else { return }
        
        let colors: [Color] = [.red, .green, .blue, .yellow, .purple, .pink, .orange, .gray]
        
        var newColor: Color = state.imageColor
        while newColor == state.imageColor {
            newColor = colors.randomElement()!
        }
        
        state.imageColor = newColor
        self.state = .picture(state)
    }
}
