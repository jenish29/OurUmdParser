//
//  RatingController.swift
//  UmdUtility
//
//  Created by pc on 7/10/17.
//  Copyright © 2017 Jenish. All rights reserved.
//

import UIKit

class RatingController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    
    var teacherName = ""
    var dictionary : [[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
       data()
    }
    
    @IBOutlet var mainTable: UITableView!
    func data() {
        let url = "http://www.ourumd.com/reviews/" + teacherName.replacingOccurrences(of: " " , with: "%20")
        
        let parser = RatingParser()
        parser.parse(string: url) { 
            self.dictionary = parser.getData()
            self.mainTable.reloadData()
        }
        
        
    
    }
    
    //tableview functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell
        
        if dictionary.count > 0 {
            let dictionary = self.dictionary[indexPath.row]
        
            let rating = dictionary["rating"]
            let commet = dictionary["comment"]
            let course = dictionary["course"]
            let grade = dictionary["grade"]
            
            cell.rating.text = rating
            cell.commet.text = commet
            DispatchQueue.main.async {
                let desiredOffset = CGPoint(x: 0, y: -cell.commet.contentInset.top)
                
                cell.commet.setContentOffset(desiredOffset, animated: false)
            }
            
            cell.course.text = course
            cell.grade.text = grade
            cell.setNeedsLayout()
        }
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionary.count
    }
    

}

class CustomCell : UITableViewCell {
    @IBOutlet var rating: UILabel!
    @IBOutlet var course: UILabel!
    @IBOutlet var commet: UITextView!
    @IBOutlet var grade: UILabel!
    
}
