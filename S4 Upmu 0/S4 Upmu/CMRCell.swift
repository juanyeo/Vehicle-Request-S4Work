//
//  CMRCell.swift
//  S4 Upmu
//
//  Created by juan on 2020/07/14.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit

protocol CMRCellDelegate {
    func didTapHistory(cmr: cmrRequest)
    func didTapEdit(cmr: cmrRequest)
}

class CMRCell: UITableViewCell {
    
    // Cell Main Components
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var ExtendedView: UIView!
    
    // Header View Components
    @IBOutlet weak var statusColor: UIView!
    @IBOutlet weak var statusColor2: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var moveSummaryLabel: UILabel!
    @IBOutlet weak var pickupTimeLabel: UILabel!
    @IBOutlet weak var travelTypeImage: UIImageView!
    
    // Extended View Components
    @IBOutlet weak var busPaxLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var pocLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var msnLabel: UILabel!
    
    @IBOutlet weak var upperDot: UIView!
    @IBOutlet weak var horizonBox: UIView!
    @IBOutlet weak var verticBox: UIView!
    @IBOutlet weak var horizonXBox: UIView!
    @IBOutlet weak var verticXBox: UIView!
    
    @IBOutlet weak var horizonBoxWidth: NSLayoutConstraint!
    @IBOutlet weak var verticalBoxHeight: NSLayoutConstraint!
    @IBOutlet weak var horizonBoxTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var verticBoxTrailingAnchor: NSLayoutConstraint!
    @IBOutlet weak var horizonBoxTrailingAnchor: NSLayoutConstraint!
    @IBOutlet weak var verticBoxTopAnchor: NSLayoutConstraint!
    
    
    var requestInstance: cmrRequest!
    var delegate: CMRCellDelegate?
    let dateFormatter = DateFormatter()
    let calender = Calendar.current
    var workingDays: [Int] = []
    
    @IBAction func historyTapped(_ sender: UIButton) {
        delegate?.didTapHistory(cmr: requestInstance)
    }
    
    @IBAction func updateTapped(_ sender: UIButton) {
        delegate?.didTapEdit(cmr: requestInstance)
    }
    
    func setRequestData(request: cmrRequest) {
        requestInstance = request
    }
    
