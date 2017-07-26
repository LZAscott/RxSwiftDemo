//
//  LoginViewModel.swift
//  RxSwiftDemo
//
//  Created by Scott_Mr on 2017/7/25.
//  Copyright © 2017年 Scott. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewModel {
    
    let usernameUseable:Driver<Result>
    let loginButtonEnabled:Driver<Bool>
    let loginResult:Driver<Result>
    
    init(input:(username:Driver<String>, password:Driver<String>, loginTaps:Driver<Void>), service:ValidationService) {
        
        usernameUseable = input.username.flatMapLatest { userName in
            return service.loginUserNameValid(userName).asDriver(onErrorJustReturn: .failed(message: "连接server失败"))
        }
        
        let usernameAndPass = Driver.combineLatest(input.username,input.password) {
            return ($0, $1)
        }
        
        loginResult = input.loginTaps.withLatestFrom(usernameAndPass).flatMapLatest{ (username, password)  in
            service.login(username, password: password).asDriver(onErrorJustReturn: .failed(message: "连接server失败"))
        }
        
        loginButtonEnabled = input.password.map {
            $0.characters.count > 0
        }.asDriver()
    }
}
