//
//  RetailEvaluator.swift
//  RetailDemo
//
//  Created by Stephen E. Cotner on 6/28/20.
//

import Combine
import Poet
import SwiftUI

extension RetailExample {
    class Evaluator {
        
        // Translator
        
        lazy var translator: Translator = Translator($state)
        
        // State
        
        @Passable var state: State? = .initial
        
        // Data
        var order: Order = Order(
            id: "6398327",
            products: [
            Product(
                title: "MacBook Pro 13” 1TB",
                upc: "885909918161",
                image: "macbookpro13",
                location: "Bin 1A"),
            
            Product(
                title: "iPad Pro 11” 128gb",
                upc: "888462533391",
                image: "ipadpro11",
                location: "Bin 2B"),
            
            Product(
                title: "Magic Keyboard for iPad Pro 11”",
                upc: "888462153501",
                image: "magickeyboard11",
                location: "Bin 3A"),

            Product(
                title: "Airpods Pro",
                upc: "190199246850",
                image: "airpodspro",
                location: "Bin 2C"),
            ]
        )
        
        init() {
            debugPrint("init Retail Evaluator")
        }
        
        deinit {
            debugPrint("deinit Retail Evaluator")
        }
    }
}

// MARK: Data Types

struct Order {
    var id: String
    var products: [Product]
}

struct Product {
    var title: String
    var upc: String
    var image: String
    var location: String
}

struct FindableProduct {
    var product: Product
    var status: FoundStatus
    
    enum FoundStatus {
        case unknown
        case found
        case notFound
    }
}

extension RetailExample.Evaluator {
    
    enum State: EvaluatorState {
        case initial
        case notStarted(NotStartedState)
        case findProducts(FindProductsState)
        case chooseDeliveryLocation(ChooseDeliveryLocationState)
        case completed(CompletedState)
        case canceled(CanceledState)
    }
    
    // Configurations
    
    struct NotStartedState {
        var customer: String
        var instructions: [String]
        var orderID: String
        var products: [Product]
        var startAction: Action
    }
    
    struct FindProductsState {
        var customer: String
        var instructions: [String]
        var focusedInstructionIndex: Int
        var orderID: String
        var findableProducts: [FindableProduct]
        var startTime: Date
        var nextAction: Action?
    }
    
    struct ChooseDeliveryLocationState {
        var customer: String
        var instructions: [String]
        var focusedInstructionIndex: Int
        var orderID: String
        var products: [Product]
        var numberOfProductsRequested: Int
        var deliveryLocationChoices: [String]
        var deliveryLocationPreference: String?
        var startTime: Date
        var nextAction: Action?
    }
    
    struct CompletedState {
        var customer: String
        var instructions: [String]
        var focusedInstructionIndex: Int
        var orderID: String
        var deliveryLocation: String
        var products: [Product]
        var numberOfProductsRequested: Int
        var timeCompleted: Date
        var elapsedTime: TimeInterval
        var doneAction: Action
    }
    
    struct CanceledState {
        var customer: String
        var instructions: [String]
        var focusedInstructionIndex: Int
        var orderID: String
        var timeCompleted: Date
        var elapsedTime: TimeInterval
        var doneAction: Action
    }
}

// MARK: Actions

extension RetailExample.Evaluator: Evaluating, Evaluating_ViewCycle, Evaluating_ProductFinding, Evaluating_OptionToggling {
    
    // Actions
    
    enum Action: EvaluatorAction, EvaluatorAction_ViewCycle, EvaluatorAction_OptionToggling, EvaluatorAction_ProductFinding {
        case onAppear
        case onDisappear
        case startOrder
        case advanceToDelivery
        case advanceToCompleted
        case advanceToCanceled
        case done
        case toggleOption(_ option: String)
        case toggleProductFound(_ product: FindableProduct)
        case toggleProductNotFound(_ product: FindableProduct)
    }
    
    func evaluate(_ action: Action?) {
        breadcrumb(action)
        
        switch action {
        
        // View Cycle
        case .onAppear:
            advanceToNotStarted()
            
        case .onDisappear:
            break
        
        // Advancing Between States
        
        case .startOrder:
            startOrder()
            
        case .advanceToDelivery:
            advanceToDelivery()
            
        case .advanceToCompleted:
            advanceToCompleted()
            
        case .advanceToCanceled:
            advanceToCanceled()
            
        case .done:
            translator.$dismiss.please()
            
        // Product Finding
            
        case .toggleProductFound(let product):
            toggleProductFound(product)
            
        case .toggleProductNotFound(let product):
            toggleProductNotFound(product)
            
        // Option Toggling
        
        case .toggleOption(let option):
            toggleOption(option)
            
        case .none:
            break
        }
    }
    
    // MARK: Advancing Between States
    
    func advanceToNotStarted() {
        if case .initial = state {
            self.state = .notStarted(
                NotStartedState(
                    customer: "Bob Dobalina",
                    instructions: [
                        "Tap start to claim this order",
                        "Mark items found or not found",
                        "Choose a Delivery Location"
                    ],
                    orderID: order.id,
                    products: order.products,
                    startAction: Action.startOrder)
            )
        }
    }
    
