//
//  TitleView.swift
//  RetailDemo
//
//  Created by Stephen E. Cotner on 6/28/20.
//

import Poet
import SwiftUI

struct TitleView: View {
    var text: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(text)
                    .font(Font.system(size: 32, weight: .bold))
                    .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            Spacer().frame(height: 24)
        }
        .foregroundColor(color)
    }
}
