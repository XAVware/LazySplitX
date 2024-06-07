//
//  AuthService.swift
//  InventoryX
//
//  Created by Ryan Smetana on 3/18/24.
//

import SwiftUI
import CryptoKit

class AuthService {
    @Published var isAuthorized: Bool
    @Published var showOnboarding: Bool
    
    static let shared = AuthService()
    
    init() {
        let authorized = true
        self.isAuthorized = authorized
        self.showOnboarding = authorized ? false : true
    }
}
