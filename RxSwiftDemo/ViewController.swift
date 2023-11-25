//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by Shafiq  Ullah on 11/24/23.
//

import UIKit
import RxSwift
import RxCocoa

struct Product{
    let imageName : String
    let title : String
}

struct ProductViewModel{
    var items = PublishSubject<[Product]>()

    
    let products = [
        Product(imageName: "house", title: "Home"),
        Product(imageName: "gear", title: "Settings"),
        Product(imageName: "person.circle", title: "Profile"),
        Product(imageName: "bell", title: "Activity"),
    ]
    
    
    func fetchItems(){
        
        items.onNext(products)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let products_new = [
                Product(imageName: "gear", title: "Settings"),
                Product(imageName: "house", title: "Home"),
                Product(imageName: "gear", title: "Settings"),
                Product(imageName: "person.circle", title: "Profile"),
                Product(imageName: "house", title: "Home"),
                Product(imageName: "gear", title: "Settings"),
                Product(imageName: "person.circle", title: "Profile")
            ]
            
            items.onNext(products_new)
            items.onCompleted() // Basically shutdown the pipeline
        }
    }
    
}

class ViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tabel = UITableView()
        tabel.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tabel
    }()
    
    private var vm = ProductViewModel()
    
    private var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        bindTableData()
    }
    
    func bindTableData(){
        //Bind items to table
        // use bind when you are only interested on item events, nothing about error
        vm.items.bind(to:
                        tableView.rx.items(
                            cellIdentifier: "cell",
                            cellType: UITableViewCell.self)
        ){
            row, product, cell in
            cell.textLabel?.text = product.title
            cell.imageView?.image = UIImage(systemName: product.imageName)
        }.disposed(by: bag)
        
        
        
        vm.items.bind { products in
            print("Bind count \(products.count)")
        }.disposed(by: bag)
        
        
        //Use subscribe when you are interested both items, errors and all other staffs
        vm.items.subscribe { products in
            print("subscribe count \(products.count)")
        } onError: { error in
            
        } onCompleted: {
            
        } onDisposed: {
            
        }.disposed(by: bag)

        
        
        
        
        //Bind model selected handler// kind of SelectItemOnIndexpath
        tableView.rx.modelSelected(Product.self).bind { product in
            print(product.title)
        }.disposed(by: bag)
        
        
        //Fetch data
        vm.fetchItems()
    }
    
    
}

