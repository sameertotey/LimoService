//
//  LimoRequestCreationState.swift
//  LimoService
//
//  Created by Sameer Totey on 5/18/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation

enum ActiveField {
    case From
    case To
}
struct RequestCreationState {
        var dateSet       = false
        var fromSet       = false
        var toSet         = false
        var passengersSet = false
        var bagsSet       = false
        var carTypeSet    = false
        var commentSet    = false

     func getStepName() -> String {
        var returnString = ""
        switch (dateSet, fromSet, toSet) {
        case (false, false, false):
            returnString = "Select Date/Time"
        default:
            println("new state added")
        }
        return returnString
    }
}
