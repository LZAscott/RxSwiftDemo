//
//  ListViewModel.swift
//  RxSwiftDemo
//
//  Created by Scott_Mr on 2017/7/26.
//  Copyright © 2017年 Scott. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ListViewModel {
    
    var models:Driver<[Contact]>
    
    init(with searchText:Observable<String>, service:SearchService){
        models = searchText.debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { text in
                return service.getContacts(withName: text)
            }.asDriver(onErrorJustReturn:[])
    }
}
