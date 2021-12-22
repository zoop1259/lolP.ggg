//
//  LoginPopViewController.swift
//  lolP.gg
//
//  Created by 강대민 on 2021/12/02.
//

import Foundation
import UIKit
import AuthenticationServices
import GoogleSignIn
import Firebase

@available(iOS 13.0,*) //IOS13이상 가능하기 떄문에 사용해야 한다.
class LoginPopupViewController: UIViewController {
    
    @IBOutlet var popup: UIView!
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var googleloginBtn: GIDSignInButton!
    @IBOutlet weak var appleloginBtn: ASAuthorizationAppleIDButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appleloginBtn.addTarget(self, action: #selector(LoginPopupViewController.appleLogInButtonTapped), for: .touchDown)
        popup.layer.cornerRadius = 30
    }
    
    
    
    //애플 버튼 눌렀을때
    @objc func appleLogInButtonTapped() {
        let authorizationProvider = ASAuthorizationAppleIDProvider()
        let request = authorizationProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    //구글 버튼 눌렀을 때
    @IBAction func googleLoginBtnAction(_ sender: UIButton) {
        self.googleAuthLogin()
    }
    func googleAuthLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let signInConfig = GIDConfiguration.init(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            
            guard let authentication = user?.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
        
            Auth.auth().signIn(with: credential) {_,_ in
                
                Logintest()
            }
        }
    }
}

//MARK: Apple Login
@available(iOS 13.0, *)
extension LoginPopupViewController: ASAuthorizationControllerDelegate {
    
    //성공적으로 로그인을 완료했을 때
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credential as ASAuthorizationAppleIDCredential:
            let firstName = credential.fullName?.givenName
            let lastName = credential.fullName?.familyName
            let email = credential.email
            
            break
            
        default:
            break
            
        }
    }
    //에러가 있을 때
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("AppleID Credential failed with error: \(error.localizedDescription)")
    }
}

//MARK: 애플 로그인 텍스트 프로바이딩
@available(iOS 13.0, *)
extension LoginPopupViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
