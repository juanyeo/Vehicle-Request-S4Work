//
//  CMRAddViewController.swift
//  S4 Upmu
//
//  Created by juan on 2020/07/15.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit
import Firebase

class CMRAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var unitTitle: UILabel!
    @IBOutlet weak var dtgTitle: UILabel!
    @IBOutlet weak var originTitle: UILabel!
    @IBOutlet weak var destinTitle: UILabel!
    @IBOutlet weak var busTitle: UILabel!
    @IBOutlet weak var paxTitle: UILabel!
    @IBOutlet weak var truckTitle: UILabel!
    @IBOutlet weak var pocTitle: UILabel!
    @IBOutlet weak var sendDateTitle: UILabel!
    
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var timeGuideLabel: UILabel!
    @IBOutlet weak var originCampTextField: UITextField!
    @IBOutlet weak var originBldgTextField: UITextField!
    //@IBOutlet weak var originDetailTextField: UITextField!
    @IBOutlet weak var originDetailTextView: UITextView!
    @IBOutlet weak var destinCampTextField: UITextField!
    @IBOutlet weak var destinBldgTextField: UITextField!
    //@IBOutlet weak var destinDetailTextField: UITextField!
    @IBOutlet weak var destinDetailTextView: UITextView!
    @IBOutlet weak var busTextField: UITextField!
    @IBOutlet weak var paxTextField: UITextField!
    @IBOutlet weak var isTruckSwitch: UISwitch!
    @IBOutlet weak var pocNameTextField: UITextField!
    @IBOutlet weak var nameGuideLabel: UILabel!
    @IBOutlet weak var pocPhoneTextField: UITextField!
    @IBOutlet weak var phoneGuideLabel: UILabel!
    @IBOutlet weak var sendDateTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    let bottomLine1 = CALayer()
    let bottomLine2 = CALayer()
    let bottomLine3 = CALayer()
    let bottomLine4 = CALayer()
    let bottomLine5 = CALayer()
    let bottomLine6 = CALayer()
    let bottomLine7 = CALayer()
    let bottomLine8 = CALayer()
    let bottomLine9 = CALayer()
    let bottomLine10 = CALayer()
    let bottomLine11 = CALayer()
    let bottomLine12 = CALayer()
    let bottomLine13 = CALayer()
    let bottomLine14 = CALayer()
    
    let toolbar = UIToolbar()
    let unitPicker = UIPickerView()
    let units = ["3 ABCD", "1-41 EF", "5-92 GH", "65 IJK", "3-5 LMN", "8-97 OP", "9-32 QR", "3-8 ST", "462 UVW"]
    let datePicker = UIDatePicker()
    let sendDatePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let calender = Calendar.current
    let originCampPicker = UIPickerView()
    let destinCampPicker = UIPickerView()
    let camps: [[String]] = [["No Data", ""], ["Seoul", "Camp Seoul"], ["Incheon", "Camp Incheon"], ["Ulsan", "Camp Ulsan"], ["Jeju", "Camp Jeju"], ["Busan", "Camp Busan"], ["Suwon", "Camp Suwon"]]
    
    var unitData: Int = 0
    var departTimeData: String = ""
    var arrivalTimeData: String = ""
    var isRoundTripData: Int = 1
    var originData: Int = 0
    var destinData: Int = 0
    var originBldgData: String = ""
    var destinBldgData: String = ""
    var originDetailData: String = ""
    var destinDetailData: String = ""
    var quantityData: Int = 1
    var paxData: Int = 25
    var truckData: Int = 0
    var pocNameData: String = ""
    var pocPhoneData: String = ""
    var new_id = ""
    
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewComponents()
        dateFormatter.dateFormat = "dd MMM yy"
    }
    
    func setViewComponents() {
        addBottomLines()
        setPickerDelegate()
        
        unitTextField.delegate = self
        dateTextField.delegate = self
        timeTextField.delegate = self
        originCampTextField.delegate = self
        originBldgTextField.delegate = self
        originDetailTextView.delegate = self
        destinCampTextField.delegate = self
        destinBldgTextField.delegate = self
        destinDetailTextView.delegate = self
        busTextField.delegate = self
        paxTextField.delegate = self
        pocNameTextField.delegate = self
        pocPhoneTextField.delegate = self
        sendDateTextField.delegate = self
        
        unitTextField.inputView = unitPicker
        originCampTextField.inputView = originCampPicker
        destinCampTextField.inputView = destinCampPicker
        
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(textfield:)), for: .valueChanged)
        
        sendDateTextField.inputAccessoryView = toolbar
        sendDateTextField.inputView = sendDatePicker
        sendDatePicker.datePickerMode = .date
        sendDatePicker.addTarget(self, action: #selector(sendDateChanged(textfield:)), for: .valueChanged)
        
        dateFormatter.dateFormat = "dd MMM yy"
        let curDate = dateFormatter.string(from: Date())
        sendDateTextField.placeholder = curDate
        
        timeTextField.keyboardType = UIKeyboardType.decimalPad
        originBldgTextField.keyboardType = UIKeyboardType.numberPad
        destinBldgTextField.keyboardType = UIKeyboardType.numberPad
        busTextField.keyboardType = UIKeyboardType.numberPad
        paxTextField.keyboardType = UIKeyboardType.numberPad
        pocPhoneTextField.keyboardType = UIKeyboardType.decimalPad
        
        originDetailTextView.autocorrectionType = UITextAutocorrectionType.no
        destinDetailTextView.autocorrectionType = UITextAutocorrectionType.no
        pocNameTextField.autocorrectionType = UITextAutocorrectionType.no
    }

    @IBAction func submitButtonTapped(_ sender: Any) {
        if dateTextField.text == "" {
            print("필수데이터 입력되지 않음")
            return
        }
        
        if let timeText = timeTextField.text, !timeText.isEmpty {
            let times = timeText.split(separator: ".")
            if times.count == 2 {
                departTimeData = String(times[0])
                arrivalTimeData = String(times[1])
                if let depart = Int(departTimeData), let arrival = Int(arrivalTimeData) {
                    if arrival - depart < 500 {
                        isRoundTripData = 0
                    }
                }
            } else {
                departTimeData = String(times[0])
            }
        }
        
        if let originBldgText = originBldgTextField.text, !originBldgText.isEmpty {
            originBldgData = originBldgText
        }
        if let originDetailText = originDetailTextView.text, !originDetailText.isEmpty {
            originDetailData = originDetailText
        }
        if let destinBldgText = destinBldgTextField.text, !destinBldgText.isEmpty {
            destinBldgData = destinBldgText
        }
        if let destinDetailText = destinDetailTextView.text, !destinDetailText.isEmpty {
            destinDetailData = destinDetailText
        }
        if let quantityText = busTextField.text, !quantityText.isEmpty {
            quantityData = Int(quantityText)!
        }
        if let paxText = paxTextField.text, !paxText.isEmpty {
            paxData = Int(paxText)!
        }
        if isTruckSwitch.isOn {
            truckData = 1
        }
        if let pocNameText = pocNameTextField.text, !pocNameText.isEmpty {
            pocNameData = pocNameText
        }
        if let pocPhoneText = pocPhoneTextField.text, !pocPhoneText.isEmpty {
            pocPhoneData = pocPhoneText
        }
        
        
        let entered_cmr = ["status": "Submitted", "unit": units[unitData], "date": dateTextField.text!, "dateInNum": dateToInt(date: dateTextField.text!), "departTime": departTimeData, "arrivalTime": arrivalTimeData, "isRoundTrip": isRoundTripData, "originCamp": camps[originData][1], "originBLDG": originBldgData, "originDetail": originDetailData, "destinationCamp": camps[destinData][1], "destinationBLDG": destinBldgData, "destinationDetail": destinDetailData, "quantity": quantityData, "pax": paxData, "issuedTruck": truckData, "pocName": pocNameData, "pocNumber": pocPhoneData, "MSN": ""] as [String: Any]
        
        self.ref.child("cmr").childByAutoId().setValue(entered_cmr)
        
        let query = self.ref.child("cmr").queryOrdered(byChild: "date").queryEqual(toValue: dateTextField.text!)
        dateFormatter.dateFormat = "dd MMM yy HH:mm"
        let curDate = dateFormatter.string(from: Date())
        
        query.observeSingleEvent(of: .value) { (snapshotGroup) in
            if let snapshots = snapshotGroup.children.allObjects as? [DataSnapshot] {
                for snapshot in snapshots {
                    if let data = snapshot.value as? [String:AnyObject] {
                        let date = data["date"] as! String
                        print("snapshot")
                        let unit = data["unit"] as! String
                        let poc = data["pocName"] as! String
                        let MSN = data["MSN"] as! String
                        if unit == self.units[self.unitData] && poc == self.pocNameData && MSN == "" {
                            self.new_id = snapshot.key
                            print(snapshot.key)
                        }
                    }
                }
            }
            let history_text = "CMR request for " + self.units[self.unitData] + " on " + self.dateTextField.text! + " is Submitted"
            let status_history = ["type": "status", "isCMR": 1, "requestid": self.new_id, "requestunit": self.units[self.unitData], "requestdate": self.dateTextField.text!, "key": [""], "value": ["", "Submitted"], "date": curDate, "sender": "", "text": history_text] as [String : Any]
            
            self.ref.child("history").childByAutoId().setValue(status_history)
        }
        
        dateFormatter.dateFormat = "dd MMM yy"
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == unitPicker {
            return units.count
        } else {
            return camps.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == unitPicker {
            return units[row]
        } else {
            return camps[row][0]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if pickerView == unitPicker {
            let defaultView = UIView()
            defaultView.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
            label.textAlignment = .center
            label.text = units[row]
            label.font = UIFont(name: "Roboto", size: 20)
            
            defaultView.addSubview(label)
            return defaultView
        } else {
            let defaultView = UIView()
            defaultView.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
            label.textAlignment = .center
            if row == 0 {
                label.text = "No Data"
            } else {
                label.text = camps[row][1]
            }
            label.font = UIFont(name: "Roboto", size: 20)
            
            defaultView.addSubview(label)
            return defaultView
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == unitPicker {
            unitData = row
            unitTextField.text = units[row]
            unitTextField.resignFirstResponder()
        }
        else if pickerView == originCampPicker {
            originData = row
            if row != 0 {
                originCampTextField.text = camps[row][0]
            } else {
                originCampTextField.text = ""
            }
            originCampTextField.resignFirstResponder()
        }
        else {
            destinData = row
            if row != 0 {
                destinCampTextField.text = camps[row][0]
            } else {
                destinCampTextField.text = ""
            }
            destinCampTextField.resignFirstResponder()
        }
    }
    
    @objc func dateChanged(textfield: UITextField) {
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func sendDateChanged(textfield: UITextField) {
        sendDateTextField.text = dateFormatter.string(from: sendDatePicker.date)
    }
    
    func addBottomLines() {
        bottomLine1.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine1.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        unitTextField.layer.addSublayer(bottomLine1)
        bottomLine2.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine2.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        dateTextField.layer.addSublayer(bottomLine2)
        bottomLine3.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine3.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        timeTextField.layer.addSublayer(bottomLine3)
        bottomLine4.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine4.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        originCampTextField.layer.addSublayer(bottomLine4)
        bottomLine5.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine5.frame = CGRect(x: 98, y: 16, width: 3, height: 40)
        originBldgTextField.layer.addSublayer(bottomLine5)
        bottomLine6.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine6.frame = CGRect(x: -8, y: 12, width: 2, height: 50)
        //originDetailTextView.layer.addSublayer(bottomLine6)
        bottomLine7.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine7.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        destinCampTextField.layer.addSublayer(bottomLine7)
        bottomLine8.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine8.frame = CGRect(x: 98, y: 16, width: 3, height: 40)
        destinBldgTextField.layer.addSublayer(bottomLine8)
        bottomLine9.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine9.frame = CGRect(x: -8, y: 12, width: 2, height: 50)
        //destinDetailTextField.layer.addSublayer(bottomLine9)
        bottomLine10.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine10.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        busTextField.layer.addSublayer(bottomLine10)
        bottomLine11.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine11.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        paxTextField.layer.addSublayer(bottomLine11)
        bottomLine12.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine12.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        pocNameTextField.layer.addSublayer(bottomLine12)
        bottomLine13.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine13.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        pocPhoneTextField.layer.addSublayer(bottomLine13)
        bottomLine14.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bottomLine14.frame = CGRect(x: -9, y: 9, width: 3, height: 26)
        sendDateTextField.layer.addSublayer(bottomLine14)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("entered")
        switch textField {
        case unitTextField:
            if let unitText = unitTextField.text, unitText.isEmpty {
                break
            }
            bottomLine1.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            unitTitle.textColor = UIColor.systemGray
        case dateTextField:
            if let dateText = dateTextField.text, dateText.isEmpty {
                break
            }
            bottomLine2.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            dtgTitle.textColor = UIColor.systemGray
        case timeTextField:
            if let timeText = timeTextField.text, timeText.isEmpty {
                break
            }
            if let timeText = timeTextField.text, !timeText.isEmpty {
                let times = timeText.split(separator: ".")
                if times.count == 2 {
                    if times[0].count == 4 && times[1].count == 4 {
                        dtgTitle.textColor = UIColor.systemGray
                        bottomLine3.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                        timeGuideLabel.textColor = UIColor.white
                    } else {
                        timeGuideLabel.text = "Enter 4-digit time"
                        timeGuideLabel.textColor = UIColor.red
                    }
                } else {
                    if timeText.count > 4 {
                        timeGuideLabel.text = "Separate time with \".\""
                        timeGuideLabel.textColor = UIColor.red
                    } else {
                        dtgTitle.textColor = UIColor.systemGray
                        bottomLine3.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                        timeGuideLabel.text = "No arrival time"
                        timeGuideLabel.textColor = UIColor.red
                    }
                }
            }
        case originCampTextField:
            if let originCampText = originCampTextField.text, originCampText.isEmpty {
                break
            }
            originTitle.textColor = UIColor.systemGray
            bottomLine4.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case originBldgTextField:
            if let originBldgText = originBldgTextField.text, originBldgText.isEmpty {
                break
            }
            destinTitle.textColor = UIColor.systemGray
            bottomLine4.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            bottomLine5.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case destinCampTextField:
            if let destinCampText = destinCampTextField.text, destinCampText.isEmpty {
                break
            }
            destinTitle.textColor = UIColor.systemGray
            bottomLine7.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case destinBldgTextField:
            if let destinBldgText = destinBldgTextField.text, destinBldgText.isEmpty {
                break
            }
            destinTitle.textColor = UIColor.systemGray
            bottomLine7.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            bottomLine8.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case busTextField:
            if let busText = busTextField.text, busText.isEmpty {
                break
            }
            busTitle.textColor = UIColor.systemGray
            bottomLine10.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case paxTextField:
            if let paxText = paxTextField.text, paxText.isEmpty {
                break
            }
            paxTitle.textColor = UIColor.systemGray
            bottomLine11.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case pocNameTextField:
            if let pocNameText = pocNameTextField.text, pocNameText.isEmpty {
                break
            }
            pocTitle.textColor = UIColor.systemGray
            bottomLine12.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            if let nameText = pocNameTextField.text, !nameText.isEmpty {
                let names = nameText.split(separator: " ")
                if names.count == 2 {
                    bottomLine12.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    nameGuideLabel.textColor = UIColor.white
                } else {
                    bottomLine12.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    nameGuideLabel.text = "RANK NAME ex) 1LT First"
                    nameGuideLabel.textColor = UIColor.red
                }
            }
        case pocPhoneTextField:
            if let pocPhoneText = pocPhoneTextField.text, pocPhoneText.isEmpty {
                break
            }
            pocTitle.textColor = UIColor.systemGray
            bottomLine13.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            phoneGuideLabel.textColor = UIColor.white
        default:
            if let sendDateText = sendDateTextField.text, sendDateText.isEmpty {
                break
            }
            sendDateTitle.textColor = UIColor.systemGray
            bottomLine14.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == originDetailTextView {
            if let originDetailText = originDetailTextView.text, !originDetailText.isEmpty {
                originDetailTextView.textColor = UIColor.black
                originTitle.textColor = UIColor.systemGray
                bottomLine4.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                bottomLine5.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                bottomLine6.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            } else {
                originDetailTextView.text = "Detail"
            }
        }
        else if textView == destinDetailTextView {
            if let destinDetailText = destinDetailTextView.text, !destinDetailText.isEmpty {
                destinDetailTextView.textColor = UIColor.black
                destinTitle.textColor = UIColor.systemGray
                bottomLine7.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                bottomLine8.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                bottomLine9.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            } else {
                destinDetailTextView.text = "Detail"
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == originDetailTextView {
            originDetailTextView.text = ""
        }
        else if textView == destinDetailTextView {
            destinDetailTextView.text = ""
        }
    }
    
    func setPickerDelegate() {
        unitPicker.delegate = self
        unitPicker.dataSource = self
        originCampPicker.delegate = self
        originCampPicker.dataSource = self
        destinCampPicker.delegate = self
        destinCampPicker.dataSource = self
    }
    
    func dateToInt(date: String) -> Int {
        dateFormatter.dateFormat = "dd MMM yy"
        let basicDate = dateFormatter.date(from: "01 JAN 20")
        let inputDate = dateFormatter.date(from: date)
        let interval = calender.dateComponents([.day], from: basicDate!, to: inputDate!)
        return interval.day!
    }
}
