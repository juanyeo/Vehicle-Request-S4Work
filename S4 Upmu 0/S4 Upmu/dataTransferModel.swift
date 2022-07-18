//
//  dataTransferModel.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/23.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import Foundation

class info {
    @objc dynamic var id: String? = nil
    @objc dynamic var isCMR: Bool = true
    @objc dynamic var status: String = ""
    
    func setInfo(id: String, isCMR: Bool, status: String) {
        self.id = id
        self.isCMR = isCMR
        self.status = status
    }
}
