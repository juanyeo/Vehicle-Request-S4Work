//
//  TMPDetailViewController.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/27.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit

class TMPDetailViewController: UIViewController {
    
    // Header View
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    // Extended View
    @IBOutlet weak var extendedViewHeight: NSLayoutConstraint!
    @IBOutlet weak var extendedLineHeight: NSLayoutConstraint!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var destinLabel: UILabel!
    @IBOutlet weak var pocLabel: UILabel!
    @IBOutlet weak var foldUpDownButton: UIButton!
    var folded = true
    
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
    
    @IBOutlet weak var tableView: UITableView!
    var tmprequest = [tmpRequest]()
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
        unitLabel.text = tmprequest[0].unit
        startDateLabel.text = tmprequest[0].startDate
        endDateLabel.text = tmprequest[0].endDate
        
        quantityLabel.text = String(tmprequest[0].quantity) + " " + tmprequest[0].type + ", " + String(tmprequest[0].pax) + " Pax"
        destinLabel.text = tmprequest[0].destination
        pocLabel.text = tmprequest[0].user
        setStatusLabels(request: tmprequest[0])
        
        extendedViewHeight.constant = 40
        foldUpDownButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)
    }
    
    @IBAction func foldUpDownButtonTapped(_ sender: Any) {
        if folded {
            let count = tmprequest[0].status.count
            switch count {
            case 1:
                extendedViewHeight.constant = 176
                extendedLineHeight.constant = 116
            case 2:
                extendedViewHeight.constant = 202
                extendedLineHeight.constant = 142
            case 3:
                extendedViewHeight.constant = 228
                extendedLineHeight.constant = 168
            case 4:
                extendedViewHeight.constant = 254
                extendedLineHeight.constant = 194
            default:
                extendedViewHeight.constant = 280
                extendedLineHeight.constant = 220
            }
            //extendedViewHeight.constant = 217
            foldUpDownButton.setImage(UIImage(systemName: "arrow.up"), for: .normal)
            folded = false
        } else {
            extendedViewHeight.constant = 40
            foldUpDownButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)
            folded = true
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

extension TMPDetailViewController: UITableViewDelegate, UITableViewDataSource {
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
