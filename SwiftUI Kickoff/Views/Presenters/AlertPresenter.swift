//
//  AlertPresenter.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/20/20.
//

import Poet
import SwiftUI

struct AlertPresenter: View {
    let configuration: Passable<AlertConfiguration>
    
    @Observable var title: String = ""
    @Observable var message: String = ""
    @Observable var primaryAlertAction: AlertAction? = nil
    @Observable var secondaryAlertAction: AlertAction? = nil
    @Observable var isAlertPresented: Bool = false
    
    init(_ configuration: Passable<AlertConfiguration>) {
        self.configuration = configuration
    }
    
    var body: some View {
        AlertView(
            title: $title,
            message: $message,
            primaryAlertAction: $primaryAlertAction,
            secondaryAlertAction: $secondaryAlertAction,
            isPresented: $isAlertPresented)
            
        .onReceive(configuration.subject) { alertConfiguration in
            if let alertConfiguration = alertConfiguration {
                self.title = alertConfiguration.title
                self.message = alertConfiguration.message
                self.primaryAlertAction = alertConfiguration.primaryAlertAction
                self.secondaryAlertAction = alertConfiguration.secondaryAlertAction
                self.isAlertPresented = true
            }
        }
    }
}

struct AlertView: View {
    @Observed var title: String
    @Observed var message: String
    @Observed var primaryAlertAction: AlertAction?
    @Observed var secondaryAlertAction: AlertAction?
    @Observed var isPresented: Bool
    
    var body: some View {
        VStack {
            EmptyView()
        }
        .alert(isPresented: _isPresented.$observable.wrappedValue) {
            if let primaryAlertAction = primaryAlertAction, let secondaryAlertAction = secondaryAlertAction {
                let primaryButton: Alert.Button = button(for: primaryAlertAction)
                let secondaryButton: Alert.Button = button(for: secondaryAlertAction)
                return Alert(title: Text(title), message: Text(message), primaryButton: primaryButton, secondaryButton: secondaryButton)
            } else if let primaryAlertAction = primaryAlertAction {
                let primaryButton: Alert.Button = button(for: primaryAlertAction)
                return Alert(title: Text(title), message: Text(message), dismissButton: primaryButton)
            } else {
                let primaryButton = Alert.Button.default(Text("OK"))
                return Alert(title: Text(title), message: Text(message), dismissButton: primaryButton)
            }
        }
    }
    
    func button(for alertAction: AlertAction) -> Alert.Button {
        switch alertAction.style {
        case .regular:
            return Alert.Button.default(Text(alertAction.title), action: {
                DispatchQueue.main.async {
                    alertAction.action?()
                }
            })
        case .cancel:
            return Alert.Button.cancel(Text(alertAction.title), action: {
                DispatchQueue.main.async {
                    alertAction.action?()
                }
            })
        case .destructive:
            return Alert.Button.destructive(Text(alertAction.title), action: {
                DispatchQueue.main.async {
                    alertAction.action?()
                }
            })
        }
    }
}

struct AlertConfiguration {
    var title: String
    var message: String
    var primaryAlertAction: AlertAction?
    var secondaryAlertAction: AlertAction?
    
    init(title: String, message: String) {
        self.title = title
        self.message = message
        self.primaryAlertAction = nil
        self.secondaryAlertAction = nil
    }
    
    init(title: String, message: String, alertAction: AlertAction) {
        self.title = title
        self.message = message
        self.primaryAlertAction = alertAction
        self.secondaryAlertAction = nil
    }
    
    init(title: String, message: String, primaryAlertAction: AlertAction, secondaryAlertAction: AlertAction) {
        self.title = title
        self.message = message
        self.primaryAlertAction = primaryAlertAction
        self.secondaryAlertAction = secondaryAlertAction
    }
}

struct AlertAction {
    let title: String
    let style: AlertStyle
    let action: (() -> Void)?
    
    enum AlertStyle {
        case regular
        case cancel
        case destructive
    }
}
