//
//  TMPAddViewController.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/22.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit
import Firebase
import FSCalendar

class TMPAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var unitTitle: UILabel!
    @IBOutlet weak var vehicleTitle: UILabel!
    @IBOutlet weak var paxTitle: UILabel!
    @IBOutlet weak var userTitle: UILabel!
    @IBOutlet weak var destinTitle: UILabel!
    @IBOutlet weak var officeTitle: UILabel!
    @IBOutlet weak var sendDateTitle: UILabel!
    
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var paxTextField: UITextField!
    let toolbar = UIToolbar()
    let datePicker = UIDatePicker()
    @IBOutlet weak var sendDateTextField: UITextField!
    
    
    // FSCalendar Objects
    @IBOutlet weak var calendar: FSCalendar!
    private var firstDate: Date?
    private var lastDate: Date?
    private var datesRange: [Date]?
    let dateFormatter = DateFormatter()
    let curCalender = Calendar.current
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    
    @IBOutlet weak var rankTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var destinPickTextField: UITextField!
    @IBOutlet weak var destinWriteTextField: UITextField!
    @IBOutlet weak var officeSegment: UISegmentedControl!
    
    let bottomLine1 = CALayer()
    let bottomLine2 = CALayer()
    let bottomLine3 = CALayer()
    let bottomLine4 = CALayer()
    let bottomLine5 = CALayer()
    let bottomLine6 = CALayer()
    let bottomLine7 = CALayer()
    let bottomLine8 = CALayer()
    let bottomLine9 = CALayer()
    
    let unitPicker = UIPickerView()
    let units = ["3 ABCD", "1-41 EF", "5-92 GH", "65 IJK", "3-5 LMN", "8-97 OP", "9-32 QR", "3-8 ST", "462 UVW"]
    let typePicker = UIPickerView()
    let types = ["Van", "SUV", "Sedan", "Bongo", "Truck", "Bus", "Reefer", "TMP"]
    let rankPicker = UIPickerView()
    let ranks = ["RK1", "RK2", "RK3", "RK4", "NK1", "NK2", "NK3", "NK4"]
    let destinPicker = UIPickerView()
    let destins: [String] = ["", "Singapore", "Germany", "US", "Japan", "India", "France", "Portugal", "Thailand"]
    
    var unitData: Int = 0
    var typeData: Int = 0
    var rankData: Int = 0
    var destinPickerData: Int = 0
    var userData: String = ""
    var quantityData: Int = 1
    var paxData: Int = 8
    var destinData: String = ""
    var officeData: String = "Seoul"
    var dateData: String = ""
    var new_id = ""
    
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewComponents()
    }
    
    func setViewComponents() {
        addBottomLines()
        setDelegate()
        
        calendar.delegate = self
        calendar.dataSource = self
        calendar.allowsMultipleSelection = true
        calendar.appearance.headerTitleFont = UIFont(name: "Roboto-Regular", size: 15)
        calendar.appearance.headerTitleColor = UIColor.darkGray
        calendar.appearance.selectionColor = UIColor.black
        calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        
        unitTextField.inputView = unitPicker
        quantityTextField.keyboardType = UIKeyboardType.numberPad
        typeTextField.inputView = typePicker
        paxTextField.keyboardType = UIKeyboardType.numberPad
        rankTextField.inputView = rankPicker
        nameTextField.autocorrectionType = UITextAutocorrectionType.no
        destinPickTextField.inputView = destinPicker
        destinWriteTextField.autocorrectionType = UITextAutocorrectionType.no
        sendDateTextField.inputAccessoryView = toolbar
        sendDateTextField.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(textfield:)), for: .valueChanged)
        dateFormatter.dateFormat = "dd MMM yy"
        let curDate = dateFormatter.string(from: Date())
        sendDateTextField.placeholder = curDate
        
        daysLabel.isHidden = true
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        if dateData == "" {
            print("필수데이터 입력되지 않음")
            return
        }
        
        let inDate = dateData.components(separatedBy: " - ")
        
        let term = (officeData == "Seoul") ? 14 : 7
        let statusDates = splitDates(start: inDate[0], end: inDate[1], term: term)
        
        var status: [String] = []
        for i in 0..<statusDates.count {
            status.append("Submitted")
        }
        
        if let nameText = nameTextField.text, !nameText.isEmpty {
            userData = ranks[rankData] + " " + nameText
        }
        
        if let quantityText = quantityTextField.text, !quantityText.isEmpty {
            quantityData = Int(quantityText)!
        }
        
        if let paxText = paxTextField.text, !paxText.isEmpty {
            paxData = Int(paxText)!
        }
        
        if let destinWriteText = destinWriteTextField.text, !destinWriteText.isEmpty {
            destinData = destinWriteText
        }
        
        if let destinPickText = destinPickTextField.text, !destinPickText.isEmpty {
            destinData = destinPickText
            if let destinWriteText = destinWriteTextField.text, !destinWriteText.isEmpty {
                destinData = destinWriteText + ", " + destinPickText
            }
        }
        
        let new_tmp = ["statusDates": statusDates, "status": status, "unit": units[unitData], "type": types[typeData], "startDate": inDate[0], "startInNum": dateToInt(date: inDate[0]), "endDate": inDate[1], "endInNum": dateToInt(date: inDate[1]), "user": userData, "quantity": quantityData, "pax": paxData, "destination": destinData, "office": officeData, "MSN": ""] as [String : Any]
        
        self.ref.child("tmp").childByAutoId().setValue(new_tmp)
        
        let query = self.ref.child("tmp").queryOrdered(byChild: "startDate").queryEqual(toValue: inDate[0])
        dateFormatter.dateFormat = "dd MMM yy HH:mm"
        let curDate = dateFormatter.string(from: Date())
        
        query.observeSingleEvent(of: .value) { (snapshotGroup) in
            if let snapshots = snapshotGroup.children.allObjects as? [DataSnapshot] {
                    for snapshot in snapshots {
                        if let data = snapshot.value as? [String:AnyObject] {
                            let date = data["startDate"] as! String
                            let unit = data["unit"] as! String
                            let type = data["type"] as! String
                            let user = data["user"] as! String
                            let MSN = data["MSN"] as! String
                            if unit == self.units[self.unitData] && type == self.types[self.typeData] && user == self.userData && MSN == "" {
                                self.new_id = snapshot.key
                            }
                        }
                    }
                }
                let history_text = "TMP request For " + self.units[self.unitData] + " on " + inDate[0] + " is Submitted"
                let status_history = ["type": "status", "isCMR": 0, "requestid": self.new_id, "requestunit": self.units[self.unitData], "requestdate": inDate[0], "key": [""], "value": ["", "Submitted"], "date": curDate, "sender": "", "text": history_text] as [String : Any]
                self.ref.child("history").childByAutoId().setValue(status_history)
            }
            dateFormatter.dateFormat = "dd MMM yy"
            
            self.navigationController?.popToRootViewController(animated: true)
        }
        /*
        query.observe(.value) { (snapshotGroup) in
            if let snapshots = snapshotGroup.children.allObjects as? [DataSnapshot] {
                for snapshot in snapshots {
                    if let data = snapshot.value as? [String:AnyObject] {
                        let date = data["startDate"] as! String
                        let unit = data["unit"] as! String
                        let type = data["type"] as! String
                        let user = data["user"] as! String
                        let MSN = data["MSN"] as! String
                        if unit == self.units[self.unitData] && type == self.types[self.typeData] && user == self.userData && MSN == "" {
                            self.new_id = snapshot.key
                        }
                    }
                }
            }
            let history_text = "TMP request For " + self.units[self.unitData] + " on " + inDate[0] + " is Submitted"
            let status_history = ["type": "status", "isCMR": 0, "requestid": self.new_id, "requestunit": self.units[self.unitData], "requestdate": inDate[0], "key": [""], "value": ["", "Submitted"], "date": curDate, "sender": "", "text": history_text] as [String : Any]
            self.ref.child("history").childByAutoId().setValue(status_history)
        }
        dateFormatter.dateFormat = "dd MMM yy"
        
        self.navigationController?.popToRootViewController(animated: true) */
    
    @IBAction func officeChanged(_ sender: Any) {
        switch officeSegment.selectedSegmentIndex {
        case 0:
            officeData = "Seoul"
        case 1:
            officeData = "Busan"
        default:
            break
        }
    }
    
    // Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == unitPicker {
            return units.count
        }
        else if pickerView == typePicker {
            return types.count
        }
        else if pickerView == rankPicker {
            return ranks.count
        }
        else if pickerView == destinPicker {
            return destins.count
        } else { return 1 }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == unitPicker {
            return units[row]
        }
        else if pickerView == typePicker {
            return types[row]
        }
        else if pickerView == rankPicker {
            return ranks[row]
        }
        else if pickerView == destinPicker {
            return destins[row]
        } else { return "Default" }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let defaultView = UIView()
        defaultView.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
        label.textAlignment = .center
        if pickerView == unitPicker {
            label.text = units[row]
        }
        else if pickerView == typePicker {
            label.text = types[row]
        }
        else if pickerView == rankPicker {
            label.text = ranks[row]
        }
        else if pickerView == destinPicker {
            label.text = destins[row]
        } else { }
        label.font = UIFont(name: "Roboto", size: 20)
        
        defaultView.addSubview(label)
        return defaultView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == unitPicker {
            unitData = row
            unitTextField.text = units[row]
            unitTextField.resignFirstResponder()
        }
        else if pickerView == typePicker {
            typeData = row
            typeTextField.text = types[row]
            typeTextField.resignFirstResponder()
        }
        else if pickerView == rankPicker {
            rankData = row
            rankTextField.text = ranks[row]
            rankTextField.resignFirstResponder()
        }
        else if pickerView == destinPicker {
            destinPickerData = row
            destinPickTextField.text = destins[row]
            destinPickTextField.resignFirstResponder()
        } else { }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case unitTextField:
            if let unitText = unitTextField.text, unitText.isEmpty {
                break
            }
            bottomLine1.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            unitTitle.textColor = UIColor.systemGray
        case quantityTextField:
            if let quantityText = quantityTextField.text, !quantityText.isEmpty {
                break
            }
            if let typeText = typeTextField.text, typeText.isEmpty {
                bottomLine2.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
            vehicleTitle.textColor = UIColor.systemGray
        case typeTextField:
            if let typeText = typeTextField.text, typeText.isEmpty {
                break
            }
            if let quantityText = quantityTextField.text, !quantityText.isEmpty {
                bottomLine2.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
            vehicleTitle.textColor = UIColor.systemGray
        case paxTextField:
            if let paxText = paxTextField.text, paxText.isEmpty {
                break
            }
            bottomLine3.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            paxTitle.textColor = UIColor.systemGray
        case rankTextField:
            if let rankText = rankTextField.text, rankText.isEmpty {
                break
            }
            bottomLine5.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            userTitle.textColor = UIColor.systemGray
        case nameTextField:
            if let nameText = nameTextField.text, nameText.isEmpty {
                break
            }
            bottomLine6.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            userTitle.textColor = UIColor.systemGray
        case destinPickTextField:
            if let destinPickText = destinPickTextField.text, destinPickText.isEmpty {
                break
            }
            bottomLine7.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            destinTitle.textColor = UIColor.systemGray
        case destinWriteTextField:
            if let destinWriteText = destinWriteTextField.text, destinWriteText.isEmpty {
                break
            }
            bottomLine8.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            destinTitle.textColor = UIColor.systemGray
        default:
            if let sendDateText = sendDateTextField.text, sendDateText.isEmpty {
                break
            }
            bottomLine9.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            sendDateTitle.textColor = UIColor.systemGray
        }
    }
    
    func dateToInt(date: String) -> Int {
        dateFormatter.dateFormat = "dd MMM yy"
        let basicDate = dateFormatter.date(from: "01 JAN 20")
        let inputDate = dateFormatter.date(from: date)
        let interval = curCalender.dateComponents([.day], from: basicDate!, to: inputDate!)
        return interval.day!
    }
    
    func splitDates(start: String, end: String, term: Int) -> [String] {
        dateFormatter.dateFormat = "dd MMM yy"
        var startD: Date = dateFormatter.date(from: start)!
        var endD: Date = dateFormatter.date(from: end)!
        var dateComponent = DateComponents()
        var oneDayComponent = DateComponents()
        dateComponent.day = term - 1
        oneDayComponent.day = 1
        var dateArray: [String] = []
        
        while true {
            let nextD: Date = curCalender.date(byAdding: dateComponent, to: startD)!
            var order = curCalender.compare(nextD, to: endD, toGranularity: .day)
            
            if order == .orderedAscending {
                let rangeString: String = dateFormatter.string(from: startD) + " - " + dateFormatter.string(from: nextD)
                dateArray.append(rangeString)
                startD = curCalender.date(byAdding: oneDayComponent, to: nextD)!
            }
            else if order == .orderedDescending {
                let rangeString: String = dateFormatter.string(from: startD) + " - " + dateFormatter.string(from: endD)
                dateArray.append(rangeString)
                break
            }
            else {
                let rangeString: String = dateFormatter.string(from: startD) + " - " + dateFormatter.string(from: endD)
                dateArray.append(rangeString)
                break
            }
        }
        return dateArray
    }
    
    @objc func dateChanged(textfield: UITextField) {
        dateFormatter.dateFormat = "dd MMM yy"
        sendDateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    func addBottomLines() {
        bottomLine1.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine1.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        unitTextField.layer.addSublayer(bottomLine1)
        bottomLine2.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine2.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        quantityTextField.layer.addSublayer(bottomLine2)
        bottomLine3.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine3.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        paxTextField.layer.addSublayer(bottomLine3)
        bottomLine4.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine4.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        dateLabel.layer.addSublayer(bottomLine4)
        bottomLine5.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine5.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        rankTextField.layer.addSublayer(bottomLine5)
        bottomLine6.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine6.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        nameTextField.layer.addSublayer(bottomLine6)
        bottomLine7.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine7.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        destinPickTextField.layer.addSublayer(bottomLine7)
        bottomLine8.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine8.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        destinWriteTextField.layer.addSublayer(bottomLine8)
        bottomLine9.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine9.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        sendDateTextField.layer.addSublayer(bottomLine9)
    }
    
    func setDelegate() {
        unitPicker.delegate = self
        unitPicker.dataSource = self
        typePicker.delegate = self
        typePicker.dataSource = self
        rankPicker.delegate = self
        rankPicker.dataSource = self
        destinPicker.delegate = self
        destinPicker.dataSource = self
        
        unitTextField.delegate = self
        quantityTextField.delegate = self
        typeTextField.delegate = self
        paxTextField.delegate = self
        rankTextField.delegate = self
        nameTextField.delegate = self
        destinPickTextField.delegate = self
        destinWriteTextField.delegate = self
        sendDateTextField.delegate = self
    }
    
}