    func setCMRCell(request: cmrRequest) {
        
        upperDot.layer.cornerRadius = 7
        horizonBox.layer.cornerRadius = 7
        verticBox.layer.cornerRadius = 7
        horizonXBox.layer.cornerRadius = 7
        verticXBox.layer.cornerRadius = 7
        
        switch request.status {
        case "Approved":
            statusLabel.text = "Approved"
            statusLabel.textColor = UIColor(red: 114/255, green: 204/255, blue: 20/255, alpha: 1.0)
            upperDot.backgroundColor = .none
            horizonXBox.backgroundColor = .none
            verticXBox.backgroundColor = .none
            horizonBox.backgroundColor = UIColor(red: 114/255, green: 204/255, blue: 20/255, alpha: 1.0)
            verticBox.backgroundColor = UIColor(red: 114/255, green: 204/255, blue: 20/255, alpha: 1.0)
            horizonBoxTopAnchor.constant = 27
        case "Disapproved":
            statusLabel.text = "Disapproved"
            statusLabel.textColor = UIColor(red: 242/255, green: 89/255, blue: 59/255, alpha: 1.0)
            upperDot.backgroundColor = .none
            horizonBox.backgroundColor = .none
            verticBox.backgroundColor = .none
            horizonXBox.backgroundColor = UIColor(red: 242/255, green: 89/255, blue: 59/255, alpha: 1.0)
            verticXBox.backgroundColor = UIColor(red: 242/255, green: 89/255, blue: 59/255, alpha: 1.0)
            horizonXBox.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
            verticXBox.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        case "Pending":
            statusLabel.text = "Pending"
            statusLabel.textColor = UIColor(red: 244/255, green: 143/255, blue: 74/255, alpha: 1.0)
            upperDot.backgroundColor = .none
            horizonBox.backgroundColor = .none
            verticBox.backgroundColor = UIColor(red: 244/255, green: 143/255, blue: 74/255, alpha: 1.0)
            horizonXBox.backgroundColor = .none
            verticXBox.backgroundColor = .none
        case "Contact":
            statusLabel.text = "Contact"
            statusLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            upperDot.backgroundColor = .none
            horizonBox.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            verticBox.backgroundColor = .none
            horizonXBox.backgroundColor = .none
            verticXBox.backgroundColor = .none
            horizonBoxTopAnchor.constant = 5
        case "Submitted":
            statusLabel.text = "Submitted"
            statusLabel.textColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
            upperDot.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
            horizonBox.backgroundColor = .none
            verticBox.backgroundColor = .none
            horizonXBox.backgroundColor = .none
            verticXBox.backgroundColor = .none
        case "CBU":
            statusLabel.text = "CBU"
            statusLabel.textColor = UIColor(red: 143/255, green: 180/255, blue: 255/255, alpha: 1.0)
            upperDot.backgroundColor = .none
            horizonBox.backgroundColor = UIColor(red: 143/255, green: 180/255, blue: 255/255, alpha: 1.0)
            verticBox.backgroundColor = .none
            horizonXBox.backgroundColor = .none
            verticXBox.backgroundColor = .none
            horizonBoxTopAnchor.constant = 5
        default:
            statusLabel.text = "Unsubmitted"
            statusLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            upperDot.backgroundColor = .none
            horizonBox.backgroundColor = .none
            verticBox.backgroundColor = .none
            horizonXBox.backgroundColor = .none
            verticXBox.backgroundColor = .none
        }
        
        // Set travelTypeImage
        if request.isRoundTrip == 1 {
            travelTypeImage.image = UIImage(named: "return-64")
        } else {
            travelTypeImage.image = UIImage(named: "arrow-64")
        }
        if workingDays.count == 4 {
            checkUrgent(request: request)
        }
        
        // Set unitLabel, pickupTimeLabel, moveSummaryLabel
        unitLabel.text = request.unit
        pickupTimeLabel.text = request.departTime
        var originText = ""
        var destinationText = ""
        if request.originBLDG == "" {
            if request.originDetail == "" || request.originDetail == "Detail" {
                originText = request.originCamp
            } else {
                originText = request.originDetail + ", " + request.originCamp
            }
        } else {
            if request.originDetail == "" || request.originDetail == "Detail" {
                originText = "# " + request.originBLDG + ", " + request.originCamp
            } else {
                originText = "# " + request.originBLDG + " " +  request.originDetail + ", " + request.originCamp
            }
        }
        if request.destinationBLDG == "" {
            if request.destinationDetail == "" || request.destinationDetail == "Detail" {
                destinationText = request.destinationCamp
            } else {
                destinationText = request.destinationDetail + ", " + request.destinationCamp
            }
        } else {
            if request.destinationDetail == "" || request.destinationDetail == "Detail" {
                destinationText = "# " + request.destinationBLDG + ", " + request.destinationCamp
            } else {
                destinationText = "# " + request.destinationBLDG + " " +  request.destinationDetail + ", " + request.destinationCamp
            }
        }
        moveSummaryLabel.text = originText + " => " + destinationText
        
        // Set others (Extended View)
        if request.issuedTruck == 1 {
            busPaxLabel.text = String(request.quantity) + " Bus, " + String(request.pax) + " Pax" + ", Baggage Truck"
        } else {
            busPaxLabel.text = String(request.quantity) + " Bus, " + String(request.pax) + " Pax"
        }
        originLabel.text = originText
        destinationLabel.text = destinationText
        pocLabel.text = request.pocName + " (" + request.pocNumber + ")"
        dateLabel.text = request.date
        timeLabel.text = request.departTime + " - " + request.arrivalTime
        //msnLabel.text = request.MSN
    }
    
    func checkUrgent(request: cmrRequest) {
        // Submitted, Unsubmitted, Pending -> Within 1 working days - Error
        // Submitted, Unsubmitted -> Within 7 working days - Warning
        // Pending -> Within 3 working days - Warning
        
        var curDate: Int = workingDays[3]
        let start: Int = request.dateInNum
        if start < curDate {
            return
        }
        let status = request.status
        
        if status == "Unsubmitted" || status == "Submitted" {
            if start <= workingDays[0] {
                // Error
                travelTypeImage.image = UIImage(systemName: "timer")
                travelTypeImage.tintColor = UIColor(red: 242/255, green: 89/255, blue: 59/255, alpha: 1.0)
            }
            else if start <= workingDays[2] {
                // Warning
                //travelTypeImage.image = UIImage(systemName: "timer")
                //travelTypeImage.tintColor = UIColor(red: 244/255, green: 143/255, blue: 74/255, alpha: 1.0)
            }
        }
        else if status == "Pending" {
            if start <= workingDays[0] {
                // Error
                travelTypeImage.image = UIImage(systemName: "timer")
                travelTypeImage.tintColor = UIColor(red: 242/255, green: 89/255, blue: 59/255, alpha: 1.0)
            }
            else if start <= workingDays[1] {
                // Warning
                travelTypeImage.image = UIImage(systemName: "timer")
                travelTypeImage.tintColor = UIColor(red: 244/255, green: 143/255, blue: 74/255, alpha: 1.0)
            }
        }
        
    }
}
