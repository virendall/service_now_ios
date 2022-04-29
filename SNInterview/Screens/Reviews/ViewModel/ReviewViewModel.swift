//
//  ReviewViewModel.swift
//  SNInterview
//
//  Created by Virender Dall on 28/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import Foundation
import Combine
import UIKit

enum ReviewViewModelState: Equatable {
    case loading
    case finish
    case error(String)
}


class ReviewViewModel: ObservableObject {
    @Published private(set) var reviews: [CoffeeShop] = []
    
    @Published private(set) var state: ReviewViewModelState = .finish
    
    public let loader: ReviewLoader!
    
    private var bindings = Set<AnyCancellable>()
    
    init(loader: ReviewLoader = LocalFileReviewLoader()) {
        self.loader = loader
    }
    
    func loadReviews()  {
        self.loader.load(endPoint: FileEndPoint.reviews).sink {[weak self] completion in
            switch completion {
            case let .failure(error):
                self?.state = .error(error.localizedDescription)
            case .finished:
                self?.state = .finish
            }
        } receiveValue: {[weak self] reviews in
            self?.reviews = reviews
        }
        .store(in: &bindings)
    }
    
    func sortReviews() {
        self.reviews = self.reviews.sorted { $0.rating > $1.rating }
    }
}
