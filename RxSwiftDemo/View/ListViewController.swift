//
//  ListViewController.swift
//  RxSwiftDemo
//
//  Created by Scott_Mr on 2017/7/26.
//  Copyright © 2017年 Scott. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    var searchBarText:Observable<String> {
        return searchBar.rx.text.orEmpty.throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "联系人"
        
        let viewModel = ListViewModel(with: searchBarText, service: SearchService.instance)
        
        viewModel.models.drive(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)){(row, element, cell) in
            cell.textLabel?.text = element.name
            cell.detailTextLabel?.text = element.phone
        }.disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
