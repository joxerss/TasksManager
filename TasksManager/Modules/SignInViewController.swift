//
//  SignInViewController.swift
//  TasksManager
//
//  Created by Artem Syritsa on 04.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit
import MaterialComponents

class SignInViewController: BaseController {

    var loginTextFieldInput: MDCTextInputControllerOutlined?
    var passwordTextFieldInput: MDCTextInputControllerOutlined?
    
    @IBOutlet weak var loginTextField: MDCTextField!
    @IBOutlet weak var passwordTextField: MDCTextField!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var registerSwitch: UISwitch!
    @IBOutlet weak var signInButton: MDCButton!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    // MARK: - Overrides
    
    override func setupObservers() {
        observeKeyboard()
    }
    
    override func removeObservers() {
        unobserveKeyboard()
    }
    
    override func prepareViews() {
        hideKeyboardOnTap()
    
        loginTextFieldInput = MDCTextInputControllerOutlined(textInput: loginTextField)
        passwordTextFieldInput = MDCTextInputControllerOutlined(textInput: passwordTextField)
        
        passwordTextField.isSecureTextEntry = true
        signInButton.isUppercaseTitle = false
        
    }
    
    override func setupAppearances() {
        signInButton.layer.cornerRadius = 8.0
        
        signInButton.setTitleColor(.titleColor, for: .normal)
        signInButton.setBackgroundColor(.buttonColor)
    }
    
    override func localize() {
        loginTextField.placeholder = "intro.email".localized()
        passwordTextField.placeholder = "intro.password".localized()
        registerLabel.text = "intro.login_register".localized()
        signInButton.setTitle("intro.signin".localized(), for: .normal)
    }

    // MARK: - Actions
    
    @IBAction func signInAction(_ sender: Any) {
        
    }
}
