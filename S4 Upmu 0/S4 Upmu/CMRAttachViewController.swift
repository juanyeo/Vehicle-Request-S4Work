//
//  CMRAttachViewController.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/26.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit
import Firebase

protocol PassCMRData {
    func passCMRData(id: String, unit: String, date: String)
}

class CMRAttachViewController: UIViewController {
    
    @IBOutlet weak var CMRTableView: UITableView!
    var ref = Database.database().reference()
    
    let dateFormatter = DateFormatter()
    let calender = Calendar.current
    var requests = [cmrRequest]()
    var requestDates = [Int]()
    var groupedRequests = [String: [cmrRequest]]()
    var delegate: PassCMRData?
    
    var requestid = ""
    var requestUnit = ""
    var requestDate = ""
    var workingDays: [Int] = []
    
    override func viewWillAppear(_ animated: Bool) {
        loadCMRData()
        autoScrollTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CMRTableView.delegate = self
        CMRTableView.dataSource = self
        CMRTableView.separatorStyle = .none
        CMRTableView.backgroundColor = UIColor.white

        workingDays = calculateWorkingDay()
    }
    
    fileprivate func loadCMRData() {
        self.ref.child("cmr").queryOrdered(byChild: "dateInNum").observeSingleEvent(of: .value) { (snapshotGroup) in
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
                self.groupRequestsByDate()
                self.CMRTableView.reloadData()
                self.autoScrollTableView()
            }
        }
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
                else if count == 3 {
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

extension CMRAttachViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionString = intToDate(interval: requestDates[indexPath.section])
        let request = groupedRequests[sectionString]!
        
        requestid = request[indexPath.row].id
        requestUnit = request[indexPath.row].unit
        requestDate = request[indexPath.row].date
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate!.passCMRData(id: requestid, unit: requestUnit, date: requestDate)
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
            /*
            dateFormatter.dateFormat = "dd MMM yy"
            let currentDate = dateFormatter.string(from: Date())
            if firstItem.date == currentDate {
                backView.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
                label1.textColor = UIColor.white
                label2.textColor = UIColor.white
            } */
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
