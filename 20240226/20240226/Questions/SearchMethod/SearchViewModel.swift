//
//  SearchViewModel.swift
//  20240226
//
//  Created by Andy on 2025/2/24.
//

import Foundation

import Foundation
import RxSwift
import RxRelay


class SearchViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        /// 搜尋字串
        let searchString: AnyObserver<String?>
        /// 篩選類別
        let filterGenre: AnyObserver<String?>
    }
    
    struct Output {
        /// 當前顯示的書籍
        let currentBooks: BehaviorRelay<[BookModel]>
    }
    
    
    let input: Input
    let output: Output
    
    /// 搜尋字串
    private let searchStringSub = PublishSubject<String?>()
    /// 篩選類別
    private let filterGenreSub = PublishSubject<String?>()
    
    
    
    /// 目前顯示的書籍列表
    private let currentBooks = BehaviorRelay<[BookModel]>(value: [])
    /// 所有的書籍
    private let allBooks = BehaviorRelay<[BookModel]>(value: [])
    /// 搜尋字串
    private let searchString = BehaviorRelay<String?>(value: nil)
    /// 篩選類別
    private let filterGenre = BehaviorRelay<String?>(value: nil)
    
    
    
    init() {
        
        self.input = Input(
            searchString: searchStringSub.asObserver(),
            filterGenre: filterGenreSub.asObserver()
        )
        
        self.output = Output(
            currentBooks: currentBooks
        )
        
        self.getLocalBookList()
        
        self.binding()
    }
    
    
    private func binding() {
        
        searchStringSub
            .distinctUntilChanged()
            .bind(to: searchString)
            .disposed(by: disposeBag)
        
        filterGenreSub
            .distinctUntilChanged()
            .bind(to: filterGenre)
            .disposed(by: disposeBag)
        
        
        // 將所有書籍、篩選字串、篩選類別綁定再一起，處理相關邏輯在output出去顯示
        // 加入 debounce 降低頻繁的更新
        Observable
            .combineLatest(
                searchString,
                filterGenre,
                allBooks
            )
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] searchString, filterGenre, allBooks in
                guard let self = self else { return }
                /// 經過篩選後的結果
                let filterdBooks = self.handleBooksSearchText(books: allBooks, searchText: searchString, filterGenre: filterGenre)
                
                self.currentBooks.accept(filterdBooks)
            })
            .disposed(by: disposeBag)
        
    }
    
    /// 取得本地 json
    private func getLocalBookList() {
        
        guard let url = Bundle.main.url(forResource: "Books", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let books = try? JSONDecoder().decode([BookModel].self, from: data)
        else { return }
        
        self.allBooks.accept(books)
    }
    
    /// 處理書籍及篩選字串
    private func handleBooksSearchText(books: [BookModel], searchText: String?, filterGenre: String?) -> [BookModel] {
        let searchKeys = searchText?.lowercased().split(separator: "").map { String($0) } ?? []
        
        // 如果沒有搜尋字串，nil或空白
        let isSearchKeyEmpty = searchKeys.isEmpty
        
        return books.filter { book in
            
            let title = book.title.lowercased()
            
            /// 搜尋符合
            let isMatchSearch = isSearchKeyEmpty || searchKeys.allSatisfy { title.contains($0) }
            /// 類別篩選符合，nil 表示沒有篩選條件
            let isMatchGenre = book.genre == filterGenre || filterGenre?.isEmpty ?? true
            
            return isMatchSearch && isMatchGenre
        }
    }
}
