//
//  RatingParser.swift
//  UmdUtility
//
//  Created by pc on 7/10/17.
//  Copyright © 2017 Jenish. All rights reserved.
//

import Foundation

class RatingParser {
    
    
    func matchesForRegexInText(regex: String, text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                                        options: [], range: NSMakeRange(0, nsString.length))
            let maps =  results.map { nsString.substring(with: $0.range)}
            return maps
        } catch {
            return []
        }
    }
    
    func parse(string: String,completionHandler: @escaping () -> Swift.Void){
        
        let url = NSURL(string: string)
        
        DispatchQueue.global().async {
            do {
                let st = try NSString.init(contentsOf: url! as URL, encoding: String.Encoding.ascii.rawValue)
                
                DispatchQueue.main.async {
                    self.ratingParser(sc: st as String)
                    completionHandler()
                }
                
            }
            catch {
                
            }
        }
    }
    
    func getData() -> [[String:String]]  {
        return ratings
    }
    private var ratings : [[String:String]] = []
    
    //this function will get the review for the teacher and the number of stars
    func ratingParser(sc : String) {
        var parser = "<table[\\s|\\S]*</table"
        var parsedData = matchesForRegexInText(regex: parser, text: sc)
        
        if parsedData.count > 0 {
            parser = "<tr>[\\s|\\S]*?</tr"
            parsedData = matchesForRegexInText(regex: parser, text: parsedData[0])
            
            if parsedData.count > 0 {
                parsedData.remove(at: 0)
                for data in parsedData {
                    parser = "avg=\\d"
                    
                    var stars = matchesForRegexInText(regex: parser, text: data)[0]
                    stars = stars.replacingOccurrences(of: "avg=", with: "")
                    
                    parser = "<td>[\\s|\\S]*?</td"
                    var comment = matchesForRegexInText(regex: parser, text: data)[1]
                    comment = comment.replacingOccurrences(of: "<td>", with: "")
                    comment = comment.replacingOccurrences(of: "</td", with: "")
                    comment = comment.replacingOccurrences(of: "<br /", with: "")
                    comment = comment.replacingOccurrences(of: ">", with: "")
                    
                    parser = "Course:[\\s|\\S]*?<br"
                    var course = matchesForRegexInText(regex: parser, text: data)[0]
                    course = course.replacingOccurrences(of: "<br", with: "")
                    
                    parser = "Grade Expected:[\\s|\\S]*?<br"
                    var grade = matchesForRegexInText(regex: parser, text: data)[0]
                    grade = grade.replacingOccurrences(of: "<br", with: "")
            
                    let dictionary = ["Stars" : stars, "comment" : comment, "course" : course, "grade":grade]
                    ratings.append(dictionary)
                    
                    
                }
            }
            
            
        }
        
        
    }
    
}
