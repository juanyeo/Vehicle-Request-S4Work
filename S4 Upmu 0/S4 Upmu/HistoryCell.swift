//
//  HistoryCell.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/25.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var textBox: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textBoxTrailing: NSLayoutConstraint! // Right, 30
    @IBOutlet weak var textBoxLeading: NSLayoutConstraint! // Left, 100
    @IBOutlet weak var dtgLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var attachLabel: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var textViewTopAnchor: NSLayoutConstraint! // 4,24
    @IBOutlet weak var alertSignImage: UIImageView!
    
    func setHistoryCell(history: history) {
        
        if history.requestid == "" {
            attachLabel.isHidden = true
            dateLabel.isHidden = true
            dtgLabel.isHidden = true
        } else {
            dtgLabel.text = history.requestunit
            dateLabel.text = history.requestdate
            if history.isCMR == 1 {
                attachLabel.text = "CMR"
            } else {
                attachLabel.text = "TMP"
            }
            attachLabel.isHidden = false
            dateLabel.isHidden = false
            dtgLabel.isHidden = false
        }
        
        let dateSplit = history.date.components(separatedBy: " ")
        let dateText = dateSplit[0] + " " + dateSplit[1] + " " + dateSplit[3]
        //senderLabel.text = "Confirmed by " + history.sender + " at " + dateText
        senderLabel.text = "Confirmed by " + "Juan" + " at " + dateText
        textView.text = history.text
        
        if history.type == "alert" {
            alertSignImage.tintColor = UIColor.red
            textView.textColor = UIColor.red
        } else {
            alertSignImage.tintColor = UIColor.white
            textView.textColor = UIColor.black
        }
    }

}
