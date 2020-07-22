//
//  Menu.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/19/20.
//

import Poet
import SwiftUI

protocol MenuScreenPresentable {
    var title: String { get }
    var description: String { get }
    var id: UUID { get }
    func screen() -> AnyView
}

struct NumberedMenuScreenPresentable: MenuScreenPresentable {
    let number: Int
    let menuScreenPresentable: MenuScreenPresentable
    var title: String { return menuScreenPresentable.title }
    var description: String { return menuScreenPresentable.description }
    var id: UUID { return menuScreenPresentable.id }
    func screen() -> AnyView { return menuScreenPresentable.screen() }
}

struct MenuScreen: View {
    @Passable var showScreen: AnyView?
    @Environment(\.operatingSystem) var operatingSystem: OperatingSystem
    @State var isReadingMore: Bool = false
    private let horizontalMargin: CGFloat = 30
    
    let numberedScreenItems: [NumberedMenuScreenPresentable] = {
        let screenItems: [MenuScreenPresentable] = [
            ObservingExample(),
            TextFieldExample(),
            UndoRedoExample(),
            PassablesExample(),
            LoginExample(),
            RetailExample()
        ]
        return screenItems.enumerated().map { (index, value) in
            return NumberedMenuScreenPresentable(number: index, menuScreenPresentable: value)
        }
    }()
    
    var body: some View {
        ZStack {
            ScrollView {
                HStack {
                    Spacer().frame(width: horizontalMargin)
                    VStack(alignment: .leading) {
                        Spacer().frame(height:30)
                        
                        MenuScreenTitleArea()
                        
                        Spacer().frame(height:20)
                        
                        WelcomeBox(isReadingMore: $isReadingMore)
                        
                        Spacer().frame(height:40)
                        
                        ForEach(self.numberedScreenItems, id: \.id) { screenItem in
                            Button(action: {
                                showScreen = screenItem.screen()
                            }) {
                                NumberedTitledDescribedItemView(
                                    number: screenItem.number,
                                    title: screenItem.title,
                                    description: screenItem.description,
                                    totalItemCount: numberedScreenItems.count
                                )
                            }
                            .buttonStyle(UnstyledButtonStyle())
                            
                        }
                    }
                    Spacer(minLength: 0)
                    Spacer().frame(width: horizontalMargin)
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: isReadingMore)
            }
            
            PresenterWithPassedValue($showScreen) { screen in
                screen
            }
        }
    }
    
}

struct UnstyledButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(
                Color.primary.opacity(configuration.isPressed ? 0.25 : 1)
        )
    }
}

struct MenuScreenTitleArea: View {
    var body: some View {
        HStack(alignment: .bottom) {
            Text("SwiftUI\nKickoff")
                .font(Font.largeTitle.bold())
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

struct WelcomeBox: View {
    @Binding var isReadingMore: Bool
    @Environment(\.operatingSystem) var operatingSystem: OperatingSystem
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                Spacer()
                VStack(alignment: .leading) {
                    Image("bird")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36)
                        .offset(x: 0, y: 12.5)
                    
                    Image(systemName: "tortoise")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(Font.title.weight(.thin))
                        .frame(width: 40)
                        .offset(x: 5, y: 0)
                }
                .fixedSize(horizontal: true, vertical: true)
                
                Spacer().frame(width: 42)
            }
            .opacity(0.5)
            
            ThinLine()
            
            Spacer().frame(height: 30)
            
            VStack() {
                HStack(alignment: .top, spacing: 0) {
                    Text("Welcome to the SwiftUI Kickoff project.")
                        .font(Font.headline)
                    Spacer(minLength: 0)
                }

                Spacer().frame(height: 16)
                
                Group {
                    HStack(alignment: .top, spacing: 0) {
                        Text("This app contains examples of screens built using types and conventions found in the POET toolset.")
                        Spacer(minLength: 0)
                    }
                    
                    Spacer().frame(height: 16)
                    
                    Group {
                        HStack(alignment: .top, spacing: 0) {
                            Text("POET is a pattern the Score team has been using since before SwiftUI, but it has been simplified with SwiftUI, Combine, and Swift 5.3.")
                            Spacer(minLength: 0)
                        }
                        
                        Spacer().frame(height: 16)
                        
                        HStack(alignment: .top, spacing: 0) {
                            Text("Programmers can use these tools to create a unidirectional flow in a Swifty style (it's more flexible and less syntactically noisy than, say, Redux). POET's goal is to properly decouple a screen's business state, display state, and view logic, to optimize for reuse within any given layer and for flexibility and clarity during debugging and refactoring.")
                            Spacer(minLength: 0)
                        }
                        
                        Spacer().frame(height: 16)
                        
                        HStack(alignment: .top, spacing: 0) {
                            Text("POET is named for some of its main features: Passables, Observables, Evaluators, and Translators. Some helpful patterns emerge from the use of these basic actors, and this project explores them.")
                            Spacer(minLength: 0)
                        }
                        
                        Spacer().frame(height: 16)
                    }
                    .opacity(isReadingMore ? 1 : 0)
                    .frame(height: isReadingMore ? nil : 0)
                }
                .font(Font.subheadline)
                .opacity(0.65)
                
                Spacer().frame(height:4)
                
                HStack(alignment: .top, spacing: 0) {
                    Spacer(minLength: 0)
                    Button(action: {
                        isReadingMore.toggle()
                    }) {
                        HStack {
                            Text(isReadingMore ? "Read less" : "Read more")
                            Image(systemName: "chevron.down")
                                .rotationEffect(isReadingMore ? .init(degrees: 180) : .zero)
                        }
                    }
                    .buttonStyle(PillButtonStyle(background: .gray))
                    .font(Font.footnote)
                }
            }
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black)
                    .opacity(0.05)
                
            )
            
            Spacer().frame(height: 30)
            
            ThinLine()
        }
        .padding(.top, -50)
    }
}

struct ThinLine: View {
    var body: some View {
        Rectangle()
            .frame(height: Device.scale == .threeX ? 0.33 : 0.5)
            .opacity(Device.scale == .threeX ? 0.9 : 0.6)
    }
}

struct NumberedTitledDescribedItemView: View {
    let number: Int // zero-based
    let title: String
    let description: String
    let totalItemCount: Int // the count of all items in the array in which this item will appear
    
    @Environment(\.operatingSystem) var operatingSystem: OperatingSystem
    
    var body: some View {
        VStack {
            Spacer().frame(height: number == 0 ? 0 : 30)
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(.leastNonzeroMagnitude)
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Spacer().frame(height: 1)
                        Image.numberCircleFill(number + 1)
                            .font(Font.title3)
                    }
                    
                    Spacer().frame(width: 16)
                    
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.headline)
                        Spacer().frame(height: 6)
                        Text(description)
                            .font(operatingSystem == .macOS ? Font.subheadline : Font.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(0.5)
                    }
                    
                    Spacer(minLength: 30)
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.title3.weight(.thin))
                            .opacity(0.4)
                        Spacer()
                    }
                }
            }
            Spacer().frame(height: 20)
            Divider()
                .opacity(number + 1 == totalItemCount ? 0 : 1)
        }
    }
}
