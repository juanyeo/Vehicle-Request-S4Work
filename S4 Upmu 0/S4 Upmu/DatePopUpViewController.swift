//
//  DatePopUpViewController.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/24.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit
import Firebase

class DatePopUpViewController: UIViewController, UITextFieldDelegate {
    
    let dateFormatter = DateFormatter()
    let calender = Calendar.current
    var tmprequestdata: tmpRequest?
    var ref = Database.database().reference()
    
    @IBOutlet weak var startTextField1: UITextField!
    @IBOutlet weak var startTextField2: UITextField!
    @IBOutlet weak var startTextField3: UITextField!
    @IBOutlet weak var startTextField4: UITextField!
    @IBOutlet weak var startTextField5: UITextField!
    
    @IBOutlet weak var endTextField1: UITextField!
    @IBOutlet weak var endTextField2: UITextField!
    @IBOutlet weak var endTextField3: UITextField!
    @IBOutlet weak var endTextField4: UITextField!
    @IBOutlet weak var endTextField5: UITextField!
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var viewHeightConstant: NSLayoutConstraint!
    
    var start: String = ""
    var end: String = ""
    var indexOfCell = [-1, -1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        start = tmprequestdata?.startDate as! String
        end = tmprequestdata?.endDate as! String
        
        dateFormatter.dateFormat = "dd MMM yy"
        setViewComponents()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        if startTextField2.isHidden {
            viewHeightConstant.constant = 192
            startTextField2.isHidden = false
            endTextField2.isHidden = false
        }
        else if startTextField3.isHidden {
            viewHeightConstant.constant = 236
            startTextField3.isHidden = false
            endTextField3.isHidden = false
        }
        else if startTextField4.isHidden {
            viewHeightConstant.constant = 280
            startTextField4.isHidden = false
            endTextField4.isHidden = false
        }
        else if startTextField5.isHidden {
            viewHeightConstant.constant = 324
            startTextField5.isHidden = false
            endTextField5.isHidden = false
        }
    }
    
