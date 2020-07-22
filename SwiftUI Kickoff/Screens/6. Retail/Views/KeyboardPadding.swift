//
//  KeyboardPadding.swift
//  RetailDemo
//
//  Created by Stephen E. Cotner on 6/28/20.
//

import SwiftUI

struct KeyboardPadding: View {
    @ObservedObject private var keyboard = KeyboardResponder()
    var body: some View {
        Spacer().frame(height: keyboard.currentHeight)
            .animation(.linear(duration: 0.3))
    }
}

class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0
    
    init(center: NotificationCenter = .default) {
        notificationCenter = center
        #if os(iOS)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        #endif
    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        #if os(iOS)
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
        #endif
    }
    
    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
    
    deinit {
       notificationCenter.removeObserver(self)
    }
}
