//
//  NamedAction.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/13/20.
//

import Foundation
import Poet

struct NamedAction<A: EvaluatorAction> {
    let name: String
    let action: A
    var id: UUID = UUID()
}

struct NumberedNamedAction<A: EvaluatorAction> {
    let number: Int
    let name: String
    let action: A
    var id: UUID = UUID()
}

struct NamedDisableableAction<A: EvaluatorAction> {
    let name: String
    let enabled: Bool
    let action: A
    var id: UUID = UUID()
}
