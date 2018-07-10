//
//  PTLoginManager.swift
//  Path
//
//  Created by dewey on 2018. 6. 18..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

enum PTLoginFailReason: Int {
    case asdf
    case qwqw
}

class PTLoginManager: NSObject {
    static let shared: PTLoginManager = { return PTLoginManager() }()
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(kakaoSessionDidChange(_:)), name: .KOSessionDidChange, object: nil)
    }
    
    private func login(_ loginType: PTLoginType, completion: PTLoginManagerLoginCompletionBlock?) {
        if case .kakao = loginType {
            KOSessionTask.userMeTask(completion: { (error, kakaoUserMe) in
                if let kakaoUser = kakaoUserMe, error == nil {
                    let user = PTUser.createUser(userInfo: kakaoUser)
                    PTDBManager.shared.save(type: PTUser.self, object: user)
                } else {
                    self.loginFailedHandler(.unknown)
                }
                
                if let block = completion {
                    block(true, nil)
                }
            })
        }
    }
    
    private func loginSuccessHandler() {
    
    }
    
    private func loginFailedHandler(_ errorType: PTLoginErroType, error: Error? = nil) {
    }
}

//Mark:- Kakao
extension PTLoginManager {
    @objc private func kakaoSessionDidChange(_ notification: Notification) {
        
    }
    
    open func kakaoLogin(_ completion: PTLoginManagerLoginCompletionBlock?) {
        KOSession.shared().close()
        KOSession.shared().open { (error) in
            if error == nil {
                let token = KOSession.shared().token.accessToken
                debugPrint("token: %@", token)
                
                PTApiRequest.request().kakaoLogin(token: token).observeCompletion { (response) in
                    if response.isSuccess {
                        debugPrint("success login")
                        self.login(.kakao, completion: completion)
                    } else {
                        debugPrint("failed wwg login")
                        if let block = completion {
                            block(true, nil)
                        }
                    }
                }
                return
            } else {
                debugPrint("failed kakao login")
                if let block = completion {
                    block(false, nil)
                }
            }
        }
    }
    
    open func kakaoLogout(_ competion: PTLoginManagerLogoutCompletionBlock?) {
        if KOSession.shared().isOpen() == false {
            debugPrint("already logout")
        }
        
        KOSession.shared().logoutAndClose { (success, error) in
            if success == true {
                debugPrint("logout success")
                if let block = competion {
                    block(true, nil)
                }
            } else {
                debugPrint("logout failed")
            }
        }
    }
}












