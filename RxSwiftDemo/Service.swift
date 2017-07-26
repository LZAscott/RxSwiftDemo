//
//  Service.swift
//  RxSwiftDemo
//
//  Created by Scott_Mr on 2017/7/25.
//  Copyright © 2017年 Scott. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ValidationService {
    
    // 单例类
    static let instance = ValidationService()
    private init(){}
    
    let minCharactersCount = 6
    
    let filePath = NSHomeDirectory() + "/Documents/users.plist"
    
    // 验证用户名
    func validationUserName(_ name:String) -> Observable<Result> {
        if name.characters.count == 0 { // 当字符串为空的时候，什么也不做
            return Observable.just(Result.empty)
        }
        
        if name.characters.count < minCharactersCount {
            return Observable.just(Result.failed(message: "用户名长度至少为6位"))
        }
        
        if checkHasUserName(name) {
            return Observable.just(Result.failed(message: "用户名已存在"))
        }
        
        return Observable.just(Result.ok(message: "用户名可用"))
    }
    
    // 检查plist文件中是否有该用户名
    func checkHasUserName(_ userName:String) -> Bool {
        
        guard let userDict = NSDictionary(contentsOfFile: filePath) else {
            return false
        }
        
        let usernameArray = userDict.allKeys as NSArray
        
        return usernameArray.contains(userName)
    }
    
    // 验证密码
    func validationPassword(_ password:String) -> Result {
        if password.characters.count == 0 {
            return Result.empty
        }
        
        if password.characters.count < minCharactersCount {
            return .failed(message: "密码长度至少为6位")
        }
        
        return .ok(message: "密码可用")
    }
    
    // 验证确认密码
    func validationRePassword(_ password:String, _ rePassword: String) -> Result {
        if rePassword.characters.count == 0 {
            return .empty
        }
        
        if rePassword.characters.count < minCharactersCount {
            return .failed(message: "密码长度至少为6位")
        }
        
        if rePassword == password {
            return .ok(message: "密码可用")
        }
        
        return .failed(message: "两次密码不一样")
    }
    
    // 注册
    func register(_ username:String, password:String) -> Observable<Result> {
        let userDict = [username: password]
        
        if (userDict as NSDictionary).write(toFile: filePath, atomically: true) {
            return Observable.just(Result.ok(message: "注册成功"))
        }else{
            return Observable.just(Result.failed(message: "注册失败"))
        }
    }
    
    func loginUserNameValid(_ userName:String) -> Observable<Result> {
        if userName.characters.count == 0 {
            return Observable.just(Result.empty)
        }
        
        if checkHasUserName(userName) {
            return Observable.just(Result.ok(message: "用户名可用"))
        }
        
        return Observable.just(Result.failed(message: "用户名不存在"))
    }
    
    // 登录
    func login(_ username:String, password:String) -> Observable<Result> {
        
        guard let userDict = NSDictionary(contentsOfFile: filePath),
         let userPass = userDict.object(forKey: username)
        else {
            return Observable.just(Result.empty)
        }
        
        if (userPass as! String) == password {
            return Observable.just(Result.ok(message: "登录成功"))
        }else{
            return Observable.just(Result.failed(message: "密码错误"))
        }
    }
}

class SearchService {
    
    static let instance = SearchService();
    private init(){}
    
    // 获取联系人
    func getContacts() -> Observable<[Contact]> {
        let contactPath = Bundle.main.path(forResource: "Contact", ofType: "plist")
        let contactArr = NSArray(contentsOfFile: contactPath!) as! Array<[String:String]>
        
        var contacts = [Contact]()
        for contactDict in contactArr {
            let contact = Contact(name:contactDict["name"]!, phone: contactDict["phone"]!)
            contacts.append(contact)
        }
        
        return Observable.just(contacts).observeOn(MainScheduler.instance)
    }
    
    func getContacts(withName name: String) -> Observable<[Contact]> {
        if name == "" {
            return getContacts()
        }
        
        let contactPath = Bundle.main.path(forResource: "Contact", ofType: "plist")
        let contactArr = NSArray(contentsOfFile: contactPath!) as! Array<[String:String]>
        
        var contacts = [Contact]()
        for contactDict in contactArr {
            if contactDict["name"]!.contains(name) {
                let contact = Contact(name:contactDict["name"]!, phone: contactDict["phone"]!)
                contacts.append(contact)
            }
        }
        
        return Observable.just(contacts).observeOn(MainScheduler.instance)
    }

}
