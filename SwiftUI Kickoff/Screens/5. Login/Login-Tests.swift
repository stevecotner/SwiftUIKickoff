//
//  Login-Tests.swift
//  PoetTests
//
//  Created by Stephen E. Cotner on 5/29/20.
//  Copyright © 2020 Steve Cotner. All rights reserved.
//

import Poet
@testable import SwiftUI_Kickoff
import XCTest

class Login_Tests: XCTestCase {
    typealias Action = LoginExample.Evaluator.Action
    typealias Element = LoginExample.Evaluator.Element
    
    var screen: LoginExample.Screen?
    var evaluator: LoginExample.Evaluator?
    var translator: LoginExample.Translator?
    
    // override func setUpWithError() throws { // <-- new xcode
    override func setUp() { // <-- old xcode
        // Put setup code here. This method is called before the invocation of each test method in the class.
        screen = LoginExample.Screen()
        evaluator = screen?.evaluator
        translator = screen?.translator
    }

    // override func tearDownWithError() throws { // <-- new xcode
    override func tearDown() { // <-- old xcode
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoginSuccessShowsAlert() throws {
        evaluator?.performer = LoginMockPerformer(shouldSucceed: true)
        evaluator?.showLogin()
        evaluator?.evaluate(Action.signIn)
        XCTAssert(translator?.alert?.title == "Login Succeeded!", "Alert title should say 'Login Succeeded!' Actual: \(String(describing: translator?.alert?.title))")
    }
    
    func testLoginFailureShowsAlert() throws {
        evaluator?.performer = LoginMockPerformer(shouldSucceed: false)
        evaluator?.showLogin()
        evaluator?.evaluate(Action.signIn)
        XCTAssert(translator?.alert?.title == "Login Failed", "Alert title should say 'Login Failed' Actual: \(String(describing: translator?.alert?.title))")
    }
    
    func testUsernameCharacterCountValidation() throws {
        evaluator?.performer = LoginMockPerformer(shouldSucceed: true)
        evaluator?.showLogin()
        
        // Invalid: hey
        evaluator?.textFieldDidChange(text: "hey", elementName: Element.usernameTextField)
        XCTAssert(translator?.usernameValidation.isValid == false, "Username should be invalid. Actual: \(String(describing: translator?.usernameValidation.isValid))")
        
        // Valid: hello
        evaluator?.textFieldDidChange(text: "hello", elementName: Element.usernameTextField)
        XCTAssert(translator?.usernameValidation.isValid == true, "Username should be valid.  Actual: \(String(describing: translator?.usernameValidation.isValid))")
    }

    func testUsernameBadCharacterValidation() throws {
        evaluator?.performer = LoginMockPerformer(shouldSucceed: true)
        evaluator?.showLogin()
        
        // Valid: hello
        evaluator?.textFieldDidChange(text: "hello", elementName: Element.usernameTextField)
        XCTAssert(translator?.usernameValidation.isValid == true, "Username should be valid. Actual: \(String(describing: translator?.usernameValidation.isValid))")
        
        // Invalid: hello,\=
        evaluator?.textFieldDidChange(text: "hello,\\=", elementName: Element.usernameTextField)
        XCTAssert(translator?.usernameValidation.isValid == false, "Username should be invalid.  Actual: \(String(describing: translator?.usernameValidation.isValid))")
    }
    
    func testPasswordCharacterCountValidation() throws {
        evaluator?.performer = LoginMockPerformer(shouldSucceed: true)
        evaluator?.showLogin()
        
        // Invalid: 123
        evaluator?.textFieldDidChange(text: "123", elementName: Element.passwordTextField)
        XCTAssert(translator?.passwordValidation.isValid == false, "Password should be invalid. Actual: \(String(describing: translator?.passwordValidation.isValid))")
        
        // Valid: 123456
        evaluator?.textFieldDidChange(text: "123456", elementName: Element.passwordTextField)
        XCTAssert(translator?.passwordValidation.isValid == true, "Password should be valid.  Actual: \(String(describing: translator?.passwordValidation.isValid))")
    }

    func testPasswordBadCharacterValidation() throws {
        evaluator?.performer = LoginMockPerformer(shouldSucceed: true)
        evaluator?.showLogin()
        
        // Valid: 123456
        evaluator?.textFieldDidChange(text: "123456", elementName: Element.passwordTextField)
        XCTAssert(translator?.passwordValidation.isValid == true, "Password should be valid. Actual: \(String(describing: translator?.passwordValidation.isValid))")
        
        // Invalid: 123456@.
        evaluator?.textFieldDidChange(text: "123456@.", elementName: Element.passwordTextField)
        XCTAssert(translator?.passwordValidation.isValid == false, "Password should be invalid.  Actual: \(String(describing: translator?.passwordValidation.isValid))")
    }
}
