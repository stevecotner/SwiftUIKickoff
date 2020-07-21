//
//  RetailTranslator.swift
//  RetailDemo
//
//  Created by Stephen E. Cotner on 6/28/20.
//

import Foundation
import Combine
import Poet
import SwiftUI

extension RetailExample {

    class Translator {
        
        typealias Evaluator = RetailExample.Evaluator
        typealias Action = Evaluator.Action
        typealias State = Evaluator.State
        typealias Section = RetailExample.ViewMaker<Evaluator>.Section
        
        // Observable Sections for PageViewMaker
        @Observable var sections: [Section] = []
        @Observable var customerTitle: String = ""
        @Observable var feedback: String = ""
        @Observable var instructions: [String] = []
        @Observable var focusedInstructionIndex: Int? = nil
        @Observable var allowsCollapsingAndExpanding: Bool = false
        @Observable var deliveryOptions: [String] = []
        @Observable var deliveryPreference: String = ""
        @Observable var displayableProducts: [DisplayableProduct] = []
        @Observable var completedSummary: String? = ""
        
        // Bottom Button
        @Observable var bottomButtonAction: NamedDisableableAction<Action>? = nil
        
        // Passable
        @Passable var dismiss: Please?
        
        // State Sink
        var stateSink: AnyCancellable?
        
        // Formatter
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .long
            return formatter
        }()
        
        let numberFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumSignificantDigits = 2
            formatter.minimumSignificantDigits = 0
            return formatter
        }()
        
        init(_ state: Passable<State>) {
            debugPrint("init Retail Translator")
            
            stateSink = state.subject.sink { [weak self] value in
                if let value = value {
                    self?.translate(state: value)
                }
            }
        }
        
        deinit {
            debugPrint("deinit Retail Translator")
        }
    }
}

// Display Type
struct DisplayableProduct {
    var product: Product
    var findableProduct: FindableProduct?
    var id: String { return product.upc }
}

// MARK: Translating States

extension RetailExample.Translator {
    func translate(state: Evaluator.State) {
        switch state {
            
        case .initial:
            break
            
        case .notStarted(let state):
            translateNotStarted(state)
            
        case .findProducts(let state):
            translateFindingProducts(state)
            
        case .chooseDeliveryLocation(let state):
            translateDeliveryOptions(state)
            
        case .completed(let state):
            translateCompleted(state)
            
        case .canceled(let state):
            translateCanceled(state)
            
        }
    }
    
    // MARK: Not Started
    
    func translateNotStarted(_ state: Evaluator.NotStartedState) {
        
        let productCount = state.products.count
        
        // Observable Values
        
        customerTitle = "Order for \n\(state.customer)"
        feedback = "\(state.products.count) \(pluralizedProduct(productCount)) requested"
        instructions = state.instructions
        focusedInstructionIndex = nil
        allowsCollapsingAndExpanding = false
        
        displayableProducts = state.products.map({
            return DisplayableProduct(
                product: $0,
                findableProduct: nil
            )
        })
        
        // Sections
        
        sections = [
            topSpace_,
            customerTitle_,
            __,
            instructions_,
            divider_,
            feedback_,
            __,
            displayableProducts_
        ]
        
        // Bottom button
        
        withAnimation(.none) {
            bottomButtonAction = NamedDisableableAction(name: "Start", enabled: true, action: state.startAction)
        }
    }
    
    // MARK: Finding Products
    
    func translateFindingProducts(_ state: Evaluator.FindProductsState) {
        
        let foundCount = state.findableProducts.filter {$0.status == .found}.count
        
        // Observable Values
        
        customerTitle = "Order for \n\(state.customer)"
        feedback = "\(foundCount) \(pluralizedProduct(foundCount)) marked found"
        
        withAnimation(Animation.linear(duration: 0.35)) {
            instructions = state.instructions
            focusedInstructionIndex = state.focusedInstructionIndex
            allowsCollapsingAndExpanding = true
            
            displayableProducts = state.findableProducts.map({
                return DisplayableProduct(
                    product: $0.product,
                    findableProduct: $0
                )
            })
            
            // Sections
            
            sections = [
                topSpace_,
                customerTitle_,
                __,
                instructions_,
                divider_,
                feedback_,
                __,
                displayableProducts_
            ]
        }
        
        // Bottom button
        
        if let nextAction = state.nextAction {
            let name: String = {
                if case .advanceToCanceled = nextAction {
                    return "Cancel Order"
                } else {
                    return "Next"
                }
            }()
            bottomButtonAction = NamedDisableableAction(name: name, enabled: true, action: nextAction)
        } else {
            bottomButtonAction = nil
        }
    }
    
    // MARK: Delivering Products
    
