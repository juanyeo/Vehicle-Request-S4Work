//
//  CMRViewController.swift
//  S4 Upmu
//
//  Created by juan on 2020/07/14.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit
import Firebase

class CMRViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var CMRTableView: UITableView!
    var ref = Database.database().reference()
    
    let dateFormatter = DateFormatter()
    let calender = Calendar.current
    var requests = [cmrRequest]()
    var histories = [history]()
    var requestDates = [Int]()
    var groupedRequests = [String: [cmrRequest]]()
    //var rowSelected = [-1, -1]
    var extendedRow = [-1, -1]
    var isFirstTimeView = true
    var workingDays: [Int] = []
    
    let addButton = UIButton()
    let newButton = UIButton()
    let filButton = UIButton()
    
    override func viewWillAppear(_ animated: Bool) {
        ref.keepSynced(true)
        self.navigationController?.navigationBar.isHidden = true
        self.extendedRow = [-1, -1]
        loadCMRData()
        
        // Reset Buttons
        let tabbarHeight: CGFloat = (tabBarController?.tabBar.frame.size.height)!
        self.newButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
        self.filButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
        self.newButton.isHidden = true
        self.filButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //autoScrollTableView()
        loadHistoryData()
        workingDays = calculateWorkingDay()
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
        
        self.view.addSubview(filButton)
        self.view.addSubview(newButton)
        self.view.addSubview(addButton)
        
        newButton.isHidden = true
        filButton.isHidden = true
        
        CMRTableView.delegate = self
        CMRTableView.dataSource = self
        CMRTableView.separatorStyle = .none
        //CMRTableView.backgroundColor = UIColor.systemGray6
        CMRTableView.backgroundColor = UIColor.white
    }
    
    fileprivate func loadCMRData() {
        self.ref.child("cmr").queryOrdered(byChild: "dateInNum").observe(.value) { (snapshotGroup) in
            self.requests.removeAll()
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
                        self.requests.append(cmrRequest(id: snapshot.key, status: status, unit: unit, date: date, dateInNum: dateInNum, departTime: departTime, arrivalTime: arrivalTime, isRoundTrip: isRoundTrip, originCamp: originCamp, originBLDG: originBLDG, originDetail: originDetail, destinationCamp: destinationCamp, destinationBLDG: destinationBLDG, destinationDetail: destinationDetail, quantity: quantity, pax: pax, issuedTruck: issuedTruck, pocName: pocName, pocNumber: pocNumber, MSN: MSN))
                    }
                }
                if self.requests.count == 0 {
                    self.setDefaultData()
                }
                
                self.groupRequestsByDate()
                self.CMRTableView.reloadData()
                if self.isFirstTimeView {
                    self.autoScrollTableView()
                }
                self.isFirstTimeView = false
                //self.autoScrollTableView()
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
        let tmp_cmr = cmrRequest(id: "", status: "Contact", unit: "SAMPLE", date: "03 Feb 20", dateInNum: 33, departTime: "0000", arrivalTime: "0000", isRoundTrip: 0, originCamp: "CP Sample", originBLDG: "1234", originDetail: "", destinationCamp: "", destinationBLDG: "", destinationDetail: "This is Sample Data", quantity: 1, pax: 25, issuedTruck: 1, pocName: "1LT Philosophy, Engineering", pocNumber: "010-1234-1234", MSN: "")
        requests.append(tmp_cmr)
    }
    
    fileprivate func groupRequestsByDate() {
        if requests.count == 0 {
            print("groupRequestsByDate() - 오브젝트 없음")
            return
        }
        groupedRequests.removeAll()
        requestDates.removeAll()
        
        var pastDate: Int = requests.first?.dateInNum ?? 0
        var pastDateString: String = requests.first?.date ?? "01 Jan 20"
        var sameDateRequests = [cmrRequest]()
        requestDates.append(requests.first!.dateInNum)
        
        for request in requests {
            if request.dateInNum == pastDate {
                sameDateRequests.append(request)
            }
            else if request.dateInNum > pastDate {
                groupedRequests[pastDateString] = sameDateRequests
                requestDates.append(request.dateInNum)
                sameDateRequests.removeAll()
                sameDateRequests.append(request)
                pastDate = request.dateInNum
                pastDateString = request.date
            }
            else {
                print("groupRequestsByDate() - 데이터 소팅 안됨")
            }
        }
        groupedRequests[pastDateString] = sameDateRequests
    }
    
    func autoScrollTableView() {
        let currentInt = currentDateToInt()
        let aftertoday = requestDates.filter { (date) -> Bool in
            date >= currentInt
        }.sorted()
        var indexPath = IndexPath()
        if aftertoday.count != 0 {
            indexPath = IndexPath(row: 0, section: requestDates.index(of: aftertoday.min()!)!)
            self.CMRTableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    fileprivate func createSearchBar() {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = " Search - 검색 기능은 아직이오"
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
    }
    
    @objc func addNewButtonAction(sender: UIButton!) {
        /* let cmr1 = ["status": "Approved", "unit": "5-4 CAV", "date": "13 May 20", "dateInNum": 133, "departTime": "0900", "arrivalTime": "1030", "isRoundTrip": 0, "originCamp": "CP Hovey", "originBLDG": "1234", "originDetail": "", "destinationCamp": "", "destinationBLDG": "", "destinationDetail": "Rodriguez Live Fire Complex", "quantity": 2, "pax": 50, "issuedTruck": 1, "pocName": "1LT Philosophy, Engineering", "pocNumber": "010-2379-4239", "MSN": ""] as [String: Any]
        let cmr2 = ["status": "Pending", "unit": "1-18 IN", "date": "25 Jul 20", "dateInNum": 206, "departTime": "0900", "arrivalTime": "1700", "isRoundTrip": 1, "originCamp": "CP Humphreys", "originBLDG": "1234", "originDetail": "Warriors Base", "destinationCamp": "", "destinationBLDG": "1410", "destinationDetail": "Yongsan Garrison", "quantity": 2, "pax": 50, "issuedTruck": 0, "pocName": "1LT Philosophy, Engineering", "pocNumber": "010-2379-4239", "MSN": ""] as [String : Any]
        let cmr3 = ["status": "Submitted", "unit": "2 ABCT", "date": "05 Jun 20", "dateInNum": 156, "departTime": "0900", "arrivalTime": "1030", "isRoundTrip": 0, "originCamp": "CP Hovey", "originBLDG": "1234", "originDetail": "", "destinationCamp": "CP Casey", "destinationBLDG": "", "destinationDetail": "Rodriguez Live Fire Complex", "quantity": 2, "pax": 50, "issuedTruck": 1, "pocName": "1LT Philosophy, Engineering", "pocNumber": "010-2379-4239", "MSN": ""] as [String : Any]
        
        self.ref.child("cmr").childByAutoId().setValue(cmr1)
        self.ref.child("cmr").childByAutoId().setValue(cmr2)
        self.ref.child("cmr").childByAutoId().setValue(cmr3) */
        
        let tabbarHeight: CGFloat = (tabBarController?.tabBar.frame.size.height)!
        if newButton.isHidden {
            newButton.isHidden = false
            filButton.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.newButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 160), size: CGSize(width: 60, height: 60))
                self.filButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 240), size: CGSize(width: 60, height: 60))
            }
            addButton.setImage(UIImage(named: "박스-color"), for: UIControl.State.normal)
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.newButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
                self.filButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width - 80, y: self.view.frame.height - tabbarHeight - 80), size: CGSize(width: 60, height: 60))
            }) { (Bool) in
                self.newButton.isHidden = true
                self.filButton.isHidden = true
            }
            addButton.setImage(UIImage(named: "box_closed"), for: UIControl.State.normal)
        }
    }
    
    @objc func newButtonAction(sender: UIButton!) {
        self.navigationController?.navigationBar.isHidden = false
        performSegue(withIdentifier: "cmrToNew", sender: .none)
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
    
    func DateToInt(date: Date) -> Int {
        dateFormatter.dateFormat = "dd MMM yy"
        let basicDate = dateFormatter.date(from: "01 JAN 20")
        let interval = calender.dateComponents([.day], from: basicDate!, to: date)
        return interval.day!
    }
    
    func calculateWorkingDay() -> [Int] {
        var oneDayComponent = DateComponents()
        oneDayComponent.day = 1
        var count = 0
        var date = Date()
        var oneWorkingDay = Date()
        var threeWorkingDay = Date()
        var sevenWorkingDay = Date()
        
        while true {
            date = calender.date(byAdding: oneDayComponent, to: date)!
            
            if !calender.isDateInWeekend(date) {
                count += 1
                if count == 1 {
                    oneWorkingDay = date
                }
                else if count == 2 {
                    threeWorkingDay = date
                }
                else if count == 7 {
                    sevenWorkingDay = date
                    break
                }
            }
        }
        
        return [DateToInt(date: oneWorkingDay), DateToInt(date: threeWorkingDay), DateToInt(date: sevenWorkingDay), currentDateToInt()]
    }
    
}

