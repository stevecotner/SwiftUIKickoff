//
//  CardDeck.swift
//  SwiftUI Kickoff
//
//  Created by Stephen E. Cotner on 7/22/20.
//

import Poet
import SwiftUI

struct DeckConfiguration: Identifiable {
    let title: String
    let cardConfigurations: [CardConfiguration]
    let emptyMessage: String
    let countMessage: (Int) -> String?
    let instruction: String?
    let isSpread: Bool
    let isVisible: Bool
    let deckName: EvaluatorElement
    let id: String
}

struct CardConfiguration: Identifiable {
    let title: String
    let body: String
    let height: CGFloat
    let id: String
    let data: EvaluatorData
}

protocol Evaluating_Card: Evaluating where Action: EvaluatorAction_Card {}

protocol EvaluatorAction_Card: EvaluatorAction {
    static func spreadDeck(deckName: EvaluatorElement) -> Self
    static func stackDeck(deckName: EvaluatorElement) -> Self
    static func selectItem(data: EvaluatorData) -> Self
}

struct CardDeck<E: Evaluating_Card>: View {
    let evaluator: E
    @Observed var deckConfiguration: DeckConfiguration?
    var body: some View {
        if let deckConfiguration = deckConfiguration, deckConfiguration.isVisible {
            VStack {
                let count = deckConfiguration.cardConfigurations.count
                
                HStack {
                    Text(deckConfiguration.title)
                        .font(Font.title2.bold())
                        .fixedSize(horizontal: false, vertical: true)
                        .scaleEffect(deckConfiguration.isSpread ? 1.25 : 1, anchor: .topLeading)
                    Spacer()
                    Button(deckConfiguration.isSpread ? "Close" : "\(count)") {
                        if deckConfiguration.isSpread {
                            evaluator.evaluate(.stackDeck(deckName: deckConfiguration.deckName))
                        }
                    }
                    .buttonStyle(PillButtonStyle(background: deckConfiguration.isSpread ? .gray : .black, size: deckConfiguration.isSpread ? .large : .small))
                    .allowsHitTesting(deckConfiguration.isSpread)
                    .opacity(deckConfiguration.isSpread ? 1 : count > 0 ? 1 : 0)
                }
                
                Spacer().frame(height: 16)
                
                
                if deckConfiguration.isSpread, let countMessage = deckConfiguration.countMessage(count) {
                    HStack {
                        Text(countMessage)
                            .font(Font.headline)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    Spacer().frame(height: 18)
                }
                
                if deckConfiguration.isSpread, let instruction = deckConfiguration.instruction {
                    HStack {
                        Text(instruction)
                            .font(Font.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(0.4)
                        Spacer()
                    }
                    Spacer().frame(height: 18)
                }
                
                Spacer().frame(height: 10)
                
                ForEach(Array(deckConfiguration.cardConfigurations.enumerated()), id: \.element.id) { (index, cardConfiguration) in
                    return Card(evaluator: evaluator,
                                cardConfiguration: cardConfiguration,
                                deckName: deckConfiguration.deckName,
                                isDeckSpread: deckConfiguration.isSpread)
                        .zIndex(Double(deckConfiguration.cardConfigurations.count - index))
                        .padding(.top, topPadding(index: index, cardheight: cardConfiguration.height))
                        
                        .scaleEffect(spreadOrStackedScale(index: index), anchor: .bottom)
                        .opacity(spreadOrStackedOpacity(index: index))
                }
                
                HStack {
                    if deckConfiguration.cardConfigurations.isEmpty {
                        Text(deckConfiguration.emptyMessage)
                            .font(.title3)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(0.3)
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .padding(.leading, 40)
            .padding(.trailing, 40)
            .padding(.bottom, 44)
        } else {
            EmptyView()
        }
    }
    
    func topPadding(index: Int, cardheight: CGFloat) -> CGFloat {
        index == 0 ? 0 : deckConfiguration?.isSpread == true ? 20 : -(cardheight - (index < 3 ? 10 : 0))
    }
    
    func spreadOrStackedScale(index: Int) -> CGFloat {
        if deckConfiguration?.isSpread == true {
            return 1
        } else {
            if index < 5 {
                return max(0, 1 - (CGFloat(index) * 0.1))
            } else {
                let a = CGFloat(5 * 0.1)
                return max(0, 1 - a - (CGFloat(index - 5) * 0.05))
            }
        }
    }
    
    func spreadOrStackedOpacity(index: Int) -> Double {
        if deckConfiguration?.isSpread == true {
            return 1
        } else {
            return index < 3 ? 1 : 0
        }
    }
}



struct Card<E: Evaluating_Card>: View {
    let evaluator: E
    let cardConfiguration: CardConfiguration
    let deckName: EvaluatorElement
    let isDeckSpread: Bool
    var body: some View {
        Button(action: {
            if isDeckSpread == false {
                evaluator.evaluate(.spreadDeck(deckName: deckName))
            } else {
                evaluator.evaluate(.selectItem(data: cardConfiguration.data))
            }
        }) {
            HStack {
                VStack {
                    HStack {
                        Text(cardConfiguration.title)
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    HStack {
                        Text(cardConfiguration.body)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
            .frame(height: cardConfiguration.height)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 5)
            )
        }
        .buttonStyle(CardButtonStyle())
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.04 : 1, anchor: .center)
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.05 : 0), radius: 20, x: 0, y: 5)
            .animation(.spring(response: 0.25, dampingFraction: 0.6, blendDuration: 0), value: configuration.isPressed)
    }
}
