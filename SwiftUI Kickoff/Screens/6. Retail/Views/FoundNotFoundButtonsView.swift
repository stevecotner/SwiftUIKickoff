//
//  FoundNotFoundButtons.swift
//  Poet
//
//  Created by Stephen E. Cotner on 5/21/20.
//  Copyright © 2020 Steve Cotner. All rights reserved.
//

import Poet
import SwiftUI

struct FoundNotFoundButtonsView<E: Evaluating_ProductFinding>: View {
    let findableProduct: FindableProduct
    let evaluator: E
    
    var body: some View {
        let isFound = findableProduct.status == .found
        let isNotFound = findableProduct.status == .notFound
        
        return GeometryReader() { geometry in
            ZStack(alignment: .topLeading) {
                HStack(alignment: .top, spacing: 0) {
                    SelectableCapsuleButton(
                        title: "Found",
                        isSelected: isFound,
                        imageName: "checkmark",
                        action: { self.evaluator.evaluate(.toggleProductFound(self.findableProduct)) }
                    )
                    .layoutPriority(30)
                }
                .frame(width: geometry.size.width / 2.0)
                .offset(x: 0, y: 0)
                
                HStack(alignment: .top, spacing: 0) {
                    SelectableCapsuleButton(
                        title: "Not Found",
                        isSelected: isNotFound,
                        imageName: "xmark",
                        action: { self.evaluator.evaluate(.toggleProductNotFound(self.findableProduct)) }
                    )
                    .layoutPriority(30)
                }
                .frame(width: geometry.size.width / 2.0)
                .offset(x: geometry.size.width / 2.0, y: 0)
            }
        }.frame(height: 44)
    }
}