extension CMRViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return requestDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionString = intToDate(interval: requestDates[section])
        return groupedRequests[sectionString]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionString = intToDate(interval: requestDates[indexPath.section])
        let request = groupedRequests[sectionString]!
        let cell = CMRTableView.dequeueReusableCell(withIdentifier: "CMRCell", for: indexPath) as! CMRCell
        
        cell.workingDays = workingDays
        cell.setRequestData(request: request[indexPath.row])
        cell.setCMRCell(request: request[indexPath.row])
        
        /*if indexMatch(checkpoint: rowSelected, index: [indexPath.section, indexPath.row]) && !indexMatch(checkpoint: extendedRow, index: [indexPath.section, indexPath.row]) {
            cell.HeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.ExtendedView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        else {
            cell.HeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        cell.HeaderView.layer.cornerRadius = 6
        cell.ExtendedView.layer.cornerRadius = 6*/
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexMatch(checkpoint: extendedRow, index: [indexPath.section, indexPath.row]) {
            return 290 //320
        }
        else {
            return 78 //78
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CMRTableView.deselectRow(at: indexPath, animated: true)
        let index = [indexPath.section, indexPath.row]
        /*
        let sectionString = intToDate(interval: requestDates[indexPath.section])
        let request = groupedRequests[sectionString]!
        
        self.rowSelected = index
        if !indexMatch(checkpoint: extendedRow, index: [-1, -1]) {
            let extendedRowIndexPath = IndexPath(row: extendedRow[1], section: extendedRow[0])
            CMRTableView.reloadRows(at: [indexPath, extendedRowIndexPath], with: .automatic)
        }
        CMRTableView.reloadRows(at: [indexPath], with: .automatic) */
        
        
        if indexMatch(checkpoint: extendedRow, index: index) {
            self.extendedRow = [-1, -1]
            CMRTableView.reloadRows(at: [indexPath], with: .automatic) // new
        }
        else {
            if indexMatch(checkpoint: extendedRow, index: [-1, -1]) {
                self.extendedRow = index
                CMRTableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                let extendedRowIndexPath = IndexPath(row: extendedRow[1], section: extendedRow[0])
                self.extendedRow = index
                CMRTableView.reloadRows(at: [indexPath, extendedRowIndexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label1 = UILabel()
        let label2 = UILabel()
        let containerView = UIView()
        
        let backView = UIView()
        containerView.addSubview(backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 45).isActive = true
        backView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -self.view.bounds.width/2+30).isActive = true
        backView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backView.layer.masksToBounds = false
        backView.layer.cornerRadius = 25
        backView.backgroundColor = UIColor.white
        
        let sectionString = intToDate(interval: requestDates[section])
        if let firstItem = groupedRequests[sectionString]?.first {
            let dateArray = firstItem.date.components(separatedBy: " ")
            let day = dateArray[0]
            let month = dateArray[1]
            label1.text = day
            label2.text = month
            
            dateFormatter.dateFormat = "dd MMM yy"
            /*let currentDate = dateFormatter.string(from: Date())
            if firstItem.date == currentDate {
                backView.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
                label1.textColor = UIColor.white
                label2.textColor = UIColor.white
            }*/
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
        label1.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 46).isActive = true
        label1.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -self.view.bounds.width/2+30).isActive = true
        label2.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 20).isActive = true
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

extension CMRViewController: CMRCellDelegate {
    func didTapHistory(cmr: cmrRequest) {
        /*let alertTitle = "History"
        let message = "공사중 - 아직 접근할 수 없습니다"
        
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "돌아간다", style: .default, handler: nil))
        present(alert, animated: true, completion: nil) */
        performSegue(withIdentifier: "cmrDetailSegue1", sender: cmr)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func didTapEdit(cmr: cmrRequest) {
        performSegue(withIdentifier: "popupSegue1", sender: cmr)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popupSegue1" {
            let popVC = segue.destination as! StatusPopUpViewController
            popVC.cmrrequestdata = sender as? cmrRequest
            popVC.isCMR = true
            popVC.indexOfCell = extendedRow
        }
        else if segue.identifier == "cmrDetailSegue1" {
            let detailVC = segue.destination as! CMRDetailViewController
            let singleCMR = sender as? cmrRequest
            detailVC.cmrrequest = [singleCMR!]
            var singleRequestHistory = [history]()
            for history in histories {
                if history.requestid == singleCMR?.id {
                    singleRequestHistory.append(history)
                }
            }
            detailVC.histories = singleRequestHistory
        }
    }
}
