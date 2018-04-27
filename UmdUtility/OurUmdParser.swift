//
//  AmazonParser.swift
//  FindOffer
//
//  Created by Pc on 6/14/17.
//  Copyright © 2017 Pc. All rights reserved.
//

import Foundation
import UIKit

class OurUmdParser {
    
    private var overAllGradeDictionary : NSMutableDictionary = ["overAllGrade" : 0.0,"overAllDistributed" : []]
    private var overAllGrade : Double = 0.0
    private var teachers = Teacher()
    
    func matchesForRegexInText(regex: String, text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                                        options: [], range: NSMakeRange(0, nsString.length))
            let maps =  results.map { nsString.substring(with: $0.range)}
            return maps
        } catch let error as NSError {
            
            return []
        }
    }
    
    func parse(string: String,completionHandler: @escaping () -> Swift.Void){
        
        let url = NSURL(string: string)
        
        DispatchQueue.global().async {
            do {
                let st = try NSString.init(contentsOf: url! as URL, encoding: String.Encoding.ascii.rawValue)
                
                DispatchQueue.main.async {
                    self.oudUmdParser(dataString: st as String)
                    completionHandler()
                }
                
            }
                
            catch {
                
            }
        }
        
        
    }
    
    func getData() -> NSArray {
      return [overAllGradeDictionary,teachers]
    }
    
    func oudUmdParser(dataString : String) {
        
        getTitle(data: dataString)
        
        let itemTitlePattern = "<table width = \"100%\" cellspacing = \"0\" cellpadding = \"2\"[(\\s)|(\\S)]*?id=\"leftside"
        let tables = matchesForRegexInText(regex: itemTitlePattern, text: dataString)
        
        if tables.count > 0 {
          
            getTeacherName(data: tables[0])
            
            let mainTableParser = "<table width = \"100%\" cellspacing = \"0\" cellpadding = \"2\"[(\\s)|(\\S)]*?Historical Grade Data for Professors"
            let overData = matchesForRegexInText(regex: mainTableParser, text: tables[0])
           
            if overData.count > 0 {
                getOverAllGrade(data:overData[0])
            }
            
            }
        
    }
    
    func getTeacherName(data:String) {
        var parser = "<tr class = \\\"front\\\">[\\s|\\S]*?<tr><td colspan = \"2"
        var parsed = matchesForRegexInText(regex: parser, text: data)
        parsed.remove(at: 0)
        
        var curr = teachers
        var secondCurr = teachers
        var thirdCurr = teachers
        var fourthCurr = teachers
        
        for pars in parsed  {
         
            parser = "<a href = [\\s|\\S]*?</a"
            let teacherName = matchesForRegexInText(regex: parser, text: pars)
            if teacherName.count > 0 {
                parser = ">[\\s|\\S]*?<"
                let teacherN = matchesForRegexInText(regex: parser, text: teacherName[0])
                
                if teacherN.count > 0 {
                    var name = teacherN[0].replacingOccurrences(of: ">", with: "")
                    name = name.replacingOccurrences(of: "<", with: "")
                  
                    curr.teacherName = name
                    curr.next = Teacher()
                    curr.next?.prev = curr
                    curr = curr.next!
                    
                }
            }
            
            let hasData = "No Grade"
            let hasDataP = matchesForRegexInText(regex: hasData, text: pars)
            
            if hasDataP.count == 0 {
                parser = "<tr class = \\\"grade\\\">[\\s|\\S]*?colspan = \\\"3\\\">.*?</tr"
                let grades = matchesForRegexInText(regex: parser, text: pars)
                if grades.count > 0 {
                    for grade in grades {
                        parser = "<td>[\\d|\\.]+</td>"
                        let gradesParsed = matchesForRegexInText(regex: parser, text: grade)
                        if gradesParsed.count > 0 {
                            let doubleParser =  "[\\d|\\.]+"
                            let final  = matchesForRegexInText(regex: doubleParser, text: gradesParsed[0])
                            if final.count > 0 {
                                secondCurr.overAllGradeDictionary.setValue(final[0].toDouble(), forKey: "overAllGrade")
                                secondCurr = secondCurr.next!
                            }
                            
                        }
                    }
                }
                
                parser =  "<tr>[\\s|\\S]*?</tr"
                parsed = matchesForRegexInText(regex: parser, text: pars)
                if parsed.count > 0 {
                    var overAllGradeDistributed : [[String]] = []
                    for singleDistribution in parsed {
                        let singleParser = "\\d+%"
                        let ps = matchesForRegexInText(regex: singleParser, text: singleDistribution)
                        
                        if ps.count > 0
                        {
                            overAllGradeDistributed.append(ps)
                        }
                        
                    }
                    
                    thirdCurr.overAllGradeDictionary.setValue(overAllGradeDistributed, forKey: "overAllDistributed")
                    thirdCurr = thirdCurr.next!
                    
                }
                
                parser = "\\d+\\s(reviews|Reviews)+"
                parsed = matchesForRegexInText(regex: parser, text: pars)
                if parsed.count > 0 {
                    fourthCurr.numOfReviews = parsed[0]
                }
                
                parser = "Grade Data[\\s|\\S]+?\\."
                parsed = matchesForRegexInText(regex: parser, text: pars)
                if parsed.count > 0 {
                 fourthCurr.totalData = parsed[0]
                }
                fourthCurr = fourthCurr.next!
   
            }else{
                
               secondCurr = secondCurr.next!
               thirdCurr = thirdCurr.next!
               fourthCurr = fourthCurr.next!
            }
            
            
        }
    
    }
    
    func getTitle(data:String) {
        let parser = "class = \"pageheading\"[\\s|\\S]*?</p"
        let parsed = matchesForRegexInText(regex: parser, text: data)
        
        if parsed.count > 0 {
            var title = parsed[0]
            
            title = title.replacingOccurrences(of:"class = \"pageheading\">", with: "")
            title = title.replacingOccurrences(of: "<i> </i>", with: "")
            title = title.replacingOccurrences(of: "</p", with: "")
            self.overAllGradeDictionary.setValue(title, forKey: "title")
        }
        
        
    }
    func getOverAllGrade(data:String){
        
            let overDataParse = "<tr class = \"grade\"[(\\s)|(\\S)]*?cols"
            let overDataParsed = matchesForRegexInText(regex: overDataParse, text: data)
        
            if overDataParsed.count > 0 {
                //gets overall grade
                let overAllGrade = "<td>[\\d|\\.]+</td>"
                let overAllGradeP = matchesForRegexInText(regex: overAllGrade, text: overDataParsed[0])
                if overAllGradeP.count > 0 {
                    let finalP = overAllGradeP[0]
                    let doubleParser =  "[\\d|\\.]+"
                    let final  = matchesForRegexInText(regex: doubleParser, text: finalP)
                    self.overAllGradeDictionary.setValue(final[0].toDouble(), forKey: "overAllGrade")
                }
                // end getting overall grade
                
                //getting distribution of grades
                let distributionsParser = "<tr>[\\s|\\S]*?</tr"
                let distributionData = matchesForRegexInText(regex: distributionsParser, text: data)
                var overAllGradeDistributed : [[String]] = []

                for singleDistribution in distributionData {
                   let singleParser = "\\d+%"
                   let parsed = matchesForRegexInText(regex: singleParser, text: singleDistribution)
                  
                    if parsed.count > 0
                    {
                       overAllGradeDistributed.append(parsed)
                    }
                }
                
                self.overAllGradeDictionary.setValue(overAllGradeDistributed, forKey: "overAllDistributed")
                
                
            }
        }
}

