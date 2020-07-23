//
//  CardsExample_Translator.swift
//  SwiftUI Kickoff
//
//  Created by Stephen E. Cotner on 7/22/20.
//

import Combine
import Poet
import SwiftUI

extension CardsExample {
    
    class Translator {
        
        typealias Evaluator = CardsExample.Evaluator
        typealias State = Evaluator.State
        typealias DeckName = Evaluator.DeckName
        
        // Observable Display State
        @Observable var title: String?
        @Observable var pickDeck: DeckConfiguration?
        @Observable var packDeck: DeckConfiguration?
        @Observable var packedDeck: DeckConfiguration?
        @Observable var shippedDeck: DeckConfiguration?
        @Observable var isSpread: Bool = false
        @Passable var focusedCard: String?
        @Passable var alert: AlertConfiguration?
        
        // State Sink
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

extension CardsExample.Translator {
    func translate(state: State) {
        switch state {
            
        case .listTasks(let state):
            translateListTasksState(state)
        }
    }
    
    func translateListTasksState(_ state: Evaluator.ListTasksState) {
        title = "Tasks"
        
        let pickCards: [CardConfiguration] = state.pickTasks.map {
            CardConfiguration(title: $0.customerName, body: $0.taskID, height: 140, id: $0.taskID, data: $0)
        }
        
        let packCards: [CardConfiguration] = state.packTasks.map {
            CardConfiguration(title: $0.customerName, body: $0.taskID, height: 140, id: $0.taskID, data: $0)
        }
        
        let packedCards: [CardConfiguration] = state.packedTasks.map {
            CardConfiguration(title: $0.customerName, body: $0.taskID, height: 140, id: $0.taskID, data: $0)
        }
        
        let shippedCards: [CardConfiguration] = state.shippedTasks.map {
            CardConfiguration(title: $0.customerName, body: $0.taskID, height: 140, id: $0.taskID, data: $0)
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
            pickDeck = deck(title: "Read to Pick",
                            cards: pickCards,
                            emptyMessage: "All caught up! No more orders to pick.",
                            instruction: "Tap an order to mark it as picked.",
                            deckName: .pickDeck,
                            spreadDeck: state.spreadDeck)
            
            packDeck = deck(title: "Ready to Pack",
                            cards: packCards,
                            emptyMessage: "All caught up! No orders to pack right now.",
                            instruction: "Tap an order to mark it as packed.",
                            deckName: .packDeck,
                            spreadDeck: state.spreadDeck)
            
            packedDeck = deck(title: "Ready to Ship",
                              cards: packedCards,
                              emptyMessage: "All caught up! No orders to ship right now.",
                              instruction: "Tap an order to mark it as shipped.",
                              deckName: .packedDeck,
                              spreadDeck: state.spreadDeck)
            
            shippedDeck = deck(title: "Shipped",
                               cards: shippedCards,
                               emptyMessage: "You haven't shipped any orders yet.",
                               instruction: "Orders in this list are already shipped.",
                               deckName: .shippedDeck,
                               spreadDeck: state.spreadDeck)
            
            isSpread = state.spreadDeck != nil
        }
    }
    
    func deck(title: String, cards: [CardConfiguration], emptyMessage: String, instruction: String, deckName: DeckName, spreadDeck: DeckName?) -> DeckConfiguration {
        return DeckConfiguration(
            title: title,
            cardConfigurations: cards,
            emptyMessage: emptyMessage,
            countMessage: { self.countMessage($0) },
            instruction: instruction,
            isSpread: spreadDeck == deckName,
            isVisible: spreadDeck == nil || spreadDeck == deckName,
            deckName: deckName,
            id: String(deckName.hashValue)
        )
    }
    
    func countMessage(_ count: Int) -> String {
        let pluralizedOrder = count == 1 ? "order" : "orders"
        return "\(count) \(pluralizedOrder)"
    }
}
