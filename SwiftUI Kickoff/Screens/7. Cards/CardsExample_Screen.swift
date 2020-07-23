//
//  CardsExample_Screen.swift
//  SwiftUI Kickoff
//
//  Created by Stephen E. Cotner on 7/22/20.
//

import Poet
import SwiftUI

struct CardsExample: MenuScreenPresentable {
    var title: String = "Cards"
    var description: String = "Stackable Card Decks. Decoupled business state, display state, and view layer."
    var id: UUID = UUID()
    func screen() -> AnyView {
        return AnyView(Self.Screen())
    }
}

extension CardsExample {
    struct Screen: View {
        
        typealias Action = Evaluator.Action
        
        let evaluator: Evaluator
        let translator: Translator
        
        init() {
            evaluator = Evaluator()
            translator = evaluator.translator
        }
        
        var body: some View {
            ZStack {
                Observer(translator.$isSpread) { isSpread in
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            VStack(spacing: 0) {
                                Spacer().frame(height: 60)
                                Group {
                                    if isSpread == false {
                                        HStack {
                                            Spacer().frame(width: 40)
                                            Text("Fulfill\nOrders")
                                                .font(Font.largeTitle.bold())
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                            Spacer().frame(width: 44)
                                        }
                                        
                                        Spacer()
                                            .frame(height: 30)
                                    }
                                    
                                    CardDeck(evaluator: evaluator, deckConfiguration: translator.$pickDeck)
                                    
                                    CardDeck(evaluator: evaluator, deckConfiguration: translator.$packDeck)
                                    
                                    CardDeck(evaluator: evaluator, deckConfiguration: translator.$packedDeck)
                                    
                                    CardDeck(evaluator: evaluator, deckConfiguration: translator.$shippedDeck)
                                }
                            }
                        }
                        .onReceive(translator.$focusedCard.subject) { value in
                            if let value = value {
                                withAnimation {
                                    scrollProxy.scrollTo(value, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                AlertPresenter(translator.$alert)
            }.onAppear {
                self.evaluator.evaluate(.onAppear)
            }
        }
    }
}
