//
//  ExtensionHelpers.swift
//  Shoveled
//
//  Created by Joshua Walsh on 12/15/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import Foundation

public extension Dictionary {

    func has(key: Key) -> Bool {
        return index(forKey: key) != nil
    }

    public func jsonData(prettify: Bool = false) -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: options)
            return jsonData
        } catch {
            return nil
        }
    }
}

// MARK: Adds days to date
// Used for transfers
public func addDaysToCurrentDate() -> String {
    let futureTime = Calendar.current.date(byAdding: .day, value: 2, to: Date())
    let dateFormatter = DateFormatter()
    if let futureTime = futureTime {
        let dateString = dateFormatter.string(from: futureTime)
        return dateString
    }
    return ""
}
