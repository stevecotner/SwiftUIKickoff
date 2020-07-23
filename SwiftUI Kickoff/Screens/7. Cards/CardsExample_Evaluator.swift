//
//  CardsExample_Evaluator.swift
//  SwiftUI Kickoff
//
//  Created by Stephen E. Cotner on 7/22/20.
//

import Poet
import SwiftUI

extension CardsExample {
    class Evaluator {
        
        // Translator
        lazy var translator: Translator = Translator($state)
        
        // Current State
        @Passable var state: State?
        
        struct Task: EvaluatorData {
            var customerName: String
            var taskID: String
            var status: TaskStatus
            
            enum TaskStatus {
                case readyToPick
                case readyToPack
                case packed
                case shipped
            }
        }
        
        let initialTasks = [
            Task(customerName: "Alan", taskID: UUID().uuidString, status: .readyToPick),
            Task(customerName: "Bob", taskID: UUID().uuidString, status: .readyToPick),
            Task(customerName: "Chuck", taskID: UUID().uuidString, status: .readyToPick),
            Task(customerName: "Dave", taskID: UUID().uuidString, status: .readyToPick),
            Task(customerName: "Eric", taskID: UUID().uuidString, status: .readyToPick),
            Task(customerName: "Frank", taskID: UUID().uuidString, status: .readyToPack),
            Task(customerName: "George", taskID: UUID().uuidString, status: .readyToPack),
            Task(customerName: "Harvey", taskID: UUID().uuidString, status: .readyToPack),
            Task(customerName: "Iriving", taskID: UUID().uuidString, status: .readyToPick),
            Task(customerName: "John", taskID: UUID().uuidString, status: .readyToPack),
            Task(customerName: "Kyle", taskID: UUID().uuidString, status: .readyToPick),
            Task(customerName: "Larry", taskID: UUID().uuidString, status: .readyToPack),
            Task(customerName: "Mark", taskID: UUID().uuidString, status: .readyToPack),
            Task(customerName: "Niles", taskID: UUID().uuidString, status: .readyToPack),
            Task(customerName: "Olaf", taskID: UUID().uuidString, status: .readyToPick),
            Task(customerName: "Peter", taskID: UUID().uuidString, status: .readyToPick),
            Task(customerName: "Quincy", taskID: UUID().uuidString, status: .readyToPick),
            Task(customerName: "Reggie", taskID: UUID().uuidString, status: .readyToPack),
        ]
    }
}

// MARK: State

extension CardsExample.Evaluator {
    enum State: EvaluatorState {
        case listTasks(ListTasksState)
    }
    
    struct ListTasksState {
        var pickTasks: [Task]
        var packTasks: [Task]
        var packedTasks: [Task]
        var shippedTasks: [Task]
        var spreadDeck: DeckName?
        var allTasks: [Task] {
            return pickTasks + packTasks + packedTasks + shippedTasks
        }
    }
    
    enum DeckName: EvaluatorElement {
        case pickDeck
        case packDeck
        case packedDeck
        case shippedDeck
    }
}

// Mark: Actions

extension CardsExample.Evaluator: Evaluating, Evaluating_ViewCycle, Evaluating_Card {
    enum Action: EvaluatorAction, EvaluatorAction_ViewCycle, EvaluatorAction_Card {
        case onAppear
        case onDisappear
        case spreadDeck(deckName: EvaluatorElement)
        case stackDeck(deckName: EvaluatorElement)
        case _selectItem(data: EvaluatorData)
        
        static func selectItem(data: EvaluatorData) -> CardsExample.Evaluator.Action {
            _selectItem(data: data)
        }
    }
    
    func evaluate(_ action: Action?) {
        switch action {
        case .onAppear:
            showInitialListTasksState()
            
        case .onDisappear:
            break
            
        case .spreadDeck(let deckName):
            spreadDeck(deckName)
            
        case .stackDeck(let deckName):
            stackDeck(deckName)
            
        case ._selectItem(let data):
            selectItem(data)
            
        case .none:
            break
        }
    }
    
