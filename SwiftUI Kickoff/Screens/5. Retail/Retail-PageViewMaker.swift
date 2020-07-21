//
//  Retail-PageViewMaker.swift
//  RetailDemo
//
//  Created by Stephen E. Cotner on 6/28/20.
//

import Combine
import Poet
import SwiftUI

extension RetailExample {
    struct ViewMaker<E: Evaluating_ProductFinding & Evaluating_OptionToggling>: ObservingPageView_ViewMaker {
        
        enum Section: ObservingPageViewSection {
            case canceledTitle
            case completedTitle
            case completedSummary(completedSummary: Observed<String?>)
            case customerTitle(title: Observed<String>)
            case options(options: Observed<[String]>, preference: Observed<String>)
            case feedback(feedback: Observed<String>)
            case displayableProducts(displayableProducts: Observed<[DisplayableProduct]>)
            case divider
            case instructions(instructions: Observed<[String]>, focusableInstructionIndex: Observed<Int?>, allowsCollapsingAndExpanding: Observed<Bool>)
            case topSpace
            case space
            
            var id: String {
                switch self {
                case .canceledTitle:        return "canceledTitle"
                case .completedTitle:       return "completedTitle"
                case .completedSummary:     return "completedSummary"
                case .customerTitle:        return "customerTitle"
                case .options:              return "options"
                case .feedback:             return "feedback"
                case .displayableProducts:  return "displayableProducts"
                case .divider:              return "divider"
                case .instructions:         return "instructions"
                case .topSpace:             return "topSpace"
                case .space:                return "space"
                }
            }
        }
        
        let evaluator: E
        
        func view(for section: Section) -> AnyView {
            switch section {
            
            case .topSpace:
                return AnyView(
                    Spacer().frame(height: 60)
                )
                
            case .space:
                return AnyView(
                    SpaceView()
                )
                
            case .canceledTitle:
                return AnyView(
                    Fadeable {
                        TitleView(
                            text: "Canceled",
                            color: Color.red // systemRed
                        )
                    }
                )
                
            case .completedTitle:
                return AnyView(
                    Fadeable {
                        TitleView(
                            text: "Completed",
                            color: Color.green // systemGreen
                        )
                    }
                )
                
            case .customerTitle(let title):
                return AnyView(
                    Observer(title) { title in
                        TitleView(
                            text: title,
                            color: Color.primary
                        )
                    }
                )
                
            case .divider:
                return AnyView(
                    DividerView()
                )
                
            case .feedback(let feedback):
                return AnyView(
                    FeedbackView(feedback: feedback)
                )
                
            case .instructions(let instructions, let focusableInstructionIndex, let allowsCollapsingAndExpanding):
                return AnyView(
                    InstructionsView(
                        instructions: instructions,
                        focusableInstructionIndex: focusableInstructionIndex,
                        allowsCollapsingAndExpanding: allowsCollapsingAndExpanding
                    )
                )
             
            case .displayableProducts(let displayableProducts):
                return AnyView(
                    VStack(spacing: 0) {
                        DisplayableProductsView(displayableProducts: displayableProducts, evaluator: self.evaluator)
                    }
                )
                
            case .options(let options, let preference):
                return AnyView(
                    Fadeable {
                        OptionsView(options: options, preference: preference, evaluator: self.evaluator)
                    }
                )
                
            case .completedSummary(let completedSummary):
                return AnyView(
                    Fadeable {
                        VStack(spacing: 0) {
                            HStack {
                                ObservingTextView(completedSummary)
                                    .font(Font.system(.headline))
                                    .opacity(0.36)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40))
                                Spacer()
                            }
                        }.padding(.bottom, 30)
                    }
                )
            }
        }
    }
}
