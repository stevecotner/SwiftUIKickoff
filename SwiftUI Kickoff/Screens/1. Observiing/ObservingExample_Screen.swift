//
//  ObservingExample_Screen.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/13/20.
//

import SwiftUI
import Poet

struct ObservingExample: MenuScreenPresentable {
    var title: String = "Observing"
    var description: String = "A simple view model. Evaluating an action. Observables, Observers, Observed."
    var id: UUID = UUID()
    func screen() -> AnyView {
        return AnyView(Self.Screen())
    }
}

extension ObservingExample {
    struct Screen: View {
        
        let viewModel: ViewModel
        
        init() {
            viewModel = ViewModel()
        }
        
        var body: some View {
            ZStack {
                VStack(spacing: 10) {
                    
                    // Title
                    Text("Observing")
                        .font(.headline)
                    
                    Spacer().frame(height: 20)
                    
                    // Button
                    Observer(viewModel.$namedAction) { namedAction in
                        if let namedAction = namedAction {
                            Button(namedAction.name) {
                                viewModel.evaluate(namedAction.action)
                            }
                        }
                    }
                    
                    // Feedback
                    ObservingTextView(viewModel.$feedback)
                        .opacity(0.5)
                }
            }
            .onAppear {
                viewModel.evaluate(.onAppear)
            }
        }
    }
}

struct AScreen_Previews: PreviewProvider {
    static var previews: some View {
        ObservingExample.Screen()
    }
}
