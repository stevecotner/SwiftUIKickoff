//
//  DisplayableProductsView.swift
//  Poet
//
//  Created by Stephen E. Cotner on 5/21/20.
//  Copyright © 2020 Steve Cotner. All rights reserved.
//

import Poet
import SwiftUI

protocol Evaluating_ProductFinding: Evaluating where Action: EvaluatorAction_ProductFinding {}
        
protocol EvaluatorAction_ProductFinding: EvaluatorAction {
    static func toggleProductFound(_ product: FindableProduct) -> Self
    static func toggleProductNotFound(_ product: FindableProduct) -> Self
}

struct DisplayableProductsView<E: Evaluating_ProductFinding>: View {
    @Observed var displayableProducts: [DisplayableProduct]
    let evaluator: E
    
    var body: some View {
        return VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 40) {
                ForEach(displayableProducts, id: \.id) { displayableProduct in
                    return HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            ProductView(product: displayableProduct.product)
                            if displayableProduct.findableProduct != nil {
                                FoundNotFoundButtonsView(findableProduct: displayableProduct.findableProduct!, evaluator: self.evaluator)
                                    .padding(EdgeInsets(top: 8, leading: 20, bottom: 0, trailing: 20))
                                    .transition(.opacity)
                            }
                        }
                    }
                }
            }
            
            Spacer().frame(height: 30)
        }
    }
}
