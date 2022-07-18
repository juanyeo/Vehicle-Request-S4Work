//
//  HistoryModel.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/25.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import Foundation

class history {
    var id: String
    var type: String
    var isCMR: Int
    var requestid: String
    var requestunit: String
    var requestdate: String
    var key: [String]
    var value: [String]
    var date: String
    var sender: String
    var text: String
    
    init(id: String, type: String, isCMR: Int, requestid: String, requestunit: String, requestdate: String, key: [String], value: [String], date: String, sender: String, text: String) {
        self.id = id
        self.type = type
        self.isCMR = isCMR
        self.requestid = requestid
        self.requestunit = requestunit
        self.requestdate = requestdate
        self.key = key
        self.value = value
        self.date = date
        self.sender = sender
        self.text = text
    }
}
