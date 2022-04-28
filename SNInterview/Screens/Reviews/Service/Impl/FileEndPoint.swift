//
//  FileEndPoint.swift
//  SNInterview
//
//  Created by Virender Dall on 28/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import Foundation

enum FileEndPoint {
    case reviews
}

extension FileEndPoint: EndPoint {
    var path: String {
        switch self {
        case .reviews:
           return "CoffeeShops"
        }
    }
}
