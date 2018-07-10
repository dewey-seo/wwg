//
//  PTLoginObjects.swift
//  Path
//
//  Created by dewey on 2018. 7. 2..
//  Copyright © 2018년 path. All rights reserved.
//

import Foundation

typealias PTLoginManagerLoginCompletionBlock = (_ success: Bool, _ loginInfo: PTLoginInfo?) -> Void
typealias PTLoginManagerLogoutCompletionBlock = (_ success: Bool, _ logoutInfo: PTLogoutInfo?) -> Void

enum PTLoginType: Int {
    case kakao = 0
    case facebook
}

enum PTLoginErroType: Int {
    case unknown
    case needRegister
}

struct PTLoginInfo {
}

struct PTLogoutInfo {
}

