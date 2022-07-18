//
//  TMPCell.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/21.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit

protocol TMPCellDelegate {
    func didTapHistory(tmp: tmpRequest)
    func didTapEdit(tmp: tmpRequest)
}

class TMPCell: UITableViewCell {
    
    // Cell Main Components
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var ExtendedView: UIView!
    
    // Header View Components
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var vehicleLabel: UILabel!
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var statusDot1: UIView!
    @IBOutlet weak var statusDot2: UIView!
    @IBOutlet weak var statusDot3: UIView!
    @IBOutlet weak var statusDot4: UIView!
    @IBOutlet weak var statusDot5: UIView!
    
    // Extended View Components
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var destinLabel: UILabel!
    @IBOutlet weak var officeLabel: UILabel!
    @IBOutlet weak var msnLabel: UILabel!
    
    // Status View Components
    @IBOutlet weak var termLabel1: UILabel!
    @IBOutlet weak var termLabel2: UILabel!
    @IBOutlet weak var termLabel3: UILabel!
    @IBOutlet weak var termLabel4: UILabel!
    @IBOutlet weak var termLabel5: UILabel!
    
    @IBOutlet weak var statLabel1: UILabel!
    @IBOutlet weak var statLabel2: UILabel!
    @IBOutlet weak var statLabel3: UILabel!
    @IBOutlet weak var statLabel4: UILabel!
    @IBOutlet weak var statLabel5: UILabel!
    
    @IBOutlet weak var historyYanchor: NSLayoutConstraint!
    @IBOutlet weak var updateYanchor: NSLayoutConstraint!
    
    
    var requestInstance: tmpRequest!
    var delegate: TMPCellDelegate?
    
    @IBAction func historyTapped(_ sender: UIButton) {
        delegate?.didTapHistory(tmp: requestInstance)
    }
    
    @IBAction func updateTapped(_ sender: UIButton) {
        delegate?.didTapEdit(tmp: requestInstance)
    }
    
    func setRequestData(request: tmpRequest) {
        requestInstance = request
    }
    
    //tmpRequest(statusDates: ["26 JUN 20 - 15 AUG 20", "26 JUN 20 - 15 AUG 20"], status: ["Approved", "Pending"], unit: "2 ABCT", type: "SEDAN", startDate: "26 JUN 20", startInNum: 177, endDate: "15 AUG 20", endInNum: 227, user: "1LT Yankee, Candle", quantity: 1, pax: 5, destination: "Sample Destination", office: "Humphreys", MSN: "")
    
