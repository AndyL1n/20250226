//
//  AsyncProblem.swift
//  20240226
//
//  Created by Andy on 2025/2/25.
//

import Foundation
import RxSwift
import RxRelay

class TestAsyncViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let startFetch: AnyObserver<Void>
    }
    
    struct Output {
        let list: BehaviorRelay<[PassengerDetailModel]>
    }
    
    
    let input: Input
    let output: Output
    
    /// 加載更多聊天訊息
    private let startFetchSub = PublishSubject<Void>()
    
    /// 旅客資訊列表
    private let list = BehaviorRelay<[PassengerDetailModel]>(value: [])
    
    private let hotelList = BehaviorRelay<[HotelModel]>(value: [])
    private let flightList = BehaviorRelay<[FlightModel]>(value: [])
    private let sightList = BehaviorRelay<[SightModel]>(value: [])
    
    init() {
        
        self.input = Input(
            startFetch: startFetchSub.asObserver()
        )
        
        self.output = Output(
            list: list
        )
        
        self.binding()
    }
    
    private func binding() {
        
        startFetchSub
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.getHotelDetail()
                self.getSightDetail()
                self.getFlightDetail()
            })
            .disposed(by: disposeBag)
        
        
        Observable
            .combineLatest(
                hotelList,
                sightList,
                flightList
            )
            .subscribe(onNext: { [weak self] hotelList, sightList, flightList in
                guard let self = self else { return }
                
                var list = self.list.value
                
                list = self.handleFlightList(flightList: flightList, passengerList: list)
                
                list = self.handleHotelList(hotelList: hotelList, passengerList: list)
                
                list = self.handleSightList(sightList: sightList, passengerList: list)
                
                self.list.accept(list)
                
            })
            .disposed(by: disposeBag)
        
    }
    
    /// 處理酒店名單
    private func handleHotelList(hotelList: [HotelModel], passengerList: [PassengerDetailModel]) -> [PassengerDetailModel] {
        
        var list = passengerList
        
        hotelList.forEach { model in
            
            if var index = passengerList.firstIndex(where: { $0.passenger == model.passenger }) {
                list[index].hotels.append(model.hotel)
            } else {
                let passenger = PassengerDetailModel(passenger: model.passenger, hotels: [model.hotel])
                list.append(passenger)
            }
            
        }
        
        return list
        
    }
    
    /// 處理景點名單
    private func handleSightList(sightList: [SightModel], passengerList: [PassengerDetailModel]) -> [PassengerDetailModel] {
        
        var list = passengerList
        
        sightList.forEach { model in
            
            if var index = passengerList.firstIndex(where: { $0.passenger == model.passenger }) {
                list[index].sights.append(model.sight)
            } else {
                let passenger = PassengerDetailModel(passenger: model.passenger, sights: [model.sight])
                list.append(passenger)
            }
            
        }
        
        return list
        
    }
    
    /// 處理航班名單
    private func handleFlightList(flightList: [FlightModel], passengerList: [PassengerDetailModel]) -> [PassengerDetailModel] {
        
        var list = passengerList
        
        flightList.forEach { model in
            
            if var index = passengerList.firstIndex(where: { $0.passenger == model.passenger }) {
                list[index].flights.append(model.flight)
            } else {
                let passenger = PassengerDetailModel(passenger: model.passenger, flights: [model.flight])
                list.append(passenger)
            }
            
        }
        
        return list
        
    }
    
    
}


/// 模擬異步API請求
extension TestAsyncViewModel {
    
    fileprivate func getFlightDetail() {
        DispatchQueue.global().async {
            /*
             APIServer.requestFlightDetail() { [weak self] result in
                guard let self = self else { return }
                self.FlightioList.accept(result)
             }
             */
        }
        
    }
    
    
    
    fileprivate func getHotelDetail() {
        DispatchQueue.global().async {
            /*
             APIServer.requestHotelDetail() { [weak self] result in
                guard let self = self else { return }
                self.hotelList.accept(result)
             }
             */
        }
        
    }
    
    fileprivate func getSightDetail() {
        DispatchQueue.global().async {
            /*
             APIServer.requestSightDetail() { [weak self] result in
                guard let self = self else { return }
                self.sightList.accept(result)
             }
             */
        }
        
    }
    
}
