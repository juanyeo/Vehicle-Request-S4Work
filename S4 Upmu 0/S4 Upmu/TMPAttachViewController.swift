//
//  TMPAttachViewController.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/26.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit
import Firebase

protocol PassTMPData {
    func passTMPData(id: String, unit: String, date: String)
}

class TMPAttachViewController: UIViewController {

    @IBOutlet weak var TMPTableView: UITableView!
    var ref = Database.database().reference()
    
    let dateFormatter = DateFormatter()
    let calender = Calendar.current
    var currentDate: Int = 0
    var requests = [tmpRequest]()
    var requestDates = [Int]()
    var groupedRequests = [String: [tmpRequest]]()
    var statusCounts = [[Int]]()
    var delegate: PassTMPData?
    
    var requestid = ""
    var requestUnit = ""
    var requestDate = ""
    
    override func viewWillAppear(_ animated: Bool) {
        loadTMPData()
        autoScrollTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TMPTableView.delegate = self
        TMPTableView.dataSource = self
        TMPTableView.separatorStyle = .none
        TMPTableView.backgroundColor = UIColor.white
    }
    
    fileprivate func loadTMPData() {
        currentDate = currentDateToInt()
        
        self.ref.child("tmp").queryOrdered(byChild: "startInNum").observeSingleEvent(of: .value) { (snapshotGroup) in
            self.requests.removeAll()
            if let snapshots = snapshotGroup.children.allObjects as? [DataSnapshot] {
                for snapshot in snapshots {
                    if let data = snapshot.value as? [String:AnyObject] {
                        print(snapshot.key)
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
                    }
                }
                self.groupRequestsByDate()
                self.TMPTableView.reloadData()
            }
        }
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
    
    func autoScrollTableView() {
        let currentInt = currentDateToInt()
        let aftertoday = requestDates.filter { (date) -> Bool in
            date >= currentInt
        }.sorted()
        var indexPath = IndexPath()
        if aftertoday.count != 0 {
            indexPath = IndexPath(row: 0, section: requestDates.index(of: aftertoday.min()!)!)
            self.TMPTableView.scrollToRow(at: indexPath, at: .top, animated: false)
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

extension TMPAttachViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return requestDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionString = intToDate(interval: requestDates[section])
        return groupedRequests[sectionString]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var request: [tmpRequest] = []
        let sectionString = intToDate(interval: requestDates[indexPath.section])
        request = groupedRequests[sectionString]!
        let cell = TMPTableView.dequeueReusableCell(withIdentifier: "TMPCell", for: indexPath) as! TMPCell
        
        cell.setRequestData(request: request[indexPath.row])
        cell.setTMPCell(request: request[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 117 //78
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TMPTableView.deselectRow(at: indexPath, animated: true)
        let sectionString = intToDate(interval: requestDates[indexPath.section])
        let request = groupedRequests[sectionString]!
        
        requestid = request[indexPath.row].id
        requestUnit = request[indexPath.row].unit
        requestDate = request[indexPath.row].startDate
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate!.passTMPData(id: requestid, unit: requestUnit, date: requestDate)
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
        //backView.backgroundColor = UIColor.systemGray6
        backView.backgroundColor = UIColor.white
        
        let sectionString = intToDate(interval: requestDates[section])
        if let firstItem = groupedRequests[sectionString]?.first {
            let dateArray = firstItem.startDate.components(separatedBy: " ")
            let day = dateArray[0]
            let month = dateArray[1]
            label1.text = day
            label2.text = month
            
            /*
            dateFormatter.dateFormat = "dd MMM yy"
            let currentDate = dateFormatter.string(from: Date())
            if firstItem.startDate == currentDate {
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
