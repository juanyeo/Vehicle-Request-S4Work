//
//  CMRDetailViewController.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/27.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit
import Firebase

class CMRDetailViewController: UIViewController {
    
    // Header View
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var shortDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //Extended View
    @IBOutlet weak var extendedViewHeight: NSLayoutConstraint!
    @IBOutlet weak var boxPaxLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var pocLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var msnLabel: UILabel!
    @IBOutlet weak var foldUpDownButton: UIButton!
    var folded = true
    
    // Table View
    @IBOutlet weak var tableView: UITableView!
    var cmrrequest = [cmrRequest]()
    var histories = [history]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        setViewComponents()

        // Do any additional setup after loading the view.
    }
    
    func setViewComponents() {
        unitLabel.text = cmrrequest[0].unit
        shortDateLabel.text = cmrrequest[0].date
        
        switch cmrrequest[0].status {
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
        
        if cmrrequest[0].issuedTruck == 1 {
            boxPaxLabel.text = String(cmrrequest[0].quantity) + " Bus, " + String(cmrrequest[0].pax) + " Pax" + ", Baggage Truck"
        } else {
            boxPaxLabel.text = String(cmrrequest[0].quantity) + " Bus, " + String(cmrrequest[0].pax) + " Pax"
        }
        
        var originText = ""
        var destinationText = ""
        if cmrrequest[0].originBLDG == "" {
            if cmrrequest[0].originDetail == "" {
                originText = cmrrequest[0].originCamp
            } else {
                originText = cmrrequest[0].originDetail + ", " + cmrrequest[0].originCamp
            }
        } else {
            originText = "# " + cmrrequest[0].originBLDG + " " +  cmrrequest[0].originDetail + ", " + cmrrequest[0].originCamp
        }
        if cmrrequest[0].destinationBLDG == "" {
            if cmrrequest[0].destinationDetail == "" {
                destinationText = cmrrequest[0].destinationCamp
            } else {
                destinationText = cmrrequest[0].destinationDetail + ", " + cmrrequest[0].destinationCamp
            }
        } else {
            destinationText = "# " + cmrrequest[0].destinationBLDG + " " +  cmrrequest[0].destinationDetail + ", " + cmrrequest[0].destinationCamp
        }
        
        originLabel.text = originText
        destinationLabel.text = destinationText
        pocLabel.text = cmrrequest[0].pocName + " (" + cmrrequest[0].pocNumber + ")"
        dateLabel.text = cmrrequest[0].date
        timeLabel.text = cmrrequest[0].departTime + " - " + cmrrequest[0].arrivalTime
        msnLabel.text = cmrrequest[0].MSN
        
        extendedViewHeight.constant = 40
        foldUpDownButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)
    }
    
    @IBAction func foldUpDownButtonTapped(_ sender: Any) {
        if folded {
            extendedViewHeight.constant = 217
            foldUpDownButton.setImage(UIImage(systemName: "arrow.up"), for: .normal)
            folded = false
        } else {
            extendedViewHeight.constant = 40
            foldUpDownButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)
            folded = true
        }
    }
    
    
}

extension CMRDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let history = histories[indexPath.row]
        if history.type == "status" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyStatusCell")! as! HistoryStatusCell
            cell.setHistoryStatusCell(history: history)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell")! as! HistoryCell
            cell.setHistoryCell(history: history)
            return cell
        }
    }
}
