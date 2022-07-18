//
//  TMPViewController.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/21.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit
import Firebase

class TMPViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var TMPTableView: UITableView!
    var ref = Database.database().reference()
    
    let dateFormatter = DateFormatter()
    let calender = Calendar.current
    var currentDate: Int = 0
    var requests = [tmpRequest]()
    var singleRequests = [tmpRequest]()
    var requestDates = [Int]()
    var splitRequestDates = [Int]()
    var groupedRequests = [String: [tmpRequest]]()
    var splitRequests = [String: [tmpRequest]]()
    var statusCounts = [[Int]]()
    //var rowSelected = [-1, -1]
    var extendedRow = [-1, -1]
    var splitRequestMode: Bool = false
    var isFirstTimeView = true
    var histories = [history]()
    
    let addButton = UIButton()
    let newButton = UIButton()
    let filButton = UIButton()
    let modeButton = UIButton()
    
    override func viewWillAppear(_ animated: Bool) {
        ref.keepSynced(true)
        self.navigationController?.navigationBar.isHidden = true
        self.extendedRow = [-1, -1]
        
        loadTMPData()
        
        // Reset Buttons
        let tabbarHeight: CGFloat = (tabBarController?.tabBar.frame.size.height)!
        self.newButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
        self.filButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
        self.modeButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
        self.newButton.isHidden = true
        self.filButton.isHidden = true
        self.modeButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //autoScrollTableView()
        loadHistoryData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabbarHeight: CGFloat = (tabBarController?.tabBar.frame.size.height)!

        addButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
        addButton.backgroundColor = UIColor.white
        addButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addButton.layer.shadowOpacity = 0.8
        addButton.layer.shadowRadius = 10.0
        addButton.layer.masksToBounds = false
        addButton.layer.cornerRadius = 30
        addButton.setImage(UIImage(named: "box_closed"), for: UIControl.State.normal)
        addButton.addTarget(self, action: #selector(addNewButtonAction(sender:)), for: .touchUpInside)
        self.view.addSubview(addButton)
        
        newButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
        newButton.backgroundColor = UIColor.white
        newButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        newButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        newButton.layer.shadowOpacity = 0.8
        newButton.layer.shadowRadius = 10.0
        newButton.layer.masksToBounds = false
        newButton.layer.cornerRadius = 30
        newButton.setImage(UIImage(named: "추가-white"), for: UIControl.State.normal)
        newButton.addTarget(self, action: #selector(newButtonAction(sender:)), for: .touchUpInside)
        
        filButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
        filButton.backgroundColor = UIColor.white
        filButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        filButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        filButton.layer.shadowOpacity = 0.8
        filButton.layer.shadowRadius = 10.0
        filButton.layer.masksToBounds = false
        filButton.layer.cornerRadius = 30
        filButton.setImage(UIImage(named: "필터-color"), for: UIControl.State.normal)
        //filterButton.addTarget(self, action: #selector(addNewButtonAction(sender:)), for: .touchUpInside)
        
        modeButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
        modeButton.backgroundColor = UIColor.white
        modeButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        modeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        modeButton.layer.shadowOpacity = 0.8
        modeButton.layer.shadowRadius = 10.0
        modeButton.layer.masksToBounds = false
        modeButton.layer.cornerRadius = 30
        modeButton.setImage(UIImage(named: "oneone"), for: UIControl.State.normal)
        modeButton.addTarget(self, action: #selector(changeModeButtonAction(sender:)), for: .touchUpInside)
        
        self.view.addSubview(modeButton)
        self.view.addSubview(filButton)
        self.view.addSubview(newButton)
        self.view.addSubview(addButton)
        
        modeButton.isHidden = true
        filButton.isHidden = true
        newButton.isHidden = true
        
        TMPTableView.delegate = self
        TMPTableView.dataSource = self
        TMPTableView.separatorStyle = .none
        TMPTableView.backgroundColor = UIColor.white
    }
    
    fileprivate func loadTMPData() {
        currentDate = currentDateToInt()
        
        self.ref.child("tmp").queryOrdered(byChild: "startInNum").observe(.value) { (snapshotGroup) in
            self.requests.removeAll()
            self.singleRequests.removeAll()
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
                        if self.validateRequest(start: startInNum, end: endInNum) {
                            self.requests.append(tmpRequest(id: snapshot.key, statusDates: statusDates, status: status, unit: unit, type: type, startDate: startDate, startInNum: startInNum, endDate: endDate, endInNum: endInNum, user: user, quantity: quantity, pax: pax, destination: destination, office: office, MSN: MSN))
                        }
                        for i in 0..<statusDates.count {
                            let dateArray = statusDates[i].components(separatedBy: " - ")
                            let startInt = self.dateToInt(date: dateArray[0])
                            let endInt = self.dateToInt(date: dateArray[1])
                            if self.validateRequest(start: startInt, end: endInt) {
                                self.singleRequests.append(tmpRequest(id: snapshot.key, statusDates: [statusDates[i]], status: [status[i]], unit: unit, type: type, startDate: dateArray[0], startInNum: startInt, endDate: dateArray[1], endInNum: endInt, user: user, quantity: quantity, pax: pax, destination: destination, office: office, MSN: MSN))
                            }
                        }
                    }
                }
                if self.requests.count == 0 {
                    self.groupedRequests.removeAll()
                    self.requestDates.removeAll()
                    self.setDefaultData()
                } else {
                    self.groupRequestsByDate()
                    self.groupSplitRequestsByDate()
                }
                self.TMPTableView.reloadData()
                if self.isFirstTimeView {
                    self.autoScrollTableView()
                }
                self.isFirstTimeView = false
            }
        }
    }
    
    func loadHistoryData() {
        self.ref.child("history").queryOrdered(byChild: "date").observeSingleEvent(of: .value) { (snapshotGroup) in
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
            }
        }
    }
    
    fileprivate func setDefaultData() {
        let tmp_tmp = tmpRequest(id: "", statusDates: ["26 Jun 20 - 27 Jun 20", "28 Jun 20 - 29 Jun 20"], status: ["Approved", "Pending"], unit: "2 ABCT", type: "SEDAN", startDate: "26 Jun 20", startInNum: 177, endDate: "29 Jun 20", endInNum: 180, user: "1LT Yankee, Candle", quantity: 1, pax: 5, destination: "Sample Destination", office: "Humphreys", MSN: "")
        requests.append(tmp_tmp)
        groupedRequests["26 Jun 20"] = [tmp_tmp]
        requestDates.append(177)
    }
    
    fileprivate func validateRequest(start: Int, end: Int) -> Bool {
        /*if currentDate > end {
            return false
        } else {
            return true
        }*/
        return true
    }
    
    fileprivate func groupRequestsByDate() {
        groupedRequests.removeAll()
        requestDates.removeAll()
        statusCounts.removeAll()
        
        var pastDate: Int = requests.first?.startInNum ?? 0
        var pastDateString: String = requests.first?.startDate ?? "01 Jan 20"
        var sameDateRequests = [tmpRequest]()
        var statusCount = [Int]()
        
        requestDates.append(requests.first!.startInNum)
        
        for request in requests {
            if request.startInNum == pastDate {
                sameDateRequests.append(request)
                statusCount.append(request.status.count)
            }
            else if request.startInNum > pastDate {
                groupedRequests[pastDateString] = sameDateRequests
                statusCounts.append(statusCount)
                requestDates.append(request.startInNum)
                sameDateRequests.removeAll()
                statusCount.removeAll()
                sameDateRequests.append(request)
                statusCount.append(request.status.count)
                pastDate = request.startInNum
                pastDateString = request.startDate
            }
            else {
                print("groupRequestsByDate() - 데이터 소팅 안됨")
            }
        }
        groupedRequests[pastDateString] = sameDateRequests
        statusCounts.append(statusCount)
    }
    
    fileprivate func groupSplitRequestsByDate() {
        splitRequests.removeAll()
        splitRequestDates.removeAll()
        singleRequests = singleRequests.sorted(by: {$0.startInNum < $1.startInNum})
        
        var pastDate: Int = singleRequests.first?.startInNum ?? 0
        var pastDateString: String = singleRequests.first?.startDate ?? "01 Jan 20"
        var sameDateRequests = [tmpRequest]()
        
        splitRequestDates.append(singleRequests.first!.startInNum)
        
        for request in singleRequests {
            if request.startInNum == pastDate {
                sameDateRequests.append(request)
            }
            else if request.startInNum > pastDate {
                splitRequests[pastDateString] = sameDateRequests
                splitRequestDates.append(request.startInNum)
                sameDateRequests.removeAll()
                sameDateRequests.append(request)
                pastDate = request.startInNum
                pastDateString = request.startDate
            }
            else {
                print("groupRequestsByDate() - 데이터 소팅 안됨")
            }
        }
        splitRequests[pastDateString] = sameDateRequests
    }
    
    func autoScrollTableView() {
        var indexPath = IndexPath()
        let currentInt = currentDateToInt()
        if splitRequestMode {
            let aftertoday = splitRequestDates.filter { (date) -> Bool in
                date >= currentInt
            }.sorted()
            if aftertoday.count != 0 {
                indexPath = IndexPath(row: 0, section: splitRequestDates.index(of: aftertoday.min()!)!)
                self.TMPTableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        } else {
            let aftertoday = requestDates.filter { (date) -> Bool in
                date >= currentInt
            }.sorted()
            if aftertoday.count != 0 {
                indexPath = IndexPath(row: 0, section: requestDates.index(of: aftertoday.min()!)!)
                self.TMPTableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
    }
    
    @objc func addNewButtonAction(sender: UIButton!) {
        
        let tabbarHeight: CGFloat = (tabBarController?.tabBar.frame.size.height)!
        if newButton.isHidden {
            newButton.isHidden = false
            filButton.isHidden = false
            modeButton.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.newButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 160), size: CGSize(width: 60, height: 60))
                self.filButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 240), size: CGSize(width: 60, height: 60))
                self.modeButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 320), size: CGSize(width: 60, height: 60))
            }
            addButton.setImage(UIImage(named: "박스-color"), for: UIControl.State.normal)
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.newButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
                self.filButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
                self.modeButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
            }) { (Bool) in
                self.newButton.isHidden = true
                self.filButton.isHidden = true
                self.modeButton.isHidden = true
            }
            addButton.setImage(UIImage(named: "box_closed"), for: UIControl.State.normal)
        }
    }
    
    @objc func newButtonAction(sender: UIButton!) {
        
        self.navigationController?.navigationBar.isHidden = false
        performSegue(withIdentifier: "tmpToNew", sender: .none)
    }
    
    @objc func filButtonAction(sender: UIButton!) {
        //let tmp1 = ["statusDates": ["30 Jun 20 - 05 Aug 20", "06 Aug 20 - 15 Aug 20", "16 Aug 20 - 23 Aug 20", "24 Aug 20 - 25 Aug 20"], "status": ["Pending", "Approved", "CBU", "CBU"], "unit": "2 ABCT", "type": "VAN", "startDate": "30 Jun 20", "startInNum": 181, "endDate": "25 Aug 20", "endInNum": 237, "user": "1LT Yankee, Candle", "quantity": 1, "pax": 5, "destination": "Sample Destination", "office": "Casey", "MSN": "U017-002"] as [String : Any]
        
        //self.ref.child("tmp").childByAutoId().setValue(tmp1)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popupSegue2" {
            let popVC = segue.destination as! StatusPopUpViewController
            let tmp_sender = sender as? tmpRequest
            popVC.tmprequestdata = sender as? tmpRequest
            popVC.isCMR = false
            popVC.indexOfCell = extendedRow
            
            let originRequest = requests.filter { (tmpRequest) -> Bool in
                if tmpRequest.id == tmp_sender?.id {
                    return true
                } else {
                    return false
                }
            }
            
            popVC.origintmpdata = originRequest[0]
        }
        else if segue.identifier == "popupSegue3" {
            let popVC = segue.destination as!DatePopUpViewController
            popVC.tmprequestdata = sender as? tmpRequest
            popVC.indexOfCell = extendedRow
        }
        else if segue.identifier == "tmpDetailSegue1" {
            let detailVC = segue.destination as! TMPDetailViewController
            let singleTMP = sender as? tmpRequest
            detailVC.tmprequest = [singleTMP!]
            var singleRequestHistory = [history]()
            for history in histories {
                if history.requestid == singleTMP?.id {
                    singleRequestHistory.append(history)
                }
            }
            detailVC.histories = singleRequestHistory
        }
    }
    
    @objc func changeModeButtonAction(sender: UIButton!) {
        if splitRequestMode {
            splitRequestMode = false
            sender.setImage(UIImage(named: "oneone"), for: UIControl.State.normal)
            self.TMPTableView.reloadData()
            self.extendedRow = [-1, -1]
            self.autoScrollTableView()
        } else {
            splitRequestMode = true
            sender.setImage(UIImage(named: "모아모아-color"), for: UIControl.State.normal)
            self.TMPTableView.reloadData()
            self.extendedRow = [-1, -1]
            self.autoScrollTableView()
        }
    }
    
    func dateToInt(date: String) -> Int {
        dateFormatter.dateFormat = "dd MMM yy"
        let basicDate = dateFormatter.date(from: "01 JAN 20")
        let inputDate = dateFormatter.date(from: date)
        let interval = calender.dateComponents([.day], from: basicDate!, to: inputDate!)
        return interval.day!
    }
    
    func currentDateToInt() -> Int {
        dateFormatter.dateFormat = "dd MMM yy"
        let basicDate = dateFormatter.date(from: "01 JAN 20")
        let interval = calender.dateComponents([.day], from: basicDate!, to: Date())
        return interval.day!
    }
    
    func intToDate(interval: Int) -> String {
        dateFormatter.dateFormat = "dd MMM yy"
        let basicDate = dateFormatter.date(from: "01 JAN 20")
        let date = calender.date(byAdding: .day, value: interval, to: basicDate!)
        return dateFormatter.string(from: date!)
    }
    
    
    
}

