//
//  ChatRoomViewModel.swift
//  20240226
//
//  Created by Andy on 2025/2/24.
//

import Foundation
import RxSwift
import RxRelay


class ChatRoomViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let fetchMore: AnyObserver<Void>
    }
    
    struct Output {
        let messages: BehaviorRelay<[MessageModel]>
    }
    
    
    let input: Input
    let output: Output
    
    /// 加載更多聊天訊息
    private let fetchMoreSub = PublishSubject<Void>()
    
    /// 目前顯示的聊天訊息
    private let messages = BehaviorRelay<[MessageModel]>(value: [])
    
    /// 最新一則訊息的 TimeStamp
    private let latestMessageTimeStamp = BehaviorRelay<Int?>(value: nil)
    /// 最舊一則訊息的 Timestamp
    private let oldestMessageTimeStamp = BehaviorRelay<Int?>(value: nil)
    
    init() {
        
        self.input = Input(
            fetchMore: fetchMoreSub.asObserver()
        )
        
        self.output = Output(
            messages: messages
        )
        
        self.binding()
    }
    
    
    
    private func binding() {
        
        fetchMoreSub
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // 獲取舊的訊息
                self.fetchPreviousMessages()
            })
            .disposed(by: disposeBag)
        
    }
    
    
    /// 處理新接收到的訊息
    func handleNewMessage(model: ChatRoomModel) {
        
        var receiveMessages = model.messages
        
        // 判斷這組回傳的訊息是舊的還是新的
        guard let timeStamp = receiveMessages.first?.timestamp else { return }
        
        /// 當前顯示的所有訊息
        var currentMessages = self.messages.value
        
        
        switch model.receiveType {
        case .new:
            /// 先把這則最新訊息 TimeStamp 記錄下來
            self.latestMessageTimeStamp.accept(timeStamp)
            
            /// 插入新的訊息到最後面
            currentMessages.append(contentsOf: receiveMessages)
            self.messages.accept(currentMessages)

        case .old:
            self.oldestMessageTimeStamp.accept(timeStamp)
            
            /// 將舊的訊息放入最前面
            receiveMessages.append(contentsOf: currentMessages)
            self.messages.accept(receiveMessages)
        }
        
        
    }
    
    
    /// 獲取最新聊天訊息
    private func fetchLatestMessages() {
        
        // 透過最後取得的訊息TimeStamp，向後端取得是否有新的聊天訊息
        guard let latestTimeStamp = self.latestMessageTimeStamp.value else { return }
        
        // 透過後端定義的 Method ，帶入前端取得的最新一則訊息 TimeStamp 比對，是否有新的訊息要回傳給前端
        // websocket.request()
        // ...
    }
    
    /// 獲取之前的聊天訊息
    private func fetchPreviousMessages() {
        guard let oldestTimeStamp = self.oldestMessageTimeStamp.value else { return }
        
        // 透過後端定義的 Method ，帶入前端取得的最舊一則訊息 TimeStamp 比對，並以自定義的數量，取得該則訊息TimeStamp之前的若干數量訊息
        // websocket.request()
        // ...
    }
    
}

// MARK: - Mocking WebSocket Method
// 模擬 WebSocket 連線狀況
extension ChatRoomViewModel {
    
    /// WebSocket 已連線
    func websocketDidConnect() {
        self.fetchLatestMessages()
    }
    
    /// WebSocket 已斷線
    func websocketDidDisconnect() {
        
        // 重新連線
        // websocket.connect()
    }
    
    /// WebSocket 收到新的資料
    func websocketDidReceiveMessage() {
        
        /// 模擬原始 json String
        let textString: String = ""
        
        guard let data = textString.data(using: .utf8),
              let chatrommModel = try? JSONDecoder().decode(ChatRoomModel.self, from: data)
        else { return }
        
        self.handleNewMessage(model: chatrommModel)
    }
    
}
