//
//  RegisterViewModel.swift
//  RxSwiftDemo
//
//  Created by Scott_Mr on 2017/7/25.
//  Copyright © 2017年 Scott. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RegisterViewModel {
    
    let username = Variable<String>("")
    let password = Variable<String>("")
    let rePassword = Variable<String>("")
    let registerTaps = PublishSubject<Void>()
    
    let usernameUseable:Observable<Result>
    let passwordUseable:Observable<Result>
    let rePasswordUseable:Observable<Result>
    let registerButtonEnabled:Observable<Bool>
    let registerResult:Observable<Result>
    
    init() {
        let service = ValidationService.instance
        
        usernameUseable = username.asObservable().flatMapLatest{ username in
            return service.validationUserName(username).observeOn(MainScheduler.instance).catchErrorJustReturn(.failed(message: "userName检测出错")).shareReplay(1)
        }
        
        passwordUseable = password.asObservable().map { passWord in
            return service.validationPassword(passWord)
        }.shareReplay(1)
        
        rePasswordUseable = Observable.combineLatest(password.asObservable(), rePassword.asObservable()) {
            return service.validationRePassword($0, $1)
        }.shareReplay(1)
        
        registerButtonEnabled = Observable.combineLatest(usernameUseable, passwordUseable, rePasswordUseable) { (username, password, repassword) in
            return username.isValid && password.isValid && repassword.isValid
        }.distinctUntilChanged().shareReplay(1)
        
        let usernameAndPwd = Observable.combineLatest(username.asObservable(), password.asObservable()){
            return ($0, $1)
        }
        
        registerResult = registerTaps.asObservable().withLatestFrom(usernameAndPwd).flatMapLatest { (username, password) in
            return service.register(username, password: password).observeOn(MainScheduler.instance).catchErrorJustReturn(Result.failed(message: "注册失败"))
        }.shareReplay(1)
    }
}
