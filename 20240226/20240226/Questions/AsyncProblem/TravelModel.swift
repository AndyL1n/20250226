//
//  TravelModel.swift
//  20240226
//
//  Created by Andy on 2025/2/25.
//

/// 航班 Model
struct FlightModel: Codable {
    let passenger: String
    let flight: String
}

/// 酒店 Model
struct HotelModel: Codable {
    let passenger: String
    let hotel: String
}

/// 景點 Model
struct SightModel: Codable {
    let passenger: String
    let sight: String
}


/// 旅客資訊 Model
struct PassengerDetailModel {
    let passenger: String
    var flights: [String] = []
    var hotels: [String] = []
    var sights: [String] = []
}
