//
//  LocalFileReviewLoader.swift
//  SNInterview
//
//  Created by Virender Dall on 28/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import Foundation
import Combine

class LocalFileReviewLoader: ReviewLoader {
    func load() -> AnyPublisher<[CoffeeShop], Error> {
        return Future<[CoffeeShop], Error> { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try FileUtil.readJsonFile(name: "CoffeeShops")
                    let reviews = try JSONDecoder().decode([CoffeeShop].self, from: data)
                    promise(.success(reviews))
                } catch {
                    promise(.failure(error))
                }
                
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