    @IBAction func minusButtonTapped(_ sender: Any) {
        if !startTextField5.isHidden {
            viewHeightConstant.constant = 280
            startTextField5.text = ""
            endTextField5.text = ""
            startTextField5.isHidden = true
            endTextField5.isHidden = true
            if let startText4 = startTextField4.text, !startText4.isEmpty {
                endTextField4.text = end
            }
        } else if !startTextField4.isHidden {
            viewHeightConstant.constant = 236
            startTextField4.text = ""
            endTextField4.text = ""
            startTextField4.isHidden = true
            endTextField4.isHidden = true
            if let startText3 = startTextField3.text, !startText3.isEmpty {
                endTextField3.text = end
            }
        } else if !startTextField3.isHidden {
            viewHeightConstant.constant = 192
            startTextField3.text = ""
            endTextField3.text = ""
            startTextField3.isHidden = true
            endTextField3.isHidden = true
            if let startText2 = startTextField2.text, !startText2.isEmpty {
                endTextField2.text = end
            }
        } else if !startTextField2.isHidden {
            viewHeightConstant.constant = 148
            startTextField2.text = ""
            endTextField2.text = ""
            startTextField2.isHidden = true
            endTextField2.isHidden = true
            if let startText1 = startTextField1.text, !startText1.isEmpty {
                endTextField1.text = end
            }
        }
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        var dateContainer: [String] = []
        var statusContainer: [String] = []
        let textfields: [UITextField] = [startTextField1, endTextField1, startTextField2, endTextField2, startTextField3, endTextField3, startTextField4, endTextField4, startTextField5, endTextField5]
        
        let count = checkFilling()
        print("counted")
        print(count)
        if count <= 10 {
            textfields[count-1].textColor = UIColor.red
            return
        }
        
        let validate_result = validateInputs(count: count-10)
        print("validated")
        print(validate_result)
        if validate_result != 0 {
            textfields[validate_result].textColor = UIColor.red
            return
        }
        
        switch count-10 {
        case 2:
            let string1 = startTextField1.text! + " - " + endTextField1.text!
            dateContainer = [string1]
            start = startTextField1.text!
            end = endTextField1.text!
        case 4:
            let string1 = startTextField1.text! + " - " + endTextField1.text!
            let string2 = startTextField2.text! + " - " + endTextField2.text!
            dateContainer = [string1, string2]
            start = startTextField1.text!
            end = endTextField2.text!
        case 6:
            let string1 = startTextField1.text! + " - " + endTextField1.text!
            let string2 = startTextField2.text! + " - " + endTextField2.text!
            let string3 = startTextField3.text! + " - " + endTextField3.text!
            dateContainer = [string1, string2, string3]
            start = startTextField1.text!
            end = endTextField3.text!
        case 8:
            let string1 = startTextField1.text! + " - " + endTextField1.text!
            let string2 = startTextField2.text! + " - " + endTextField2.text!
            let string3 = startTextField3.text! + " - " + endTextField3.text!
            let string4 = startTextField4.text! + " - " + endTextField4.text!
            dateContainer = [string1, string2, string3, string4]
            start = startTextField1.text!
            end = endTextField4.text!
        case 10:
            let string1 = startTextField1.text! + " - " + endTextField1.text!
            let string2 = startTextField2.text! + " - " + endTextField2.text!
            let string3 = startTextField3.text! + " - " + endTextField3.text!
            let string4 = startTextField4.text! + " - " + endTextField4.text!
            let string5 = startTextField5.text! + " - " + endTextField5.text!
            dateContainer = [string1, string2, string3, string4, string5]
            start = startTextField1.text!
            end = endTextField5.text!
        default:
            return
        }
        
        for i in 0..<dateContainer.count {
            statusContainer.append("Unsubmitted")
        }
        
        ref.child("tmp").child(tmprequestdata!.id).updateChildValues(["statusDates": dateContainer, "status": statusContainer, "startDate": start, "startInNum": dateToInt(date: start), "endDate": end, "endInNum": dateToInt(date: end)])
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black
        let datePicker_ = textField.inputView as! UIDatePicker
        if let text = textField.text, !text.isEmpty {
            datePicker_.date = dateFormatter.date(from: text)!
        } else {
            let textFields = [startTextField1,endTextField1,startTextField2,endTextField2,startTextField3,endTextField3,startTextField4,endTextField4,startTextField5,endTextField5]
            for i in 1..<textFields.count {
                if textField == textFields[i] {
                    if let text2 = textFields[i-1]?.text, !text2.isEmpty {
                        let dateInt = dateToInt(date: text2)
                        datePicker_.date = dateFormatter.date(from: intToDate(interval: dateInt+1))!
                    }
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = UIColor.systemGray2
    }
    
    func setViewComponents() {
        setDelegate()
        
        let statusDates = tmprequestdata?.statusDates
        switch statusDates?.count {
        case 1:
            startTextField1.text = statusDates![0].components(separatedBy: " - ")[0]
            endTextField1.text = statusDates![0].components(separatedBy: " - ")[1]
            startTextField2.isHidden = true
            endTextField2.isHidden = true
            startTextField3.isHidden = true
            endTextField3.isHidden = true
            startTextField4.isHidden = true
            endTextField4.isHidden = true
            startTextField5.isHidden = true
            endTextField5.isHidden = true
            viewHeightConstant.constant = 148
        case 2:
            startTextField1.text = statusDates![0].components(separatedBy: " - ")[0]
            endTextField1.text = statusDates![0].components(separatedBy: " - ")[1]
            startTextField2.text = statusDates![1].components(separatedBy: " - ")[0]
            endTextField2.text = statusDates![1].components(separatedBy: " - ")[1]
            startTextField3.isHidden = true
            endTextField3.isHidden = true
            startTextField4.isHidden = true
            endTextField4.isHidden = true
            startTextField5.isHidden = true
            endTextField5.isHidden = true
            viewHeightConstant.constant = 192
        case 3:
            startTextField1.text = statusDates![0].components(separatedBy: " - ")[0]
            endTextField1.text = statusDates![0].components(separatedBy: " - ")[1]
            startTextField2.text = statusDates![1].components(separatedBy: " - ")[0]
            endTextField2.text = statusDates![1].components(separatedBy: " - ")[1]
            startTextField3.text = statusDates![2].components(separatedBy: " - ")[0]
            endTextField3.text = statusDates![2].components(separatedBy: " - ")[1]
            startTextField4.isHidden = true
            endTextField4.isHidden = true
            startTextField5.isHidden = true
            endTextField5.isHidden = true
            viewHeightConstant.constant = 236
        case 4:
            startTextField1.text = statusDates![0].components(separatedBy: " - ")[0]
            endTextField1.text = statusDates![0].components(separatedBy: " - ")[1]
            startTextField2.text = statusDates![1].components(separatedBy: " - ")[0]
            endTextField2.text = statusDates![1].components(separatedBy: " - ")[1]
            startTextField3.text = statusDates![2].components(separatedBy: " - ")[0]
            endTextField3.text = statusDates![2].components(separatedBy: " - ")[1]
            startTextField4.text = statusDates![3].components(separatedBy: " - ")[0]
            endTextField4.text = statusDates![3].components(separatedBy: " - ")[1]
            startTextField5.isHidden = true
            endTextField5.isHidden = true
            viewHeightConstant.constant = 280
        default:
            startTextField1.text = statusDates![0].components(separatedBy: " - ")[0]
            endTextField1.text = statusDates![0].components(separatedBy: " - ")[1]
            startTextField2.text = statusDates![1].components(separatedBy: " - ")[0]
            endTextField2.text = statusDates![1].components(separatedBy: " - ")[1]
            startTextField3.text = statusDates![2].components(separatedBy: " - ")[0]
            endTextField3.text = statusDates![2].components(separatedBy: " - ")[1]
            startTextField4.text = statusDates![3].components(separatedBy: " - ")[0]
            endTextField4.text = statusDates![3].components(separatedBy: " - ")[1]
            startTextField5.text = statusDates![4].components(separatedBy: " - ")[0]
            endTextField5.text = statusDates![4].components(separatedBy: " - ")[1]
            viewHeightConstant.constant = 324
        }
        
        startTextField1.inputAccessoryView = toolbar
        startTextField1.inputView = datePicker1
        datePicker1.datePickerMode = .date
        datePicker1.addTarget(self, action: #selector(dateChanged1(textfield:)), for: .valueChanged)
        
        startTextField2.inputAccessoryView = toolbar
        startTextField2.inputView = datePicker2
        datePicker2.datePickerMode = .date
        datePicker2.addTarget(self, action: #selector(dateChanged2(textfield:)), for: .valueChanged)
        
        startTextField3.inputAccessoryView = toolbar
        startTextField3.inputView = datePicker3
        datePicker3.datePickerMode = .date
        datePicker3.addTarget(self, action: #selector(dateChanged3(textfield:)), for: .valueChanged)
        
        startTextField4.inputAccessoryView = toolbar
        startTextField4.inputView = datePicker4
        datePicker4.datePickerMode = .date
        datePicker4.addTarget(self, action: #selector(dateChanged4(textfield:)), for: .valueChanged)
        
        startTextField5.inputAccessoryView = toolbar
        startTextField5.inputView = datePicker5
        datePicker5.datePickerMode = .date
        datePicker5.addTarget(self, action: #selector(dateChanged5(textfield:)), for: .valueChanged)
        
        endTextField1.inputAccessoryView = toolbar
        endTextField1.inputView = datePicker6
        datePicker6.datePickerMode = .date
        datePicker6.addTarget(self, action: #selector(dateChanged6(textfield:)), for: .valueChanged)
        
        endTextField2.inputAccessoryView = toolbar
        endTextField2.inputView = datePicker7
        datePicker7.datePickerMode = .date
        datePicker7.addTarget(self, action: #selector(dateChanged7(textfield:)), for: .valueChanged)
        
        endTextField3.inputAccessoryView = toolbar
        endTextField3.inputView = datePicker8
        datePicker8.datePickerMode = .date
        datePicker8.addTarget(self, action: #selector(dateChanged8(textfield:)), for: .valueChanged)
        
        endTextField4.inputAccessoryView = toolbar
        endTextField4.inputView = datePicker9
        datePicker9.datePickerMode = .date
        datePicker9.addTarget(self, action: #selector(dateChanged9(textfield:)), for: .valueChanged)
        
        endTextField5.inputAccessoryView = toolbar
        endTextField5.inputView = datePicker10
        datePicker10.datePickerMode = .date
        datePicker10.addTarget(self, action: #selector(dateChanged10(textfield:)), for: .valueChanged)
    }
    
    func setDelegate() {
        startTextField1.delegate = self
        startTextField2.delegate = self
        startTextField3.delegate = self
        startTextField4.delegate = self
        startTextField5.delegate = self
        endTextField1.delegate = self
        endTextField2.delegate = self
        endTextField3.delegate = self
        endTextField4.delegate = self
        endTextField5.delegate = self
    }
    
    let toolbar = UIToolbar()
    let datePicker1 = UIDatePicker()
    let datePicker2 = UIDatePicker()
    let datePicker3 = UIDatePicker()
    let datePicker4 = UIDatePicker()
    let datePicker5 = UIDatePicker()
    let datePicker6 = UIDatePicker()
    let datePicker7 = UIDatePicker()
    let datePicker8 = UIDatePicker()
    let datePicker9 = UIDatePicker()
    let datePicker10 = UIDatePicker()
    
    @objc func dateChanged1(textfield: UITextField) {
        startTextField1.text = dateFormatter.string(from: datePicker1.date)
    }
    @objc func dateChanged2(textfield: UITextField) {
        startTextField2.text = dateFormatter.string(from: datePicker2.date)
    }
    @objc func dateChanged3(textfield: UITextField) {
        startTextField3.text = dateFormatter.string(from: datePicker3.date)
    }
    @objc func dateChanged4(textfield: UITextField) {
        startTextField4.text = dateFormatter.string(from: datePicker4.date)
    }
    @objc func dateChanged5(textfield: UITextField) {
        startTextField5.text = dateFormatter.string(from: datePicker5.date)
    }
    @objc func dateChanged6(textfield: UITextField) {
        endTextField1.text = dateFormatter.string(from: datePicker6.date)
    }
    @objc func dateChanged7(textfield: UITextField) {
        endTextField2.text = dateFormatter.string(from: datePicker7.date)
    }
    @objc func dateChanged8(textfield: UITextField) {
        endTextField3.text = dateFormatter.string(from: datePicker8.date)
    }
    @objc func dateChanged9(textfield: UITextField) {
        endTextField4.text = dateFormatter.string(from: datePicker9.date)
    }
    @objc func dateChanged10(textfield: UITextField) {
        endTextField5.text = dateFormatter.string(from: datePicker10.date)
    }
    
    func dateToInt(date: String) -> Int {
        dateFormatter.dateFormat = "dd MMM yy"
        let basicDate = dateFormatter.date(from: "01 JAN 20")
        let inputDate = dateFormatter.date(from: date)
        let interval = calender.dateComponents([.day], from: basicDate!, to: inputDate!)
        return interval.day!
    }
    
    func intToDate(interval: Int) -> String {
        dateFormatter.dateFormat = "dd MMM yy"
        let basicDate = dateFormatter.date(from: "01 JAN 20")
        let date = calender.date(byAdding: .day, value: interval, to: basicDate!)
        return dateFormatter.string(from: date!)
    }
    
    func checkFilling() -> Int {
        let textfields: [UITextField] = [startTextField1, endTextField1, startTextField2, endTextField2, startTextField3, endTextField3, startTextField4, endTextField4, startTextField5, endTextField5]
        var count = 0
        for textfield in textfields {
            if let text = textfield.text, !text.isEmpty {
                count += 1
            }
        }
        
        for i in 0..<count {
            if let text = textfields[i].text, text.isEmpty {
                return i + 1
            }
        }
        
        if (count % 2) == 1 {
            return count
        }
        
        return count + 10
    }
    
    func validateInputs(count: Int) -> Int {
        let textfields: [UITextField] = [startTextField1, endTextField1, startTextField2, endTextField2, startTextField3, endTextField3, startTextField4, endTextField4, startTextField5, endTextField5]
        var pastTF = startTextField1
        for i in 1..<count {
            let date1 = dateToInt(date: (pastTF?.text!)!)
            let date2 = dateToInt(date: textfields[i].text!)
            if date1 > date2 {
                return i
            }
        }
        return 0
    }
}
