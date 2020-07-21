//
//  UndoRedoExample_Screen.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/11/20.
//

import SwiftUI
import Poet

struct UndoRedoExample: MenuScreenPresentable {
    var title: String = "Undo/Redo"
    var description: String = "Evaluator/Translator with multiple states. History with undo/redo."
    var id: UUID = UUID()
    func screen() -> AnyView {
        return AnyView(Self.Screen())
    }
}

extension UndoRedoExample {
    struct Screen: View {
        
        let evaluator: Evaluator
        let translator: Translator
        
        init() {
            evaluator = Evaluator()
            translator = evaluator.translator
        }
        
        var body: some View {
            ZStack {
                VStack {
                    Spacer().frame(height: 16)
                    HStack {
                        Spacer()
                        
                        // Undo Redo buttons
                        UndoRedoView(evaluator: evaluator, hasUndoHistory: translator.$hasUndoHistory, hasRedoHistory: translator.$hasRedoHistory)
                        
                        Spacer().frame(width: 16)
                    }
                    Spacer()
                }
                VStack {
                    Spacer().frame(height: 22)
                    
                    // Title
                    ObservingTextView(translator.$title)
                        .font(Font.subheadline.bold())
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        // Picture
                        Observer2(translator.$imageName, translator.$imageColor) { imageName, imageColor in
                            if let imageName = imageName {
                                Image(systemName: imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100)
                                    .foregroundColor(imageColor)
                            }
                        }
                        
                        // Button
                        Observer(translator.$namedAction) { namedAction in
                            if let namedAction = namedAction {
                                Button(action: {
                                    evaluator.evaluate(namedAction.action)
                                }) {
                                    Text(namedAction.name)
                                }
                                .buttonStyle(UnstyledButtonStyle())
                                .font(Font.largeTitle.bold().monospacedDigit())
                            }
                        }
                        
                        // Instruction
                        ObservingTextView(translator.$instruction)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // A and B buttons
                    Observer(translator.$selectedButton) { selectedButton in
                        HStack(spacing: 20) {
                            Spacer()
                            
                            CircleButton("A", isSelected: selectedButton == .a) {
                                evaluator.evaluate(.showGreeting)
                            }
                            
                            CircleButton("B", isSelected: selectedButton == .b) {
                                evaluator.evaluate(.showCounting)
                            }
                            
                            CircleButton("C", isSelected: selectedButton == .c) {
                                evaluator.evaluate(.showPicture)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    Spacer().frame(height: 20)
                }
            }
            .onAppear {
                evaluator.evaluate(.onAppear)
            }
        }
    }
}

struct UndoRedoExampleScreen_Previews: PreviewProvider {
    static var previews: some View {
        UndoRedoExample.Screen()
    }
}