    func translateDeliveryOptions(_ state: Evaluator.ChooseDeliveryLocationState) {
        
        // Observable Values
        
        customerTitle = "Order for \n\(state.customer)"
        feedback = "\(state.products.count) of \(state.numberOfProductsRequested) \(pluralizedProduct(state.numberOfProductsRequested)) found"
        deliveryOptions = state.deliveryLocationChoices
        deliveryPreference = state.deliveryLocationPreference ?? ""
        
        withAnimation(.linear) {
            instructions = state.instructions
            focusedInstructionIndex = state.focusedInstructionIndex
            allowsCollapsingAndExpanding = true

            displayableProducts = state.products.map({
                return DisplayableProduct(
                    product: $0,
                    findableProduct: nil
                )
            })
        
            // Sections
            
            sections = [
                topSpace_,
                customerTitle_,
                __,
                instructions_,
                deliveryOptions_,
                divider_,
                feedback_,
                __,
                displayableProducts_
            ]
        }
        
        // Bottom button
        
        if let nextAction = state.nextAction {
            bottomButtonAction = NamedDisableableAction(name: "Deliver and Notify Customer", enabled: true, action: nextAction)
        } else {
            bottomButtonAction = nil
        }
    }
    
    // MARK: Completed
    
    func translateCompleted(_ state: Evaluator.CompletedState) {
        
        let productCount = state.products.count
        
        // Observable Values
        
        customerTitle = title(for: state.customer)
        feedback = "\(productCount) \(pluralizedProduct(productCount)) fulfilled"
        let timeNumber = NSNumber(floatLiteral: state.elapsedTime)
        let timeString = numberFormatter.string(from: timeNumber)
        
        completedSummary =
        """
        Order completed on \(dateFormatter.string(from: state.timeCompleted)).
        \(productCount) of \(state.numberOfProductsRequested) \(pluralizedProduct(state.numberOfProductsRequested)) found.
        Time to complete: \(timeString ?? String(state.elapsedTime)) seconds.
        """
        
        withAnimation(.linear) {
            instructions = state.instructions
            focusedInstructionIndex = state.focusedInstructionIndex
            allowsCollapsingAndExpanding = true
            
            displayableProducts = state.products.map({
                return DisplayableProduct(
                    product: $0,
                    findableProduct: nil
                )
            })
        
            // Sections
            
            sections = [
                topSpace_,
                completedTitle_,
                customerTitle_,
                __,
                instructions_,
                divider_,
                feedback_,
                __,
                displayableProducts_,
                divider_,
                completedSummary_
            ]
        }
        
        // Bottom button
        
        bottomButtonAction = NamedDisableableAction(name: "Done", enabled: true, action: state.doneAction)
    }
    
    // MARK: Canceled
    
    func translateCanceled(_ state: Evaluator.CanceledState) {
        
        // Observable Values
        
        customerTitle = title(for: state.customer)
        feedback = "The customer has been notified that their order cannot be fulfilled."
        let timeNumber = NSNumber(floatLiteral: state.elapsedTime)
        let timeString = numberFormatter.string(from: timeNumber)
        
        completedSummary =
        """
        Order canceled on \(dateFormatter.string(from: state.timeCompleted)).
        0 products found.
        Time to complete: \(timeString ?? String(state.elapsedTime)) seconds.
        """
        
        // Say that only these things should appear in the body
        withAnimation(.linear) {
            instructions = state.instructions
            focusedInstructionIndex = state.focusedInstructionIndex
            allowsCollapsingAndExpanding = true
            
            // Sections
            
            sections = [
                topSpace_,
                canceledTitle_,
                customerTitle_,
                __,
                instructions_,
                divider_,
                feedback_,
                __,
                divider_,
                completedSummary_
            ]
        }
        
        // Bottom button
        
        bottomButtonAction = NamedDisableableAction(name: "Done", enabled: true, action: state.doneAction)
    }
}

// MARK: Text and Styling
 
extension RetailExample.Translator {
    func pluralizedProduct(_ count: Int) -> String {
        return (count == 1) ? "product" : "products"
    }
    
    func title(for customer: String) -> String {
        return "Order for \n\(customer)"
    }
}
    
// MARK: Sections

extension RetailExample.Translator {
    
    var canceledTitle_: Section {
        return .canceledTitle
    }
    
    var completedSummary_: Section {
        return .completedSummary(completedSummary: $completedSummary)
    }
    
    var completedTitle_: Section {
        return .completedTitle
    }
    
    var customerTitle_: Section {
        return .customerTitle(title: $customerTitle)
    }
    
    var deliveryOptions_: Section {
        return .options(options: $deliveryOptions, preference: $deliveryPreference)
    }
    
    var feedback_: Section {
        return .feedback(feedback: $feedback)
    }
    
    var displayableProducts_: Section {
        return .displayableProducts(displayableProducts: $displayableProducts)
    }
    
    var divider_: Section {
        return .divider
    }
    
    var instructions_: Section {
        return Section.instructions(instructions: $instructions, focusableInstructionIndex: $focusedInstructionIndex, allowsCollapsingAndExpanding: $allowsCollapsingAndExpanding)
    }
    
    var topSpace_: Section {
        return .topSpace
    }
    
    var __: Section {
        return .space
    }
    
}
