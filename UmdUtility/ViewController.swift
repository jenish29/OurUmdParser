//
//  ViewController.swift
//  UmdUtility
//
//  Created by Jenish on 6/19/17.
//  Copyright © 2017 Jenish. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIPopoverPresentationControllerDelegate {
 
    @IBOutlet weak var classNameTextField: UITextField!
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bottomConstraintTitleLabel: NSLayoutConstraint!
    
    private var overAllGrade : Double = 0.0
    private var overAllGradeDistribution : [[String]] = []
    private var overAllTitle = ""
    private var deviceWidth = 0.0
    private var teachers : Teacher? = nil
    private var teachersArray : [Teacher] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceWidth =  Double(UIScreen.main.bounds.width)
    
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissC))
        gesture.direction = .right
        self.view.addGestureRecognizer(gesture)
        mainTableView.addGestureRecognizer(gesture)
        
    }
    func dismissC() {
        self.dismiss(animated: true, completion: nil)
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == classNameTextField{
            if classNameTextField.text != "" {
                parseData(toAppend: classNameTextField.text!)
            }
        }
        
        
        return true
    }
    
    func parseData(toAppend:String) {
        var url = "http://www.ourumd.com/class/"
        url = url.appending(toAppend)
     
        let umdParser = OurUmdParser()
        umdParser.parse(string: url) {
            
            let dictionary = umdParser.getData()[0] as! NSMutableDictionary
            var curr = umdParser.getData()[1] as? Teacher
            self.teachersArray = []
            
            while curr != nil {
                self.teachersArray.append(curr!)
                curr = curr?.next
            }
            
            self.overAllGrade = (dictionary.value(forKey: "overAllGrade") as? Double)!
            
            let overAllDisArr = dictionary.value(forKey: "overAllDistributed") as! [[String]]
            self.overAllGradeDistribution = overAllDisArr.count > 0 ? overAllDisArr : []
            
            self.titleLabel.text =  dictionary.value(forKey: "title") as? String
    
            self.mainTableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.teachersArray.count-1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "mainCell") as! TopCell!
                cell?.overAllGrade.text = "\(overAllGrade)"
            
            if deviceWidth < 350 {
                for spacing in (cell?.spacing)! {
                    spacing.constant = 12.5
                }
            }
            
            if overAllGradeDistribution.count == 0 {
                for grade in (cell?.mainPercentage)! {
                    grade.text = "0%"
                    grade.sizeToFit()
                }
                
                for subGrade in (cell?.subPercentage)! {
                    subGrade.text = "0%"
                    subGrade.sizeToFit()
                }
            }
            else{
                var counter = 0
                var subCounter = 0
                for distribution in overAllGradeDistribution  {
                    cell?.mainPercentage[counter].text = distribution[0]
                    cell?.mainPercentage[counter].sizeToFit()
                    
                    if(distribution.count >= 2) {
                        cell?.subPercentage[subCounter].text = distribution[1]
                        subCounter+=1
                        
                        if(distribution.count >= 3) {
                            cell?.subPercentage[subCounter].text = distribution[2]
                            subCounter+=1
                            
                            if(distribution.count >= 4) {
                                cell?.subPercentage[subCounter].text = distribution[3]
                            }
                            subCounter += 1
                        }else{
                            subCounter += 2
                        }
                        
                    
                    }else { subCounter+=3 }
                   
                    
              
                    counter += 1
                }
            }
            return cell!
        }else{
          
            let cell =  tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell!
            let teacher = teachersArray[indexPath.row]
            
            //device is iphone 5
            if deviceWidth < 350 {
                for spacing in (cell?.spacing)! {
                        spacing.constant = 12.5
                }
                
                DispatchQueue.main.async {
                    cell?.width.constant = 180
                    cell?.leftMargin.constant = 2
                    cell?.numStudents.numberOfLines = 3
                }
            }
            
            
            if let name = teacher.teacherName {
                cell?.teacherName.text = name
            }
            
            cell?.numReviews.text = teacher.numOfReviews
            cell?.numReviews.sizeToFit()
            cell?.numStudents.text = teacher.totalData
            
            if let overAllGradeDistributions = teacher.overAllGradeDictionary.value(forKey: "overAllDistributed") as? [[String]] {
                
                if overAllGradeDistributions.count == 0 {
                    for grade in (cell?.mainPercentage)! {
                        grade.text = "0%"
                        grade.sizeToFit()
                    }
                    
                    for subGrade in (cell?.subPercentage)! {
                        subGrade.text = "0%"
                        subGrade.sizeToFit()
                    }
                }
                
                var counter = 0
                var subCounter = 0
                for distribution in overAllGradeDistributions  {
                    cell?.mainPercentage[counter].text = distribution[0]
                    cell?.mainPercentage[counter].sizeToFit()
                    
                    if(distribution.count >= 2) {
                        cell?.subPercentage[subCounter].text = distribution[1]
                        subCounter+=1
                        
                        if(distribution.count >= 3) {
                            cell?.subPercentage[subCounter].text = distribution[2]
                            subCounter+=1
                            
                            if(distribution.count >= 4) {
                                cell?.subPercentage[subCounter].text = distribution[3]
                            }
                            subCounter += 1
                        }else{
                            subCounter += 2
                        }
           
                    }else { subCounter+=3 }
                    counter += 1
                }

            }
      
            return cell!
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedCell = tableView.cellForRow(at: indexPath) as? Cell {
            //creating a popover controller
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "rating") as! RatingController
            controller.teacherName = selectedCell.teacherName.text!
            
            controller.modalPresentationStyle = .popover
            controller.popoverPresentationController?.delegate = self
            controller.popoverPresentationController?.sourceView = selectedCell
            controller.popoverPresentationController?.sourceRect = (selectedCell.bounds)
            controller.preferredContentSize = CGSize(width: (selectedCell.contentView.frame.size.width) + 50 , height: (selectedCell.contentView.frame.size.height) + 250
            )
            self.present(controller, animated: false, completion: nil)
        }
        
  
        
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
   

}
class TopCell : UITableViewCell {
    @IBOutlet weak var overAllGrade: UILabel!
    @IBOutlet var mainPercentage: [UILabel]!
    @IBOutlet var subPercentage: [UILabel]!
    @IBOutlet var spacing: [NSLayoutConstraint]!
   
 
}
class Cell : UITableViewCell {
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet var mainPercentage: [UILabel]!
    @IBOutlet var subPercentage: [UILabel]!
    @IBOutlet var numReviews: UILabel!
    @IBOutlet var numStudents: UILabel!
    @IBOutlet var leftMargin: NSLayoutConstraint!
    @IBOutlet var width: NSLayoutConstraint!
 
    @IBOutlet var spacing: [NSLayoutConstraint]!
}