extension TMPAddViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        callSelectedDates()
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            return
        }
        
        // Date Range Selected
        if firstDate != nil && lastDate == nil {
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                return
            }
            
            let range = getRange(from: firstDate!, to: date)
            lastDate = range.last
            
            dateFormatter.dateFormat = "dd MMM"
            let firstString = dateFormatter.string(from: firstDate!)
            let lastString = dateFormatter.string(from: lastDate!)
            dateLabel.text = firstString + " - " + lastString
            dateLabel.textColor = UIColor.black
            bottomLine4.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            dateFormatter.dateFormat = "dd MMM yy"
            let firstString2 = dateFormatter.string(from: firstDate!)
            let lastString2 = dateFormatter.string(from: lastDate!)
            dateData = firstString2 + " - " + lastString2
            
            daysLabel.isHidden = false
            let interval = curCalender.dateComponents([.day], from: firstDate!, to: lastDate!).day
            daysLabel.text = String(interval! + 1) + " Days"
            
            for day in range {
                calendar.select(day)
            }
            
            datesRange = range
            return
        }
        
        // Deselect Date Range
        if firstDate != nil && lastDate != nil {
            for day in calendar.selectedDates {
                calendar.deselect(day)
            }
            
            firstDate = nil
            lastDate = nil
            datesRange = []
            
            dateLabel.text = "Calendar"
            dateLabel.textColor = UIColor.systemGray4
            daysLabel.isHidden = true
            bottomLine4.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            dateData = ""
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // Deselect Date Range
        if firstDate != nil && lastDate != nil {
            for day in calendar.selectedDates {
                calendar.deselect(day)
            }
            
            firstDate = nil
            lastDate = nil
            datesRange = []
            
            dateLabel.text = "Calendar"
            dateLabel.textColor = UIColor.systemGray4
            daysLabel.isHidden = true
            bottomLine4.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            dateData = ""
        }
    }
    
    func getRange(from: Date, to: Date) -> [Date] {
        if from > to { return [Date]() }

        var tempDate = from
        var array = [tempDate]

        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }

        return array
    }
    
    func callSelectedDates() {
        print(calendar.selectedDates)
    }
}

