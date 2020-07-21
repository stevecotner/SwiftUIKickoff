//
//  SwiftUI_Kickoff_MacApp.swift
//  SwiftUI Kickoff Mac
//
//  Created by Stephen E. Cotner on 7/20/20.
//

import Poet
import SwiftUI

@main
struct Poet_Tutorial_MacApp: App {
    var body: some Scene {
        WindowGroup {
            Group {
                MenuScreen()
            }
            .frame(minWidth: 600, minHeight: 800)
        }
    }
}
