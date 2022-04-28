//
//  String+Extension.swift
//  SNInterview
//
//  Created by Virender Dall on 28/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import Foundation

extension String {
    var className:String {
        return self.components(separatedBy: ".").last!
    }
}
