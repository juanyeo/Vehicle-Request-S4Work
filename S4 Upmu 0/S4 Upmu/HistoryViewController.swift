//
//  HistoryViewController.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/25.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit
import Firebase

class HistoryViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var inputTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var inputBackgroundHeight: NSLayoutConstraint!
    @IBOutlet weak var inputandsendView: UIView!
    @IBOutlet weak var inputViewBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var alertButton: UIButton!
    @IBOutlet weak var attachView: UIView!
    @IBOutlet weak var attachTitleLabel: UILabel!
    let filButton = UIButton()
    let typeSegment = UISegmentedControl(items: ["CMR", "TMP"])
    
    var histories = [history]()
    var cmrRequests = [cmrRequest]()
    var tmpRequests = [tmpRequest]()
    var types = ["status", "change", "text", "alert"]
    var ref = Database.database().reference()
    let dateFormatter = DateFormatter()
    
    var isCMR = true
    var requestUnit = ""
    var requestDate = ""
    var requestid = ""
    var isAlert = false
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        ref.keepSynced(true)
        self.navigationController?.navigationBar.isHidden = true
        if histories.count != 0 {
            autoScrollTableView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        inputTextView.delegate = self
        
        loadHistoryData()
        loadCMRData()
        loadTMPData()
        
        setViewComponents()
        //autoScrollTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setViewComponents() {
        filButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 60, y: 35), size: CGSize(width: 40, height: 40))
        //addButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        //addButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        //addButton.layer.shadowOpacity = 0.5
        //addButton.layer.shadowRadius = 10.0
        filButton.layer.masksToBounds = false
        filButton.layer.cornerRadius = 20
        filButton.setImage(UIImage(named: "필터-color"), for: .normal)
        filButton.imageView?.contentMode = UIView.ContentMode.scaleToFill
        filButton.addTarget(self, action: #selector(filButtonTapped(sender:)), for: .touchUpInside)
        self.view.addSubview(filButton)
        
        typeSegment.frame = CGRect(origin: CGPoint(x: self.view.frame.width/2 - 50, y: 40), size: CGSize(width: 100, height: 30))
        typeSegment.selectedSegmentIndex = 0
        typeSegment.addTarget(self, action: #selector(changedType(sender:)), for: .valueChanged)
        self.view.addSubview(typeSegment)
        
        attachView.backgroundColor = UIColor.lightGray
        attachView.alpha = 0.8
        attachView.isHidden = true
        
        inputandsendView.layer.masksToBounds = false
        inputandsendView.layer.cornerRadius = 17
        
        let leadingLine = CALayer()
        leadingLine.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        leadingLine.frame = CGRect(x: 46, y: 8, width: 2, height: 22)
        attachButton.layer.addSublayer(leadingLine)
    }
    
    func loadHistoryData() {
        self.ref.child("history").observe(.value) { (snapshotGroup) in
            self.histories.removeAll()
            if let snapshots = snapshotGroup.children.allObjects as? [DataSnapshot] {
                for snapshot in snapshots {
                    if let data = snapshot.value as? [String:AnyObject] {
                        let id = snapshot.key
                        let type = data["type"] as! String
                        let isCMR = data["isCMR"] as! Int
                        let requestid = data["requestid"] as! String
                        let requestunit = data["requestunit"] as! String
                        let requestdate = data["requestdate"] as! String
                        let key = data["key"] as! [String]
                        let value = data["value"] as! [String]
                        let date = data["date"] as! String
                        let sender = data["sender"] as! String
                        let text = data["text"] as! String
                        self.histories.append(history(id: id, type: type, isCMR: isCMR, requestid: requestid, requestunit: requestunit, requestdate: requestdate, key: key, value: value, date: date, sender: sender, text: text))
                    }
                }
                if self.histories.count == 0 {
                    self.setDefaultData()
                }
                self.dateFormatter.dateFormat = "dd MMM yy HH:mm"
                self.histories.sorted { (history1, history2) -> Bool in
                    self.dateFormatter.date(from: history1.date)! < self.dateFormatter.date(from: history2.date)!
                }
                self.dateFormatter.dateFormat = "dd MMM yy"
                self.tableView.reloadData()
                if self.histories.count != 0 {
                    self.autoScrollTableView()
                }
            }
        }
    }
    
    fileprivate func loadCMRData() {
        self.ref.child("cmr").observeSingleEvent(of: .value) { (snapshotGroup) in
            self.cmrRequests.removeAll()
            if let snapshots = snapshotGroup.children.allObjects as? [DataSnapshot] {
                for snapshot in snapshots {
                    if let data = snapshot.value as? [String:AnyObject] {
                        let status = data["status"] as! String
                        let unit = data["unit"] as! String
                        let date = data["date"] as! String
                        let dateInNum = data["dateInNum"] as! Int
                        let departTime = data["departTime"] as! String
                        let arrivalTime = data["arrivalTime"] as! String
                        let isRoundTrip = data["isRoundTrip"] as! Int
                        let originCamp = data["originCamp"] as! String
                        let originBLDG = data["originBLDG"] as! String
                        let originDetail = data["originDetail"] as! String
                        let destinationCamp = data["destinationCamp"] as! String
                        let destinationBLDG = data["destinationBLDG"] as! String
                        let destinationDetail = data["destinationDetail"] as! String
                        let quantity = data["quantity"] as! Int
                        let pax = data["pax"] as! Int
                        let issuedTruck = data["issuedTruck"] as! Int
                        let pocName = data["pocName"] as! String
                        let pocNumber = data["pocNumber"] as! String
                        let MSN = data["MSN"] as! String
                        self.cmrRequests.append(cmrRequest(id: snapshot.key, status: status, unit: unit, date: date, dateInNum: dateInNum, departTime: departTime, arrivalTime: arrivalTime, isRoundTrip: isRoundTrip, originCamp: originCamp, originBLDG: originBLDG, originDetail: originDetail, destinationCamp: destinationCamp, destinationBLDG: destinationBLDG, destinationDetail: destinationDetail, quantity: quantity, pax: pax, issuedTruck: issuedTruck, pocName: pocName, pocNumber: pocNumber, MSN: MSN))
                    }
                }
            }
        }
    }
    
    fileprivate func loadTMPData() {
        self.ref.child("tmp").queryOrdered(byChild: "startInNum").observeSingleEvent(of: .value) { (snapshotGroup) in
            self.tmpRequests.removeAll()
            if let snapshots = snapshotGroup.children.allObjects as? [DataSnapshot] {
                for snapshot in snapshots {
                    if let data = snapshot.value as? [String:AnyObject] {
                        let statusDates = data["statusDates"] as! [String]
                        let status = data["status"] as! [String]
                        let unit = data["unit"] as! String
                        let type = data["type"] as! String
                        let startDate = data["startDate"] as! String
                        let startInNum = data["startInNum"] as! Int
                        let endDate = data["endDate"] as! String
                        let endInNum = data["endInNum"] as! Int
                        let user = data["user"] as! String
                        let quantity = data["quantity"] as! Int
                        let pax = data["pax"] as! Int
                        let destination = data["destination"] as! String
                        let office = data["office"] as! String
                        let MSN = data["MSN"] as! String
                        self.tmpRequests.append(tmpRequest(id: snapshot.key, statusDates: statusDates, status: status, unit: unit, type: type, startDate: startDate, startInNum: startInNum, endDate: endDate, endInNum: endInNum, user: user, quantity: quantity, pax: pax, destination: destination, office: office, MSN: MSN))
                    }
                }
            }
        }
    }
    
    fileprivate func setDefaultData() {
        dateFormatter.dateFormat = "dd MMM yy HH:mm"
        let tmp_history = history(id: "", type: "text", isCMR: 1, requestid: "", requestunit: "", requestdate: "", key: [""], value: [""], date: dateFormatter.string(from: Date()), sender: "", text: "Sample Text Message")
        histories.append(tmp_history)
        dateFormatter.dateFormat = "dd MMM yy"
    }
    
    func autoScrollTableView() {
        let indexPath = IndexPath(row: histories.count-1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    @objc func changedType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("CMR 선택됨")
            isCMR = true
        case 1:
            print("TMP 선택됨")
            isCMR = false
        default:
            break
        }
    }
    
    @objc func filButtonTapped(sender: UIButton) {
        performSegue(withIdentifier: "filterSegue1", sender: .none)
    }
    
    @IBAction func attachButtonTapped(_ sender: Any) {
        if isCMR {
            performSegue(withIdentifier: "attachSegue1", sender: nil)
        } else {
            performSegue(withIdentifier: "attachSegue2", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "attachSegue1" {
            let attachVC = segue.destination as! CMRAttachViewController
            attachVC.delegate = self
        }
        else if segue.identifier == "attachSegue2" {
            let attachVC = segue.destination as! TMPAttachViewController
            attachVC.delegate = self
        }
        else if segue.identifier == "cmrDetailSegue2" {
            let detailVC = segue.destination as! CMRDetailViewController
            let idForHistory = sender as! String
            var singleHistories = [history]()
            for history in histories {
                if history.requestid == idForHistory {
                    singleHistories.append(history)
                }
            }
            var singleCMRs = [cmrRequest]()
            for cmr in cmrRequests {
                if cmr.id == idForHistory {
                    singleCMRs.append(cmr)
                }
            }
            detailVC.histories = singleHistories
            detailVC.cmrrequest = singleCMRs
        }
        else if segue.identifier == "tmpDetailSegue2" {
            let detailVC = segue.destination as! TMPDetailViewController
            let idForHistory = sender as! String
            var singleHistories = [history]()
            for history in histories {
                if history.requestid == idForHistory {
                    singleHistories.append(history)
                }
            }
            var singleTMPs = [tmpRequest]()
            for tmp in tmpRequests {
                if tmp.id == idForHistory {
                    singleTMPs.append(tmp)
                }
            }
            detailVC.histories = singleHistories
            detailVC.tmprequest = singleTMPs
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        inputTextView.resignFirstResponder()
        
        var textmode = ""
        var isCMRData = 1
        if isAlert { textmode = "alert" }
        else { textmode = "text" }
        if isCMR { isCMRData = 1}
        else { isCMRData = 0 }
        
        if let text = inputTextView.text, !text.isEmpty {
            dateFormatter.dateFormat = "dd MMM yy HH:mm"
            let text_history = ["type": textmode, "isCMR": isCMRData, "requestid": requestid, "requestunit": requestUnit, "requestdate": requestDate, "key": [""], "value": [""], "date": dateFormatter.string(from: Date()), "sender": "", "text": text] as [String : Any]
            
            self.ref.child("history").childByAutoId().setValue(text_history)
            self.tableView.reloadData()
            inputTextView.text = ""
            inputTextViewHeight.constant = 34
            inputBackgroundHeight.constant = 38
        }
        
        attachView.isHidden = true
        requestid = ""
        requestUnit = ""
        requestDate = ""
        isAlert = false
        alertButton.tintColor = UIColor.lightGray
    }
    
    @IBAction func alertButtonTapped(_ sender: UIButton) {
        if isAlert {
            isAlert = false
            sender.tintColor = UIColor.lightGray
        } else {
            isAlert = true
            sender.tintColor = UIColor.red
        }
        for history in histories {
            print(history.text)
        }
    }
    
    @IBAction func attachCancelButtonTapped(_ sender: Any) {
        attachView.isHidden = true
        requestid = ""
        requestUnit = ""
        requestDate = ""
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Enter text"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if inputTextView.contentSize.height < 90 {
            inputTextViewHeight.constant = inputTextView.contentSize.height
            inputBackgroundHeight.constant = inputTextView.contentSize.height + 4
        } else {
            inputTextViewHeight.constant = 90
            inputBackgroundHeight.constant = 94
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let tabbarHeight: CGFloat = (tabBarController?.tabBar.frame.size.height)!
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardRect = keyboardSize.cgRectValue
        if inputViewBottomAnchor.constant == 0 {
            inputViewBottomAnchor.constant = tabbarHeight - keyboardRect.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if inputViewBottomAnchor.constant != 0 {
            inputViewBottomAnchor.constant = 0
        }
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellRequest = histories[indexPath.row]
        
        if cellRequest.requestid == "" {
            return
        }
        
        if cellRequest.isCMR == 1 {
            var singleCMRs = [cmrRequest]()
            for cmr in cmrRequests {
                if cmr.id == cellRequest.requestid {
                    singleCMRs.append(cmr)
                }
            }
            if singleCMRs.count != 0 {
                performSegue(withIdentifier: "cmrDetailSegue2", sender: cellRequest.requestid)
            }
        } else {
            var singleTMPs = [tmpRequest]()
            for tmp in tmpRequests {
                if tmp.id == cellRequest.requestid {
                    singleTMPs.append(tmp)
                }
            }
            if singleTMPs.count != 0 {
                performSegue(withIdentifier: "tmpDetailSegue2", sender: cellRequest.requestid)
            }
        }
        self.navigationController?.navigationBar.isHidden = false
    }
}

extension HistoryViewController: PassCMRData {
    func passCMRData(id: String, unit: String, date: String) {
        self.requestid = id
        self.requestUnit = unit
        self.requestDate = date
        
        if requestid != "" {
            attachTitleLabel.text = "CMR: " + requestUnit + ", " + requestDate
            attachView.isHidden = false
        }
    }
}

extension HistoryViewController: PassTMPData {
    func passTMPData(id: String, unit: String, date: String) {
        self.requestid = id
        self.requestUnit = unit
        self.requestDate = date
        
        if requestid != "" {
            attachTitleLabel.text = "TMP: " + requestUnit + ", " + requestDate
            attachView.isHidden = false
        }
    }
}
