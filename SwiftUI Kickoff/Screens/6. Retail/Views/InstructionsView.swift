//
//  InstructionsView.swift
//  Poet
//
//  Created by Stephen E. Cotner on 5/21/20.
//  Copyright © 2020 Steve Cotner. All rights reserved.
//

import Poet
import SwiftUI

struct InstructionsView: View {
    @Observed var instructions: [String]
    @Observed var focusableInstructionIndex: Int?
    @Observed var allowsCollapsingAndExpanding: Bool
    
    @State var isFocused: Bool = true
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<instructions.count, id: \.self) { instructionIndex in
                    VStack(alignment: .leading, spacing: 0) {
                        InstructionView(instructionNumber: instructionIndex + 1, instructionText: self.instructions[instructionIndex])
                            .frame(height: (self.allowsCollapsingAndExpanding && self.isFocused) ? (self.focusableInstructionIndex == instructionIndex ? nil : 0) : nil)
                            .opacity((self.allowsCollapsingAndExpanding) ? (self.isFocused ? (self.focusableInstructionIndex == instructionIndex ? 1 : 0) : (self.focusableInstructionIndex == instructionIndex ? 1 : 0.26)) : 1)
                    }
                }
                Spacer().frame(height: 18)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                VStack {
                    Button(
                        action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                                self.isFocused.toggle()
                            }
                    }) {
                        Image(systemName: self.isFocused ? "ellipsis.circle" : "xmark.circle" )
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(UnstyledButtonStyle())
                    .disabled(allowsCollapsingAndExpanding ? false : true)
                    .opacity(allowsCollapsingAndExpanding ? 1 : 0)
                    .foregroundColor(.primary)
                    .padding(.trailing, 60)
                    
                    Spacer()
                }
            }
            .frame(width: 34, height: 50)
        }
    }
}


struct InstructionView: View {
    let instructionNumber: Int
    let instructionText: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ZStack(alignment: .topLeading) {
                    Image.numberCircleFill(instructionNumber)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.primary)
                        .frame(width: 24, height: 24)
                        .padding(EdgeInsets(top: 0, leading: 39.5, bottom: 0, trailing: 0))
                    Text(instructionText)
                        .font(Font.system(size: 17, weight: .bold).monospacedDigit())
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(EdgeInsets(top: 0, leading: 76, bottom: 0, trailing: 10))
                        .offset(x: 0, y: 2)
                }
                Spacer()
            }
            Spacer().frame(height: 18)
        }
    }
}
