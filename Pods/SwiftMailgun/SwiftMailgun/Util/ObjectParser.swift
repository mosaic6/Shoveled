//
//  ObjectParser.swift
//  SwiftMailgun
//
//  Created by Christopher Jimenez on 3/7/16.
//  Copyright © 2016 Chris Jimenez. All rights reserved.
//

import Foundation

import ObjectMapper

public class ObjectParser {

    /**
     Converts and parse and object from a json file for testing
     
     - parameter fileName: file name
     
     - returns: object conforming to Mappable
     */
    public class func objectFromJson<T: Mappable>(json: AnyObject?) -> T? {

        return Mapper<T>().map(json)
    }

    /**
     Converts and parse and object from a json string
     
     - parameter json: String
     
     - returns:
     */
    public class func objectFromJsonString<T: Mappable>(json: String?) -> T? {

        return Mapper<T>().map(json)
    }

    /**
     Converts and parse and object to an array
     - parameter fileName: filename
     
     - returns: array of objects
     */
    public class func objectFromJsonArray<T: Mappable>(json: AnyObject?) -> [T]? {

        return Mapper<T>().mapArray(json)
    }

}