extension TMPViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if splitRequestMode {
            return splitRequestDates.count
        } else {
            return requestDates.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if splitRequestMode {
            let sectionString = intToDate(interval: splitRequestDates[section])
            return splitRequests[sectionString]!.count
        } else {
            let sectionString = intToDate(interval: requestDates[section])
            return groupedRequests[sectionString]!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var request: [tmpRequest] = []
        if splitRequestMode {
            let sectionString = intToDate(interval: splitRequestDates[indexPath.section])
            request = splitRequests[sectionString]!
        } else {
            let sectionString = intToDate(interval: requestDates[indexPath.section])
            request = groupedRequests[sectionString]!
        }
        let cell = TMPTableView.dequeueReusableCell(withIdentifier: "TMPCell", for: indexPath) as! TMPCell
        
        cell.setRequestData(request: request[indexPath.row])
        cell.setTMPCell(request: request[indexPath.row])
        /*
        if indexMatch(checkpoint: rowSelected, index: [indexPath.section, indexPath.row]) && !indexMatch(checkpoint: extendedRow, index: [indexPath.section, indexPath.row]) {
            cell.HeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.ExtendedView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        else {
            cell.HeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        cell.HeaderView.layer.cornerRadius = 6
        cell.ExtendedView.layer.cornerRadius = 6 */
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if splitRequestMode {
            return 116
        }
        if indexMatch(checkpoint: extendedRow, index: [indexPath.section, indexPath.row]) {
            let statusCount = statusCounts[indexPath.section][indexPath.row]
            switch statusCount {
            case 1:
                return 262
            case 2:
                return 288
            case 3:
                return 314
            case 4:
                return 340
            default:
                return 366
            }
        }
        else {
            return 121 //116
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TMPTableView.deselectRow(at: indexPath, animated: true)
        if splitRequestMode {
            let sectionString = intToDate(interval: splitRequestDates[indexPath.section])
            let tmp = splitRequests[sectionString]![indexPath.row]
            performSegue(withIdentifier: "popupSegue2", sender: tmp)
            self.extendedRow = [-1, -1]
            return
        }
        
        let index = [indexPath.section, indexPath.row]
        
        if indexMatch(checkpoint: extendedRow, index: index) {
            self.extendedRow = [-1, -1]
            TMPTableView.reloadRows(at: [indexPath], with: .automatic) // new
        }
        else {
            if indexMatch(checkpoint: extendedRow, index: [-1, -1]) {
                self.extendedRow = index
                TMPTableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                let extendedRowIndexPath = IndexPath(row: extendedRow[1], section: extendedRow[0])
                self.extendedRow = index
                TMPTableView.reloadRows(at: [indexPath, extendedRowIndexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label1 = UILabel()
        let label2 = UILabel()
        let containerView = UIView()
        
        let backView = UIView()
        containerView.addSubview(backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 55).isActive = true //45
        backView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -self.view.bounds.width/2+30).isActive = true
        backView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backView.layer.masksToBounds = false
        backView.layer.cornerRadius = 25
        //backView.backgroundColor = UIColor.systemGray6
        backView.backgroundColor = UIColor.white
        
        if splitRequestMode {
            let sectionString = intToDate(interval: splitRequestDates[section])
            if let firstItem = splitRequests[sectionString]?.first {
                let dateArray = firstItem.startDate.components(separatedBy: " ")
                let day = dateArray[0]
                let month = dateArray[1]
                label1.text = day
                label2.text = month
                
                dateFormatter.dateFormat = "dd MMM yy"
                /*let currentDate = dateFormatter.string(from: Date())
                if firstItem.startDate == currentDate {
                    backView.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
                    label1.textColor = UIColor.white
                    label2.textColor = UIColor.white
                }*/
            }
        } else {
            let sectionString = intToDate(interval: requestDates[section])
            if let firstItem = groupedRequests[sectionString]?.first {
                let dateArray = firstItem.startDate.components(separatedBy: " ")
                let day = dateArray[0]
                let month = dateArray[1]
                label1.text = day
                label2.text = month
                
                dateFormatter.dateFormat = "dd MMM yy"
                /*let currentDate = dateFormatter.string(from: Date())
                if firstItem.startDate == currentDate {
                    backView.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
                    label1.textColor = UIColor.white
                    label2.textColor = UIColor.white
                }*/
            }
        }
        
        label1.textAlignment = .right
        label2.textAlignment = .right
        label1.font = UIFont(name: "Roboto-Bold", size: 30)
        label2.font = UIFont(name: "Roboto-Regular", size: 15)
    
        containerView.backgroundColor = .clear
        containerView.addSubview(label1)
        containerView.addSubview(label2)
        label1.translatesAutoresizingMaskIntoConstraints = false
        label2.translatesAutoresizingMaskIntoConstraints = false
        label1.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 55).isActive = true //46
        label1.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -self.view.bounds.width/2+30).isActive = true
        label2.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 30).isActive = true //20
        label2.trailingAnchor.constraint(equalTo: label1.trailingAnchor, constant: 0).isActive = true
        
        return containerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        footerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 6)
        return footerView
    }
    
    fileprivate func indexMatch(checkpoint: [Int], index: [Int]) -> Bool {
        if checkpoint[0] == index[0] && checkpoint[1] == index[1] {
            return true
        } else {
            return false
        }
    }
}

extension TMPViewController: TMPCellDelegate {
    func didTapHistory(tmp: tmpRequest) {
        /*let alertTitle = "History"
        let message = "공사중 - 아직 접근할 수 없습니다"
        
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "돌아간다", style: .default, handler: nil))
        present(alert, animated: true, completion: nil) */
        performSegue(withIdentifier: "tmpDetailSegue1", sender: tmp)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func didTapEdit(tmp: tmpRequest) {
        performSegue(withIdentifier: "popupSegue3", sender: tmp)
    }
}
