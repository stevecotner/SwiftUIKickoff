//
//  ObservingPageView.swift
//  RetailDemo
//
//  Created by Stephen E. Cotner on 6/28/20.
//

import Poet
import SwiftUI
import Combine

protocol ObservingPageViewSection {
    var id: String { get }
}

protocol ObservingPageView_ViewMaker {
    associatedtype Section: ObservingPageViewSection
    func view(for: Section) -> AnyView
}

struct ObservingPageView<V: ObservingPageView_ViewMaker> : View {
    @Observed var sections: [V.Section]
    var viewMaker: V
    var margin: CGFloat = 0
    
    var body: some View {
        if self.sections.isEmpty {
            return AnyView(EmptyView())
        } else {
            return AnyView(
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        ForEach(sections, id: \.id) { section in
                            VStack(spacing: 0) {
                                self.viewMaker.view(for: section)
                                
                                // Bottom Inset
                                if (self.sections.firstIndex(where: {
                                    $0.id == section.id
                                })) == self.sections.count - 1 {
                                    Spacer().frame(height:CGFloat(45))
                                }
                            }
                            .padding(EdgeInsets(top: 0, leading: self.margin, bottom: 0, trailing: self.margin))
                        }
                        .padding(.zero)
                    }.padding(0)
                    Spacer()
                }
            )
        }
    }
}

