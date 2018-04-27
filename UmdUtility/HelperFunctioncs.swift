//
//  HelperFunctioncs.swift
//  FindOffer
//
//  Created by Pc on 6/12/17.
//  Copyright © 2017 Pc. All rights reserved.
//

import Foundation
import UIKit

func convertDataToDictionary(data: Data) -> NSMutableDictionary? {
    
    do {
        return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSMutableDictionary
        
    } catch {
        return nil
    }
    
    
}


func convertDataToDictionaryArr(data: Data) -> NSArray? {
    
    do {
        return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSArray
        
    } catch {
        return nil
    }
    
    
}



extension UIView {
    
    func addConstraintWithFormat(format:String, views: UIView...){
        
        var viewsDictionary = [String:UIView]()
        for(index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        
        
    }
    
    
    func centerHorizontally (view : UIView, view2 : UIView) {
        let constriant = NSLayoutConstraint(item: view2, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(constriant)
        
    }
    
    func centerVetically (view : UIView, view2: UIView){
        let constriant = NSLayoutConstraint(item: view2, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        view.addConstraint(constriant)
    }
    
    // this function will add height constraint for the give view
    func addHeighet(height : CGFloat,view : UIView){
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
        
        
    }
    
    // this function will add the width constraint for the given view
    func addWidth(width: CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width))
    }
    
    
    // this function can be called if the given view needs to increase height
    func updateHeight(height:CGFloat, view:UIView){
        for constaint in view.constraints {
            if constaint.firstAttribute == NSLayoutAttribute.height
            {
                constaint.constant = height
            }
        }
        
        
    }
    
}


extension String {
    
    // this method returns the height required for the given string
    func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.sizeToFit()
        
        return label.frame.height
    }
    
    // this method returns the width of the given string that is needed
    func width(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let font = font
        let attributes = NSDictionary(object: font, forKey:NSFontAttributeName as NSCopying)
        let sizeOfText = self.size(attributes: (attributes as! [String : AnyObject]))
        
        
        return sizeOfText.width+3
    }
 
    func toDouble() -> Double? {
            return NumberFormatter().number(from: self)?.doubleValue
        }
    
    
}
