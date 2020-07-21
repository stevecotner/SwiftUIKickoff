//
//  TextFieldExample_ViewModel.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/14/20.
//

import Combine
import Foundation
import Poet

extension PassablesExample {
    
    class ViewModel {
        @Passable var alert: AlertConfiguration?
        @Passable var bezel: BezelConfiguration?
        
        deinit {
            debugPrint("deinit Passables viewmodel")
        }
    }
}

// Mark: Actions

extension PassablesExample.ViewModel: Evaluating {
    enum Action: EvaluatorAction {
        case showAlert
        case showComplicatedAlert
        case showEmojiBezel
        case showTextBezel
    }
    
    func evaluate(_ action: Action?) {
        breadcrumb(action)
        
        switch action {
            
        // Text Field
            
        case .showAlert:
            alert = AlertConfiguration(title: "Hello", message: "This is an alert.")
            
        case .showComplicatedAlert:
            alert = AlertConfiguration(
                title: "Hi",
                message: "This alert has two choices.",
                primaryAlertAction: AlertAction(title: "Cancel",
                                                  style: .cancel,
                                                  action: nil),
                secondaryAlertAction: AlertAction(title: "Delete",
                                                style: .destructive,
                                                action: {
                                                    self.alert = AlertConfiguration(title: "Delete?", message: "This does actually delete anything.")
                                                })
            )
            
        case .showEmojiBezel:
            let emoji = ["🐥", "🦈", "🐄", "🐟", "🐙", "🦕", "🦉", "🐯", "🐢", "🐘", "🦔", "🐆", "🐛", "🐌", "🐞", "🐴", "👨🏻‍💻"]
            bezel = BezelConfiguration(text: emoji.randomElement() ?? "", textSize: .big)
            
        case .showTextBezel:
            bezel = BezelConfiguration(text: "This is a bezel.", textSize: .small)
            
            
        case .none:
            break
        }
    }
    
    func test(_ string: String) {
        print("test string: \(string)")
    }
}
