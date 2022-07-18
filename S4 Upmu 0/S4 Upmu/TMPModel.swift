//
//  TMPModel.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/21.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import Foundation
import UIKit

class tmpRequest {
    var id: String
    var statusDates: [String]
    var status: [String]
    var unit: String
    var type: String
    var startDate: String
    var startInNum: Int //2020년 1월 1일 기준
    var endDate: String
    var endInNum: Int //2020년 1월 1일 기준
    var user: String
    var quantity: Int
    var pax: Int
    var destination: String
    var office: String
    var MSN: String
    
    init(id: String, statusDates: [String], status: [String], unit: String, type: String, startDate: String, startInNum: Int, endDate: String, endInNum: Int, user: String, quantity: Int, pax: Int, destination: String, office: String, MSN: String) {
        
        self.id = id
        self.statusDates = statusDates
        self.status = status
        self.unit = unit
        self.type = type
        self.startDate = startDate
        self.startInNum = startInNum
        self.endDate = endDate
        self.endInNum = endInNum
        self.user = user
        self.quantity = quantity
        self.pax = pax
        self.destination = destination
        self.office = office
        self.MSN = MSN
    }
}
