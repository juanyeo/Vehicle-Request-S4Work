//
//  HistoryStatusCell.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/28.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit

class HistoryStatusCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    
    func setHistoryStatusCell(history: history) {
        switch history.value[1] {
            case "Approved":
                statusLabel.text = "Approved"
                statusLabel.textColor = UIColor(red: 114/255, green: 204/255, blue: 20/255, alpha: 1.0)
            case "Disapproved":
                statusLabel.text = "Disapproved"
                statusLabel.textColor = UIColor(red: 242/255, green: 89/255, blue: 59/255, alpha: 1.0)
            case "Pending":
                statusLabel.text = "Pending"
                statusLabel.textColor = UIColor(red: 244/255, green: 143/255, blue: 74/255, alpha: 1.0)
            case "Contact":
                statusLabel.text = "Contact"
                statusLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            case "Submitted":
                statusLabel.text = "Submitted"
                statusLabel.textColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
            case "CBU":
                statusLabel.text = "CBU"
                statusLabel.textColor = UIColor(red: 143/255, green: 180/255, blue: 255/255, alpha: 1.0)
            default:
                statusLabel.text = "Unsubmitted"
                statusLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        if history.isCMR == 1 {
            typeLabel.text = "CMR"
        } else {
            typeLabel.text = "TMP"
        }
        
        dateLabel.text = history.requestdate
        unitLabel.text = history.requestunit
        let dateSplit = history.date.components(separatedBy: " ")
        let dateText = dateSplit[0] + " " + dateSplit[1] + " " + dateSplit[3]
        senderLabel.text = "Confirmed by " + history.sender + " at " + dateText
    }

}
