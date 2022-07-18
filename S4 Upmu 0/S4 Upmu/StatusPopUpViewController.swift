//
//  StatusPopUpViewController.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/23.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit
import Firebase

class StatusPopUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let statuses = ["Submitted", "Pending", "Approved", "Disapproved", "Contact", "CBU", "Unsubmitted"]
    var statusRow = 0
    var currentStatus = ""
    var requestid = ""
    var cmrrequestdata: cmrRequest?
    var tmprequestdata: tmpRequest?
    var origintmpdata: tmpRequest?
    var isCMR = true
    var indexOfCell = [-1, -1]
    var ref = Database.database().reference()
    let dateFormatter = DateFormatter()
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var popupStatusPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupStatusPicker.delegate = self
        popupStatusPicker.dataSource = self
        
        
        
        popupView.layer.masksToBounds = false
        popupView.layer.cornerRadius = 10
        
        if isCMR {
            if let status = cmrrequestdata?.status {
                statusRow = statuses.index(of: status)!
                popupStatusPicker.selectRow(statusRow, inComponent: 0, animated: false)
            }
        } else {
            if let status = tmprequestdata?.status[0] {
                statusRow = statuses.index(of: status)!
                popupStatusPicker.selectRow(statusRow, inComponent: 0, animated: false)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statuses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statuses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        statusRow = row
    }
    
    @IBAction func updateButtonAction(_ sender: Any) {
        if isCMR {
            ref.child("cmr").child(cmrrequestdata!.id).updateChildValues(["status" : statuses[statusRow]])
            dateFormatter.dateFormat = "dd MMM yy HH:mm"
            let history_text1 = "CMR request for " + cmrrequestdata!.unit
            let history_text2 = " on " + cmrrequestdata!.date
            let history_text3 = " is " + statuses[statusRow]
            let status_history = ["type": "status", "isCMR": 1, "requestid": cmrrequestdata?.id, "requestunit": cmrrequestdata?.unit, "requestdate": cmrrequestdata?.date, "key": [""], "value": [cmrrequestdata?.status, statuses[statusRow]], "date": dateFormatter.string(from: Date()), "sender": "", "text": history_text1+history_text2+history_text3] as [String : Any]
            self.ref.child("history").childByAutoId().setValue(status_history)
            dateFormatter.dateFormat = "dd MMM yy"
        } else {
            let statusDates = origintmpdata?.statusDates
            let status = origintmpdata?.status
            var new_status = status
            let statusDate = tmprequestdata?.statusDates[0]
            
            let index = statusDates?.firstIndex(of: statusDate!)
            new_status?[index!] = statuses[statusRow]
            ref.child("tmp").child(tmprequestdata!.id).updateChildValues(["status" : new_status])
            
            dateFormatter.dateFormat = "dd MMM yy HH:mm"
            let history_text1 = "TMP request for " + tmprequestdata!.unit
            let history_text2 = " on " + tmprequestdata!.startDate
            let history_text3 = " is " + statuses[statusRow]
            let status_history = ["type": "status", "isCMR": 0, "requestid": tmprequestdata?.id, "requestunit": tmprequestdata?.unit, "requestdate": tmprequestdata?.startDate, "key": [""], "value": [status![index!], statuses[statusRow]], "date": dateFormatter.string(from: Date()), "sender": "", "text": history_text1+history_text2+history_text3] as [String : Any]
            self.ref.child("history").childByAutoId().setValue(status_history)
            dateFormatter.dateFormat = "dd MMM yy"
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
