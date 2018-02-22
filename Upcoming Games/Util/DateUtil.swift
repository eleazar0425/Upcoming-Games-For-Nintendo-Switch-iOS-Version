//
//  DateUtil.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/20/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation

class DateUtil {
    
    class func parse(from dateString: String) -> Date?{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let date = formatter.date(from: dateString)
        return date
    }
    
    class func daysBetweenDates(_ firstDate: Date, _ secondDate: Date) -> Int? {
        let calendar = NSCalendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: firstDate)
        let date2 = calendar.startOfDay(for: secondDate)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day
    }
    
}
