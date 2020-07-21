//
//  TextField_Screen.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/14/20.
//

import Combine
import Poet
import SwiftUI

struct TextFieldExample: MenuScreenPresentable {
    var title: String = "Text Field"
    var description: String = "Evaluating a TextField. Passing text into a TextField."
    var id: UUID = UUID()
    func screen() -> AnyView {
        return AnyView(Self.Screen())
    }
}

extension TextFieldExample {
    struct Screen: View {
        
        typealias Element = ViewModel.Element
        let viewModel: ViewModel
        
        init() {
            viewModel = ViewModel()
        }
        
        var body: some View {
            ZStack {
                VStack(spacing: 10) {
                    
                    // Text Field
                    EvaluatingTextField(
                        evaluator: viewModel,
                        placeholder: "Type something",
                        elementName: Element.textField,
                        passableText: viewModel.$passableText
                    )
                    
                    Text("Type in the text field. The evaluator (a simple view model, in this case) is told about each character.")
                        .font(.footnote)
                        .foregroundColor(Color.primary.opacity(0.5))
                        .padding(.leading, 50)
                        .padding(.trailing, 50)
                    
                    Spacer().frame(height: 10)
                    
                    Button("Type Hello") {
                        viewModel.evaluate(.typeHello)
                    }
                    .buttonStyle(PillButtonStyle(background: .gray))
                }
            }
        }
    }
}

struct TextFieldExampleScreen_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldExample.Screen()
    }
}
