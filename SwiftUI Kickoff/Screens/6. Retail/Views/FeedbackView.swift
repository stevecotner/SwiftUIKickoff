//
//  FeedbackView.swift
//  Poet
//
//  Created by Stephen E. Cotner on 6/13/20.
//  Copyright © 2020 Steve Cotner. All rights reserved.
//

import Poet
import SwiftUI

struct FeedbackView: View {
    @Observed var feedback: String
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(feedback)
                    .font(Font.headline.monospacedDigit().bold())
                    .opacity(0.36)
                    .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            Spacer().frame(height: 18)
        }
    }
}
