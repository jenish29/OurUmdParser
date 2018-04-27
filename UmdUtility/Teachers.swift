//
//  Teachers.swift
//  UmdUtility
//
//  Created by Jenish on 6/20/17.
//  Copyright © 2017 Jenish. All rights reserved.
//

import Foundation
import UIKit

class Teacher {
    var next : Teacher? = nil
    var prev : Teacher? = nil
    
    var teacherName : String? = nil
    var numOfReviews : String? = nil
    var totalData : String? = nil
    
    var overAllGradeDictionary : NSMutableDictionary = ["overAllGrade" : 0.0,"overAllDistributed" : []]
    
    func getCount(count : Int) -> Int{
        if next != nil  {
           return (next?.getCount(count: count+1))!
        }
        else{
            return count
        }
    }
    
}
