//
//  MessageModel.swift
//  20240226
//
//  Created by Andy on 2025/2/24.
//

import Foundation

struct ChatRoomModel: Codable {
    /// 用來判斷回傳回來的訊息是新的還是舊的
    let receiveType: ReceiveType
    /// 用來區分取得的聊天室ID
    let chatroomID: Int
    let messages: [MessageModel]
}


/// 聊天室訊息 Model
struct MessageModel: Codable {
    
    let content: String
    let author: String
    let timestamp: Int
    
}


/// 分頁取得聊天訊息 Request Model
struct LoadMoreRequestModel: Codable {
    let timestamp: Int
}


/// 訊息是否為新訊息或舊訊息
enum ReceiveType: Int, Codable {
    case new = 0
    case old
}
