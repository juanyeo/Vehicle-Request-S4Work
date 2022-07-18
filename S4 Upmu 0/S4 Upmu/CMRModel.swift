//
//  CMRModel.swift
//  S4 Upmu
//
//  Created by juan on 2020/07/14.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import Foundation
import UIKit

class cmrRequest {
    var id: String
    var status: String
    var unit: String
    var date: String
    var dateInNum: Int //2020년 1월 1일 기준
    var departTime: String
    var arrivalTime: String
    var isRoundTrip: Int
    
    var originCamp: String
    var originBLDG: String
    var originDetail: String
    
    var destinationCamp: String
    var destinationBLDG: String
    var destinationDetail: String
    
    var quantity: Int
    var pax: Int
    var issuedTruck: Int
    var pocName: String
    var pocNumber: String
    var MSN: String
    
    init(id: String, status: String, unit: String, date: String, dateInNum: Int, departTime: String, arrivalTime: String, isRoundTrip: Int,  originCamp: String, originBLDG: String, originDetail: String, destinationCamp: String, destinationBLDG: String, destinationDetail: String, quantity: Int, pax: Int, issuedTruck: Int, pocName: String, pocNumber: String, MSN: String) {
        
        self.id = id
        self.status = status
        self.unit = unit
        self.date = date
        self.dateInNum = dateInNum
        self.departTime = departTime
        self.arrivalTime = arrivalTime
        self.isRoundTrip = isRoundTrip
        self.originCamp = originCamp
        self.originBLDG = originBLDG
        self.originDetail = originDetail
        self.destinationCamp = destinationCamp
        self.destinationBLDG = destinationBLDG
        self.destinationDetail = destinationDetail
        self.quantity = quantity
        self.pax = pax
        self.issuedTruck = issuedTruck
        self.pocName = pocName
        self.pocNumber = pocNumber
        self.MSN = MSN
    }
}