    func startOrder() {
        guard case let .notStarted(currentState) = state else { return }
        
        // not implemented yet -- asynchronous network call
        // performer.claim(configuration.orderID) // handle success and failure
        
        let state = FindProductsState(
            customer: currentState.customer,
            instructions: currentState.instructions,
            focusedInstructionIndex: 1,
            orderID: currentState.orderID,
            findableProducts: currentState.products.map {
                return FindableProduct(
                    product: $0,
                    status: .unknown)
            },
            startTime: Date(),
            nextAction: nil
        )
        
        self.state = .findProducts(state)
    }
    
    func advanceToDelivery() {
        guard case let .findProducts(currentState) = state else { return }
        
        let state = ChooseDeliveryLocationState(
            customer: currentState.customer,
            instructions: currentState.instructions,
            focusedInstructionIndex: 2,
            orderID: currentState.orderID,
            products: currentState.findableProducts.compactMap {
                if $0.status == .found {
                    return $0.product
                } else {
                    return nil
                }
            },
            numberOfProductsRequested: currentState.findableProducts.count,
            deliveryLocationChoices: ["Cash Register", "Front Door"],
            deliveryLocationPreference: nil,
            startTime: currentState.startTime,
            nextAction: nil)
        
        self.translator.scrollToTop()
            
        afterWait(200) {
            self.state = .chooseDeliveryLocation(state)
        }
    }
    
    func advanceToCompleted() {
        guard case let .chooseDeliveryLocation(currentState) = state else { return }
        
        let deliveryLocation = currentState.deliveryLocationPreference ?? "Unknown Location"
        let instructions = currentState.instructions + ["Deliver to \(deliveryLocation)"]
        
        let state = CompletedState(
            customer: currentState.customer,
            instructions: instructions,
            focusedInstructionIndex: 3,
            orderID: currentState.orderID,
            deliveryLocation: currentState.deliveryLocationPreference ?? "Unknown Location",
            products: currentState.products,
            numberOfProductsRequested: currentState.numberOfProductsRequested,
            timeCompleted: Date(),
            elapsedTime: abs(currentState.startTime.timeIntervalSinceNow),
            doneAction: .done
            )
        
        self.translator.scrollToTop()
        
        afterWait(200) {
            self.state = .completed(state)
        }
    }
    
    func advanceToCanceled() {
        guard case let .findProducts(currentState) = state else { return }
        
        let instructions = currentState.instructions + ["You're all set!"]
        
        let state = CanceledState(
            customer: currentState.customer,
            instructions: instructions,
            focusedInstructionIndex: 3,
            orderID: currentState.orderID,
            timeCompleted: Date(),
            elapsedTime: abs(currentState.startTime.timeIntervalSinceNow),
            doneAction: .done
            )
        
        self.translator.scrollToTop()
        
        afterWait(200) {
            self.state = .canceled(state)
        }
    }
    
    // MARK: Product Finding
    
    func toggleProductFound(_ product: FindableProduct) {
        guard case let .findProducts(currentState) = state else { return }
        
        // Toggle status
        
        var modifiedProduct = product
        modifiedProduct.status = {
            switch modifiedProduct.status {
            case .found:
                return .unknown
            case .notFound, .unknown:
                return .found
            }
        }()
        
        updateFindableProduct(modifiedProduct, on: currentState)
        updateNextActionForFindableProducts()
    }
    
    func toggleProductNotFound(_ product: FindableProduct) {
        guard case let .findProducts(currentState) = state else { return }
        
        // Toggle status
        
        var modifiedProduct = product
        modifiedProduct.status = {
            switch modifiedProduct.status {
            case .notFound:
                return .unknown
            case .found, .unknown:
                return .notFound
            }
        }()
        
        updateFindableProduct(modifiedProduct, on: currentState)
        updateNextActionForFindableProducts()
    }
    
    private func updateFindableProduct(_ modifiedProduct: FindableProduct, on state: FindProductsState) {
        var modifiableState = state
        let findableProducts: [FindableProduct] = state.findableProducts.map {
            if $0.product.upc == modifiedProduct.product.upc {
                return modifiedProduct
            }
            return $0
        }
        
        modifiableState.findableProducts = findableProducts
        
        self.state = .findProducts(modifiableState)
    }
    
    private func updateNextActionForFindableProducts() {
        guard case var .findProducts(state) = state else { return }
        
        let ready = state.findableProducts.allSatisfy { (findableProduct) -> Bool in
            findableProduct.status != .unknown
        }
        
        if ready {
            let noneFound = state.findableProducts.allSatisfy { (findableProduct) -> Bool in
                findableProduct.status == .notFound
            }
            if noneFound {
                state.nextAction = .advanceToCanceled
            } else {
                state.nextAction = .advanceToDelivery
            }
        } else {
            state.nextAction = nil
        }
        
        self.state = .findProducts(state)
    }
    
    // MARK: Option Toggling
    
    func toggleOption(_ option: String) {
        guard case var .chooseDeliveryLocation(state) = state else { return }
        
        if option == state.deliveryLocationPreference {
            state.deliveryLocationPreference = nil
            state.nextAction = nil
        } else {
            state.deliveryLocationPreference = option
            state.nextAction = .advanceToCompleted
        }
        
        self.state = .chooseDeliveryLocation(state)
    }
}
