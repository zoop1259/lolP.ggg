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
import FirebaseAuth
import CryptoKit

@available(iOS 13.0,*) //IOS13이상 가능하기 떄문에 사용해야 한다.
class LoginPopupViewController: UIViewController {
    
    @IBOutlet var popup: UIView!
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var googleloginBtn: GIDSignInButton!
    @IBOutlet weak var appleloginBtn: ASAuthorizationAppleIDButton!
    
    @IBOutlet var txtuserLoginEmail: UITextField!
    @IBOutlet var txtuserLoginPassword: UITextField!
    
    fileprivate var currentNonce: String?
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        //googleloginBtn.style = .standard
//        appleloginBtn.addTarget(self, action: #selector(LoginPopupViewController.appleLogInButtonTapped), for: .touchDown)
//        popup.layer.cornerRadius = 30
////        if let user = Auth.auth().currentUser {
////            print("로그인 되어있는 상태")
////            self.showDetailViewController()
////        }
//    }
    //로그인이 되어있는 상태면 바로 디테일화면으로.
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            self.showDetailViewController()
            }
        
        appleloginBtn.addTarget(self, action: #selector(LoginPopupViewController.appleLogInButtonTapped), for: .touchDown)
        
    }
    
    //이메일 로그인 버튼 눌렀을때
    @IBAction func btnActSubmit(_ sender: UIButton) {
        guard let userEmail = txtuserLoginEmail.text else { return }
        guard let userPassword = txtuserLoginPassword.text else  { return }
         
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) {
            (user, error) in
            if user != nil{
                print("로그인 성공")
                self.showDetailViewController()
            }
            else{
                print("로그인되지 않았습니다.", error?.localizedDescription ?? "")
            }
        }
    }
    
    
    //애플 버튼 눌렀을때
    @objc func appleLogInButtonTapped() {
        startSignInWithAppleFlow()
    }
    
    
    
    
    //구글 버튼 눌렀을 때
    @IBAction func googleLoginBtnAction(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let signInConfig = GIDConfiguration.init(clientID: clientID)
        
      GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
        guard error == nil else { return }

        guard let authentication = user?.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
        // access token 부여 받음
        
        // 파베 인증정보 등록
        Auth.auth().signIn(with: credential) {_,_ in
            // token을 넘겨주면, 성공했는지 안했는지에 대한 result값과 error값을 넘겨줌
            print("로그인 됨")
            
            self.showDetailViewController()
        }
      }
    }
    
    private func showDetailViewController() {
        let mystoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let DetailViewController = mystoryboard.instantiateViewController(identifier: "LoginDetailView")
        //이방법은 로그인창까지 겹쳐서 올라옴.
//        self.show(DetailViewController, sender: self)
        //로그인창을 닫으면서 정보창 띄우기.
        guard let pvc = self.presentingViewController else { return }
        self.dismiss(animated: true) {
            pvc.present(DetailViewController, animated: true, completion: nil)
        }
    }
}

//MARK: Apple Login
@available(iOS 13.0, *)
//extension LoginPopupViewController: ASAuthorizationControllerDelegate {
//
//    //성공적으로 로그인을 완료했을 때
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        switch authorization.credential {
//        case let credential as ASAuthorizationAppleIDCredential:
//            let firstName = credential.fullName?.givenName
//            let lastName = credential.fullName?.familyName
//            let email = credential.email
//            break
//        default:
//            break
//        }
//    }
//    //에러가 있을 때
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        print("AppleID Credential failed with error: \(error.localizedDescription)")
//    }
//}
extension LoginPopupViewController: ASAuthorizationControllerDelegate {
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
    
        return hashString
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
    
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus   \(errorCode)")
                }
                return random
            }
    
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
    
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}

//MARK: 애플 로그인 텍스트 프로바이딩
@available(iOS 13.0, *)
extension LoginPopupViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