    func showInitialListTasksState() {
        let (pickTasks, packTasks, packedTasks, shippedTasks) = sortTasks(initialTasks)

        let state = ListTasksState(
            pickTasks: pickTasks,
            packTasks: packTasks,
            packedTasks: packedTasks,
            shippedTasks: shippedTasks,
            spreadDeck: nil
        )
        self.state = .listTasks(state)
    }
    
    func sortTasks(_ tasks: [Task]) -> (pickTasks: [Task], packTasks: [Task], packedTasks: [Task], shippedTasks: [Task]) {
        let pickTasks = tasks.filter { $0.status == .readyToPick }
        let packTasks = tasks.filter { $0.status == .readyToPack }
        let packedTasks = tasks.filter { $0.status == .packed }
        let shippedTasks = tasks.filter { $0.status == .shipped }
        return (pickTasks, packTasks, packedTasks, shippedTasks)
    }
    
    // MARK: Card Evaluating
    
    func spreadDeck(_ deckName: EvaluatorElement) {
        guard case var .listTasks(state) = state, let deckName = deckName as? DeckName else { return }

        state.spreadDeck = deckName
        self.state = .listTasks(state)
        self.translator.focusedCard = self.firstCard(in: deckName)
    }
    
    func stackDeck(_ deckName: EvaluatorElement) {
        guard case var .listTasks(state) = state, let deckName = deckName as? DeckName else { return }
        
        state.spreadDeck = nil
        self.state = .listTasks(state)
        afterWait(200) {
            self.translator.focusedCard = self.firstCard(in: deckName)
        }
    }
    
    /** Returns the ID of the first card in the specified deck. */
    func firstCard(in deckName: DeckName) -> String? {
        guard case let .listTasks(state) = state else { return nil }
        
        switch deckName {
        case .pickDeck:
            return state.pickTasks.first?.taskID
        case .packDeck:
            return state.packTasks.first?.taskID
        case .packedDeck:
            return state.packedTasks.first?.taskID
        case .shippedDeck:
            return state.shippedTasks.first?.taskID
        }
    }
    
    func selectItem(_ data: EvaluatorData) {
        guard let task = data as? Task else { return }
        
        switch task.status {
        case .readyToPick:
            markAsPicked(task)
        case .readyToPack:
            markAsPacked(task)
        case .packed:
            markAsShipped(task)
        case .shipped:
            translator.alert = AlertConfiguration(title: "You're all set!", message: "This order is already complete.")
        }
    }
    
    // MARK: Marking Orders
    
    func markAsPicked(_ task: Task) {
        guard case var .listTasks(state) = state else { return }
        
        var tasks: [Task] = []
        state.allTasks.forEach {
            if $0.taskID == task.taskID {
                tasks.append(Task(customerName: $0.customerName, taskID: $0.taskID, status: .readyToPack))
            } else {
                tasks.append($0)
            }
        }
        let (pick, pack, packed, shipped) = sortTasks(tasks)
        state.pickTasks = pick
        state.packTasks = pack
        state.packedTasks = packed
        state.shippedTasks = shipped
        self.state = .listTasks(state)
    }
    
    func markAsPacked(_ task: Task) {
        guard case var .listTasks(state) = state else { return }
        
        var tasks: [Task] = []
        state.allTasks.forEach {
            if $0.taskID == task.taskID {
                tasks.append(Task(customerName: $0.customerName, taskID: $0.taskID, status: .packed))
            } else {
                tasks.append($0)
            }
        }
        let (pick, pack, packed, shipped) = sortTasks(tasks)
        state.pickTasks = pick
        state.packTasks = pack
        state.packedTasks = packed
        state.shippedTasks = shipped
        self.state = .listTasks(state)
    }
    
    func markAsShipped(_ task: Task) {
        guard case var .listTasks(state) = state else { return }
        
        var tasks: [Task] = []
        state.allTasks.forEach {
            if $0.taskID == task.taskID {
                tasks.append(Task(customerName: $0.customerName, taskID: $0.taskID, status: .shipped))
            } else {
                tasks.append($0)
            }
        }
        let (pick, pack, packed, shipped) = sortTasks(tasks)
        state.pickTasks = pick
        state.packTasks = pack
        state.packedTasks = packed
        state.shippedTasks = shipped
        self.state = .listTasks(state)
    }
}

protocol EvaluatorData {}
