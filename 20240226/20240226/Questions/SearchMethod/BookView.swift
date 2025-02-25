//
//  BookView.swift
//  20240226
//
//  Created by Andy on 2025/2/25.
//

import UIKit
import RxSwift


class BookViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    
    private let viewModel: SearchViewModel = SearchViewModel()
    
    private let tableView: UITableView = UITableView()
    private var dataSource: UITableViewDiffableDataSource<SectionType, BookModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.binding()
    }
    
    
    private func binding() {
        
        viewModel.output.currentBooks
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setup() {
        self.dataSource = UITableViewDiffableDataSource<SectionType, BookModel>(tableView: tableView) { tableView, indexPath, book in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            // cell.titleLabel.text = book.title
            // cell.authorLabel.text = book.author
            // cell.genreLabel.text = book.genre
            return cell
        }
    }
    
}

