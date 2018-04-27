//
//  UmdMapViewController.swift
//  UmdUtility
//
//  Created by pc on 7/10/17.
//  Copyright © 2017 Jenish. All rights reserved.
//

import UIKit

class UmdMapViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var searchField: UITextField!
    @IBOutlet var tableV: UITableView!
    private var buildings : NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url  = "http://api.umd.io/v0/map/buildings"
        getData(url: url) { (data, response, err) in
            if err == nil {
                if let dictionary = convertDataToDictionaryArr(data: data!) {
                    self.buildings = dictionary
                    self.tableV.reloadData()
                    
                }
            }
        }
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissC))
        gesture.direction = .right
        self.view.addGestureRecognizer(gesture)
 
        
    }
    func dismissC() {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! BuildingInfoCell
        cell.buildingImage.image = nil
        
        if buildings.count > 0 {
            let data = buildings[indexPath.row] as! NSMutableDictionary
            
            if let image_url = data.value(forKey: "image_url") as? String {
                getImage(url: image_url, completionHandler: { (data, err) in
                    if err == nil && data != nil {
                        if tableView.cellForRow(at: indexPath) != nil {
                            if let image = UIImage(data: data!) {
                                cell.buildingImage.image = image
                            }
                        }
                        
                    }
                })
                
            }
            
            if let buildingName = data.value(forKey: "name") as? String {
                cell.buildingName.text = buildingName
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = buildings[indexPath.row] as! NSMutableDictionary
        
        let long = data.value(forKey: "lng") as? String
        let lat = data.value(forKey: "lat") as? String
        
        if long != nil && lat != nil {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "map") as! MapViewController
           
            controller.long = long!
            controller.lat = lat!
            
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
}

class BuildingInfoCell : UITableViewCell {
    @IBOutlet var buildingName: UILabel!
    @IBOutlet var buildingImage: UIImageView!
    
}

// adding padding to textfield
class MyTextField : UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 15, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
}
