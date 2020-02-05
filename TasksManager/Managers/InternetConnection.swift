//
//  InternetConnectionPopUp.swift
//  GeniusFinance
//
//  Created by Artem on 6/24/19.
//  Copyright © 2019 Artem. All rights reserved.
//

import UIKit
import Reachability
import MaterialComponents.MaterialButtons
import Lottie

class InternetConnectionManager: NSObject {
    
    public static let shared = InternetConnectionManager()

    let reachability = try! Reachability()
    
    private let sharedController: InternetConnection = UIStoryboard.init(name: UIStoryboard.modal, bundle: nil).instantiateViewController(identifier: UIViewController.modalConnectionViewController)
    
    private override init() {
        super.init()
        sharedController.modalPresentationStyle = .custom
        sharedController.modalTransitionStyle = .crossDissolve
        sharedController.loadViewIfNeeded()
        
        observe()
    }
    
    deinit {
        print("❌ \(InternetConnectionManager.self), \(#function)")
        reachability.stopNotifier()
    }
    
    // MARK: - Observable
    
    private func observe() {
        
        reachability.whenReachable = { [weak self] reach in
            self?.checkInternet(reach.connection)
        }
        
        reachability.whenUnreachable = { [weak self] reach in
            self?.checkInternet(reach.connection)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("🔨 Unable to start notifier")
        }
    }
    
    private func unobserve() {
        reachability.stopNotifier()
    }
    
    // MARK: - Actions public
        
    private func checkInternet(_ connection: Reachability.Connection  = InternetConnectionManager.shared.reachability.connection) {
        #if targetEnvironment(simulator)
        self.unobserve()
        self.observe()
        #endif
        
        switch connection {
        case .wifi, .cellular:
            print("🛰 Reachable via WiFi or Cellular \(sharedController.presentingViewController != nil)")
            if sharedController.presentingViewController != nil {
                sharedController.dismiss(animated: true, completion: nil)
            }
        case .none, .unavailable:
            print("🛰 Network not reachable \(sharedController.presentingViewController != nil)")
            showIntertetController()
        }
    }
     
    func hideControllerIfMay() {
        checkInternet(reachability.connection)
    }
    
    // MARK: - Actions private
    
    private func showIntertetController() -> Void {
        guard let root = Material.getRootViewController() else { fatalError("👩🏼‍💻 Root can't be nil.") }
        guard let visableController = Material.getVisibleViewController(root) else { fatalError("👩🏼‍💻 VisableController can't be nil.") }
        if visableController.isKind(of: InternetConnection.self) {
            print("⚠️ \(InternetConnection.self) already presented.")
            return
        }
        visableController.modalPresentationStyle = .overCurrentContext
        
        visableController.present(sharedController, animated: true, completion: nil)
    }
    
}

// MARK: - UI VIEW CONTROLLER

class InternetConnection: BaseController {

    // MARK: - Varibles
    
    let checkButtonLabel = "internet.check_internet".localized()
    let message = "internet.no_internet".localized()
    
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var checkButton: MDCButton!
    @IBOutlet weak var animationView: AnimationView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // listen reachability
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.currentProgress = 0.0
        animationView.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Appearances
    
    override func localize() {
        messageLabel.text = message
        checkButton.setTitle(checkButtonLabel, for: .normal)
    }
    
    override func setupAppearances() {
        checkButton.isUppercaseTitle = false
        view.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.6)
        animationView.backgroundColor = .clear
        
        checkButton.setBackgroundColor(.buttonColor)
    }
    
    override func prepareViews() {
        titleImage.isHidden = true
        animationView.isHidden = false
        
        let animation: Animation? = Animation.named("animationNoInternetConnection")
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.animationSpeed = 1.0
    }
    
    //MARK: - Actions
    
    @IBAction func checkEthernet(_ sender: Any?) {
        InternetConnectionManager.shared.hideControllerIfMay()
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
