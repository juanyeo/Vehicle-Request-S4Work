//
//  FileEnterViewController.swift
//  S4 Upmu
//
//  Created by Juan Yeo on 2020/07/30.
//  Copyright © 2020 juanyeo. All rights reserved.
//

import UIKit

class FileEnterViewController: UIViewController {
    var fileURL: URL!
    let dateFormatter = DateFormatter()
    let calender = Calendar.current
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var boxPaxLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var destinLabel: UILabel!
    @IBOutlet weak var pocLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var fileTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let contents = String()
        do {
            let contents = try String(contentsOf: fileURL, encoding: .windowsCP1250)
            fileTextView.text = contents
            //print(contents)
            setViewComponents(data: processString(cmr: contents))
        } catch { print("내용물 얻기 실패") }
    }
    
    func setViewComponents(data: [String: Any]) {
        let quantity = data["quantity"] as! Int
        let pax = data["pax"] as! Int
        let truck = data["issuedTruck"] as! Int
        let originCamp = data["originCamp"] as! String
        let originBLDG = data["originBLDG"] as! String
        let originDetail = data["originDetail"] as! String
        let destinCamp = data["destinationCamp"] as! String
        let destinBLDG = data["destinationBLDG"] as! String
        let destinDetail = data["destinationDetail"] as! String
        let date = data["date"] as! String
        let departTime = data["departTime"] as! String
        let arrivalTime = data["arrivalTime"] as! String
        let pocName = data["pocName"] as! String
        let pocPhone = data["pocNumber"] as! String
        
        unitLabel.text = data["unit"] as! String
        
        if truck == 1 {
            boxPaxLabel.text = String(quantity) + " Bus, " + String(pax) + " Pax" + ", Baggage Truck"
        } else {
            boxPaxLabel.text = String(quantity) + " Bus, " + String(pax) + " Pax"
        }
        
        var originText = ""
        var destinText = ""
        if originBLDG == "" {
            if originDetail == "" {
                originText = originCamp
            } else {
                originText = originDetail + ", " + originCamp
            }
        } else {
            originText = "# " + originBLDG + " " +  originDetail + ", " + originCamp
        }
        if destinBLDG == "" {
            if destinDetail == "" {
                destinText = destinCamp
            } else {
                destinText = destinDetail + ", " + destinCamp
            }
        } else {
            destinText = "# " + destinBLDG + " " +  destinDetail + ", " + destinCamp
        }
        
        originLabel.text = originText
        destinLabel.text = destinText
        pocLabel.text = pocName + " (" + pocPhone + ")"
        dateLabel.text = date
        timeLabel.text = departTime + " - " + arrivalTime
    }
    
    func processString(cmr: String) -> [String: Any] {
        let splitString = cmr.components(separatedBy: "\n")
        var dataString: [String] = []
        let characterSet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvxyz"
        let numberSet = "0123456789"
        let titlePrefix = ["COMBINED", "2. REQUE", "3. APPRO", "4. REQUE", "5. RECEI", "6. DESIR", "7. ORIGI", "8. ROUTE", "9. MOVEM", "CARGO DE"]
        let unitTitles = ["1-18", "1-18IN", "1-17", "1-17IN", "82", "82BEB", "5-4", "5-4CAV", "1-63", "1-63AR", "2-70", "2-70AR", "1-7", "1-7FA", "299", "299BSB"]
        let units = ["1-18 IN", "1-17 IN", "82 BEB", "5-4 CAV", "1-63 AR", "2-70 AR", "1-7 FA", "299 BSB"]
        let rankTitles = ["2LT", "O1", "1LT", "O2", "CPT", "O3", "MAJ", "O4", "LTC", "O5", "COL", "O6", "WO1", "CW2", "CW3", "SGT", "E5", "SSG", "E6", "SFC", "E7", "1SG", "E8", "MSG", "E-8", "SGM", "E9", "CSM", "E-9"]
        let monthTitles = ["january", "jan", "Jan", "february", "feb", "Feb", "march", "mar", "Mar", "april", "apr", "Apr", "may", "MaY", "May", "june", "jun", "Jun", "july", "jul", "Jul", "august", "aug", "Aug", "september", "sep", "Sep", "october", "oct", "Oct", "november", "nov", "Nov", "december", "dec", "Dec"]
        let campTitles = ["Humphreys", "HUMPHREYS", "Humphries", "HUMPHRIES", "Humphrey", "HUMPHREY", "Hovey", "HOVEY", "Casey", "CASEY", "Yongsan", "YONGSAN", "Stanley", "STANLEY", "Rodriguez", "RODRIGUEZ", "SLFC", "slfc", "RLFC", "RFLIC"]
        let campTitlesChange = ["Humphreys": "CP Humphreys", "HUMPHREYS": "CP Humphreys", "Humphries": "CP Humphreys", "HUMPHRIES": "CP Humphreys", "Humphrey": "CP Humphreys", "HUMPHREY": "CP Humphreys", "Hovey": "CP Hovey", "HOVEY": "CP Hovey", "Casey": "CP Casey", "CASEY": "CP Casey", "Yongsan": "CP Yongsan", "YONGSAN": "CP Yongsan", "Stanley": "CP Stanley", "STANLEY": "CP Stanley", "Rodriguez": "CP Rodriguez", "RODRIGUEZ": "CP Rodriguez", "SLFC": "SLFC", "slfc": "SLFC", "RLFC": "RLFC", "RFLIC": "RLFC"]

        for str in splitString {
            let trimmedString = str.trimmingCharacters(in: .whitespaces)
            if trimmedString != "" && characterSet.contains(trimmedString.prefix(1)) && !titlePrefix.contains(String(trimmedString.prefix(8))) {
                if trimmedString == "HIGHWAY" || trimmedString == "HIGHWAY??" {
                    break
                }
                if trimmedString.prefix(11) != "1. REQUEST " {
                    dataString.append(str)
                }
            }
        }
        //print(dataString)
        var unitData = "2 ABCT"
        var pocNameData = ""
        var pocPhoneData = ""
        var unitRequesterLine = dataString[1].components(separatedBy: " ").filter({ $0 != "" })
        for i in 0..<unitRequesterLine.count {
            if unitTitles.contains(unitRequesterLine[i]) {
                let index = unitTitles.index(of: unitRequesterLine[i]) as! Int
                unitData = units[index/2]
            } else if rankTitles.contains(unitRequesterLine[i]) {
                let index = rankTitles.index(of: unitRequesterLine[i]) as! Int
                if index % 2 == 0 {
                    pocNameData = rankTitles[index] + " " + unitRequesterLine[i+1]
                } else {
                    pocNameData = rankTitles[index-1] + " " + unitRequesterLine[i+1]
                }
                if !characterSet.contains(pocNameData.suffix(1)) {
                    pocNameData.removeLast()
                }
            } else if unitRequesterLine[i].components(separatedBy: CharacterSet.decimalDigits.inverted).joined().count > 4 {
                pocPhoneData = unitRequesterLine[i]
            }
        }
        
        var firstDate = ""
        var secondDate = ""
        var timeData = ""
        var dateData = ""
        var dtgLine = dataString[3].lowercased().components(separatedBy: " ").filter({ $0 != "" })
        for i in 1..<dtgLine.count-1 {
            if monthTitles.contains(dtgLine[i]) {
                let index = monthTitles.index(of: dtgLine[i]) as! Int
                if dtgLine[i-1].count == 2 {
                    if firstDate == "" {
                        firstDate = dtgLine[i-1] + " " + monthTitles[index+2-(index%3)] + " " + dtgLine[i+1].suffix(2)
                        dtgLine[i] = "MT"
                        dtgLine[i+1] = "YR"
                    } else {
                        secondDate = dtgLine[i-1] + " " + monthTitles[index+2-(index%3)] + " " + dtgLine[i+1].suffix(2)
                        dtgLine[i] = "MT"
                        dtgLine[i+1] = "YR"
                        for element in dtgLine {
                            if element.count == 4 {
                                if timeData == "" {
                                    timeData += element + "."
                                } else {
                                    timeData += element
                                }
                            }
                        }
                    }
                }
                else if dtgLine[i-1].count == 4 && i >= 2 {
                    if timeData == "" {
                        timeData += dtgLine[i-1] + "."
                    } else {
                        timeData += dtgLine[i-1]
                    }
                    if firstDate == "" {
                        firstDate = dtgLine[i-2] + " " + monthTitles[index+2-(index%3)] + " " + dtgLine[i+1].suffix(2)
                    } else {
                        secondDate = dtgLine[i-2] + " " + monthTitles[index+2-(index%3)] + " " + dtgLine[i+1].suffix(2)
                    }
                }
            }
            // Date 변환 가능한지, 두 날짜가 같은지
        }
        if firstDate.count == 8 {
            firstDate = "0" + firstDate
        }
        if secondDate.count == 8 {
            secondDate = "0" + secondDate
        }
        
        var bldg1 = ""
        var camp1 = ""
        var bldg2 = ""
        var camp2 = ""
        var detail1 = ""
        var detail2 = ""
        var locationLine = dataString[4].components(separatedBy: "   ").filter({ $0 != "" })
        var firstLocation = locationLine.first!.components(separatedBy: " ").filter({ $0 != "" })
        var secondLocation = locationLine.last!.components(separatedBy: " ").filter({ $0 != "" })
        for element in firstLocation {
            if campTitles.contains(element) {
                camp1 = campTitlesChange[element]!
            }
        }
        for element in secondLocation {
            if campTitles.contains(element) {
                camp2 = campTitlesChange[element]!
            }
        }
        
        let number1 = locationLine.first!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if number1.count == 4 || number1.count == 3 {
            bldg1 = number1
        }
        else if number1.count > 4 {
            bldg1 = String(number1.suffix(4))
        }
        
        let number2 = locationLine.last!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if number2.count == 4 || number2.count == 3 {
            bldg2 = number2
        }
        else if number2.count > 4 {
            bldg2 = String(number2.suffix(4))
        }
        
        if bldg1 == "" || camp1 == "" {
            detail1 = locationLine.first!
        }
        if bldg2 == "" || camp2 == "" {
            detail2 = locationLine.last!
        }
        
        var busData = 1
        var paxData = 45
        var truckData = 0
        var allinone = ""
        for i in 5..<dataString.count {
            allinone += dataString[i] + " "
        }
        let allArray = allinone.lowercased().components(separatedBy: " ").filter({ $0 != "" })
        for i in 0..<allArray.count {
            let element = allArray[i]
            if element == "soldiers" {
                if paxData == 45 {
                    paxData = Int(allArray[i-1])!
                }
            }
            if element.suffix(1) == "x" && numberSet.contains(element[element.index(element.startIndex, offsetBy: 0)]) && element.count < 4 {
                if numberSet.contains(element[element.index(element.startIndex, offsetBy: 1)]) {
                    if allArray[i+1] == "bus" || allArray[i+1] == "buses" || allArray[i+2] == "bus" || allArray[i+2] == "buses" {
                        if busData == 1 {
                            busData = Int(String(element.prefix(2)))!
                        }
                    }
                    else if allArray[i+1] == "pax" || allArray[i+1] == "personnel" || allArray[i+1] == "soldiers" {
                        if paxData == 45 {
                            paxData = Int(String(element.prefix(2)))!
                        }
                    }
                } else {
                    if allArray[i+1] == "bus" || allArray[i+1] == "buses" || allArray[i+2] == "bus" || allArray[i+2] == "buses" {
                        if busData == 1 {
                            busData = Int(String(element.prefix(1)))!
                        }
                    }
                    else if allArray[i+1] == "pax" || allArray[i+1] == "personnel" || allArray[i+1] == "soldiers" {
                        if paxData == 45 {
                            paxData = Int(String(element.prefix(2)))!
                        }
                    }
                }
            }
            
            if element.suffix(5) == "truck" {
                truckData = 1
            }
            
        }
        
        let extracted_cmr = ["status": "Submitted", "unit": unitData, "date": firstDate, "dateInNum": dateToInt(date: firstDate), "departTime": timeData.components(separatedBy: ".")[0], "arrivalTime": timeData.components(separatedBy: ".")[1], "isRoundTrip": 1, "originCamp": camp1, "originBLDG": bldg1, "originDetail": detail1, "destinationCamp": camp2, "destinationBLDG": bldg2, "destinationDetail": detail2, "quantity": busData, "pax": paxData, "issuedTruck": truckData, "pocName": pocNameData, "pocNumber": pocPhoneData, "MSN": ""] as [String: Any]
        
        return extracted_cmr
    }
    
    func dateToInt(date: String) -> Int {
        dateFormatter.dateFormat = "dd MMM yy"
        let basicDate = dateFormatter.date(from: "01 JAN 20")
        let inputDate = dateFormatter.date(from: date)
        let interval = calender.dateComponents([.day], from: basicDate!, to: inputDate!)
        return interval.day!
    }
}