    func setTMPCell(request: tmpRequest) {
        let statusPallete = ["Approved": UIColor(red: 114/255, green: 204/255, blue: 20/255, alpha: 1.0), "Disapproved": UIColor(red: 242/255, green: 89/255, blue: 59/255, alpha: 1.0), "Pending": UIColor(red: 244/255, green: 143/255, blue: 74/255, alpha: 1.0), "Contact": #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), "Submitted": #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1), "CBU": UIColor(red: 143/255, green: 180/255, blue: 255/255, alpha: 1.0), "Unsubmitted": UIColor.white]
        
        // Set status label
        let statusRep = setRepStatus(status: request.status)
        switch statusRep {
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
        
        // Set status dots
        statusDot1.layer.cornerRadius = 7
        statusDot2.layer.cornerRadius = 7
        statusDot3.layer.cornerRadius = 7
        statusDot4.layer.cornerRadius = 7
        statusDot5.layer.cornerRadius = 7
        
        var colorArray:[UIColor] = []
        var count = 5 - request.status.count
        
        for i in 0...4 {
            if count <= 0 {
                colorArray.append(statusPallete[request.status[4-i]]!)
            } else {
                colorArray.append(UIColor.white)
                count -= 1
            }
        }
        if colorArray.count == 5 {
            statusDot1.backgroundColor = colorArray[0]
            statusDot2.backgroundColor = colorArray[1]
            statusDot3.backgroundColor = colorArray[2]
            statusDot4.backgroundColor = colorArray[3]
            statusDot5.backgroundColor = colorArray[4]
        }
        
        //Set Vehicle Image
        switch request.type {
        case "Van":
            vehicleImage.image = UIImage(named: "VAN")
        case "SUV":
            vehicleImage.image = UIImage(named: "SUV")
        case "Sedan":
            vehicleImage.image = UIImage(named: "SEDAN")
        case "Bongo":
            vehicleImage.image = UIImage(named: "BONGO")
        case "Truck":
            vehicleImage.image = UIImage(named: "TRUCK")
        case "Bus":
            vehicleImage.image = UIImage(named: "BUS")
        case "Reefer":
            vehicleImage.image = UIImage(named: "REEFER")
        default:
            vehicleImage.image = UIImage(named: "VAN")
        }
        
        // Set other Header View components
        unitLabel.text = request.unit
        userLabel.text = request.user
        vehicleLabel.text = request.type
        //vehicleImage.image
        
        // Set Extended View
        quantityLabel.text = String(request.quantity) + " " + request.type + ", " + String(request.pax) + " Pax"
        dateLabel.text = request.startDate + " - " + request.endDate
        destinLabel.text = request.destination
        officeLabel.text = request.office
        //msnLabel.text = request.MSN
        
        // Set Status Labels
        setStatusLabels(request: request)
    }
    
    func setRepStatus(status: [String]) -> String {
        if status.contains("Submitted") {
            return "Submitted"
        }
        else if status.contains("Pending") {
            return "Pending"
        }
        else {
            let statusArray = status.reduce(into: [:]) { (counts, strings) in
                counts[strings, default: 0] += 1
            }
            return statusArray.sorted(by: {$0.value > $1.value}).first?.key ?? status.first!
        }
    }
    
    func setStatusLabels(request: tmpRequest) {
        let count = request.status.count
        
        switch count {
        case 1:
            termLabel2.isHidden = true
            statLabel2.isHidden = true
            termLabel3.isHidden = true
            statLabel3.isHidden = true
            termLabel4.isHidden = true
            statLabel4.isHidden = true
            termLabel5.isHidden = true
            statLabel5.isHidden = true
            historyYanchor.constant = 16
            updateYanchor.constant = 16
            
            termLabel1.text = request.statusDates[0]
            statLabel1.text = request.status[0]
        case 2:
            termLabel2.isHidden = false
            statLabel2.isHidden = false
            termLabel3.isHidden = true
            statLabel3.isHidden = true
            termLabel4.isHidden = true
            statLabel4.isHidden = true
            termLabel5.isHidden = true
            statLabel5.isHidden = true
            historyYanchor.constant = 42
            updateYanchor.constant = 42
            
            termLabel1.text = request.statusDates[0]
            statLabel1.text = request.status[0]
            termLabel2.text = request.statusDates[1]
            statLabel2.text = request.status[1]
        case 3:
            termLabel2.isHidden = false
            statLabel2.isHidden = false
            termLabel3.isHidden = false
            statLabel3.isHidden = false
            termLabel4.isHidden = true
            statLabel4.isHidden = true
            termLabel5.isHidden = true
            statLabel5.isHidden = true
            historyYanchor.constant = 68
            updateYanchor.constant = 68
            
            termLabel1.text = request.statusDates[0]
            statLabel1.text = request.status[0]
            termLabel2.text = request.statusDates[1]
            statLabel2.text = request.status[1]
            termLabel3.text = request.statusDates[2]
            statLabel3.text = request.status[2]
        case 4:
            termLabel2.isHidden = false
            statLabel2.isHidden = false
            termLabel3.isHidden = false
            statLabel3.isHidden = false
            termLabel4.isHidden = false
            statLabel4.isHidden = false
            termLabel5.isHidden = true
            statLabel5.isHidden = true
            historyYanchor.constant = 94
            updateYanchor.constant = 94
            
            termLabel1.text = request.statusDates[0]
            statLabel1.text = request.status[0]
            termLabel2.text = request.statusDates[1]
            statLabel2.text = request.status[1]
            termLabel3.text = request.statusDates[2]
            statLabel3.text = request.status[2]
            termLabel4.text = request.statusDates[3]
            statLabel4.text = request.status[3]
        default:
            termLabel2.isHidden = false
            statLabel2.isHidden = false
            termLabel3.isHidden = false
            statLabel3.isHidden = false
            termLabel4.isHidden = false
            statLabel4.isHidden = false
            termLabel5.isHidden = false
            statLabel5.isHidden = false
            historyYanchor.constant = 120
            updateYanchor.constant = 120
            
            termLabel1.text = request.statusDates[0]
            statLabel1.text = request.status[0]
            termLabel2.text = request.statusDates[1]
            statLabel2.text = request.status[1]
            termLabel3.text = request.statusDates[2]
            statLabel3.text = request.status[2]
            termLabel4.text = request.statusDates[3]
            statLabel4.text = request.status[3]
            termLabel5.text = request.statusDates[4]
            statLabel5.text = request.status[4]
        }
    }
    
}
