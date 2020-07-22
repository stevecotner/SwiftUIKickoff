//
//  RetailScreen.swift
//  RetailDemo
//
//  Created by Stephen E. Cotner on 6/28/20.
//

import Poet
import SwiftUI

struct RetailExample: MenuScreenPresentable {
    var title: String = "Retail Example"
    var description: String = "Fully decoupling business state, display state, and view logic. Dynamically adding and removing sections on screen."
    var id: UUID = UUID()
    func screen() -> AnyView {
        return AnyView(Self.Screen())
    }
}

extension RetailExample {
    struct Screen: View {
        
        let evaluator: RetailExample.Evaluator
        let translator: RetailExample.Translator
        
        init() {
            debugPrint("init retail screen")
            evaluator = Evaluator()
            translator = evaluator.translator
        }
        
        var body: some View {
            ZStack {
                
                // MARK: Page View
                ObservingPageView(
                    sections: self.translator.$sections,
                    viewMaker: RetailExample.ViewMaker(
                        evaluator: evaluator
                    )
                )

                // MARK: Dismiss
                DismissReceiver(translator.$dismiss)
                
                // MARK: Bottom Button
                
                VStack {
                    Spacer()
                    ObservingBottomButton(namedDisableableAction: self.translator.$bottomButtonAction, evaluator: evaluator)
                }
            }.onAppear() {
                self.evaluator.evaluate(.onAppear)
            }
        }
    }
}
