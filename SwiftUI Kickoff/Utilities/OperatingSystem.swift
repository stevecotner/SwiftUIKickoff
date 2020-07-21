//
//  OperatingSystem.swift
//  Poet Tutorial
//
//  Created by Stephen E. Cotner on 7/19/20.
//

import Foundation
import SwiftUI

enum OperatingSystem {
    case iOS
    case macOS
    case other
}

extension EnvironmentValues {
    var operatingSystem: OperatingSystem {
        get {
            #if os(macOS)
            return .macOS
            #elseif os(iOS)
            return .iOS
            #else
            return .other
            #endif
        }
    }
}
