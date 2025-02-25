//
//  ChatRoom.swift
//  20240226
//
//  Created by Andy on 2025/2/24.
//


import UIKit
import RxSwift

class ChatRoomViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    
    private let viewModel: ChatRoomViewModel = ChatRoomViewModel()
    
    private let tableView: UITableView = UITableView()
    private var dataSource: UITableViewDiffableDataSource<SectionType, MessageModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.binding()
    }
    
    
    private func binding() {
        
        viewModel.output.messages
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setup() {
        self.dataSource = UITableViewDiffableDataSource<SectionType, MessageModel>(tableView: tableView) { tableView, indexPath, message in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            // cell.messageLabel.text = message
            return cell
        }
    }
    
    
}
