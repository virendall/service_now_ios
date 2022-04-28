//
//  File.swift
//  SNInterview
//
//  Created by Virender Dall on 28/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import Foundation
import Combine

protocol ReviewLoader {
    func load() -> AnyPublisher<[CoffeeShop], Error>
}
