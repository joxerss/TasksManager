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
        
        loginTextField.keyboardType = .emailAddress
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
        guard let email = loginTextField.text, email.isValidEmail() else {
            loginTextFieldInput?.setErrorText("common.invalidate_email".localized(), errorAccessibilityValue: nil)
            return
        }
        loginTextFieldInput?.setErrorText(nil, errorAccessibilityValue: nil)
        
        guard let password = passwordTextField.text, password.count > 0 else {
            passwordTextFieldInput?.setErrorText("common.enter_password".localized(), errorAccessibilityValue: nil)
            return
        }
        passwordTextFieldInput?.setErrorText(nil, errorAccessibilityValue: nil)
        
        self.view.endEditing(true)
        
        let completion: RequestResultSignIn =  { [weak self] token in
            guard let `self` = self else { return }
            
            UserManager.shared.apiToken = token
            UserManager.shared.email = token != nil ? email : nil
            UserManager.shared.isAuthorized = token != nil ? true : false
            
            DispatchQueue.main.async { [weak self] in
                self?.hideAnimatedLoader()
                MainCoordinator.shared.SignIn()
            }
        }
        
        self.showAnimatedLoader()
        if(!registerSwitch.isOn) {
            RequestManager.shared.signIn(email, password, completion)
        } else {
            RequestManager.shared.signUp(email, password, completion)
        }
    }
}
