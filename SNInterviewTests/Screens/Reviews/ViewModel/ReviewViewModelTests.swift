//
//  ReviewViewModelTests.swift
//  SNInterviewTests
//
//  Created by Virender Dall on 28/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import XCTest
import Combine
@testable import SNInterview


class ReviewLoaderSpy: ReviewLoader {
    
    private(set) var callCount: Int = 0
    
    var result: Result<[CoffeeShop], Error> = .success([])
    
    func load(endPoint: EndPoint = FileEndPoint.reviews) -> AnyPublisher<[CoffeeShop], Error> {
        callCount += 1
        return result.publisher.eraseToAnyPublisher()
    }
}

class ReviewViewModelTests: XCTestCase {
    
    func test_init_doesNotRequestLoadReview() {
        let (_, client) = makeSUT()
        XCTAssertEqual(client.callCount, 0)
    }
    
    func test_load_ReviewsFromService() {
        let (sut, client) = makeSUT()
        sut.loadReviews()
        XCTAssertEqual(client.callCount, 1)
    }
    
    
    func test_loadTwice_ReviewsFromService() {
        let (sut, client) = makeSUT()
        
        sut.loadReviews()
        sut.loadReviews()
        
        XCTAssertEqual(client.callCount, 2)
    }
    
    func test_load_ReviewFromServiceReturnError() {
        let (sut, client) = makeSUT()
        let error = NSError(domain: "Test Error", code: 0)
        expect(sut, toCompleteWith: (.error(error.localizedDescription), []), when: {
            client.result = .failure(error)
        })
    }
    
    func test_load_ReviewFromServiceReturnEmptyResult() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: (.finish, []), when: {
            client.result = .success([])
        })
    }
    
    func test_load_ReviewFromServiceReturnResultShouldReplaceReviews() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: (.finish, [mockReview()]), when: {
            client.result = .success([])
        })
        expect(sut, toCompleteWith: (.finish, [mockReview()]), when: {
            client.result = .success([])
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ReviewViewModel, client: ReviewLoaderSpy) {
        let client = ReviewLoaderSpy()
        let sut = ReviewViewModel(loader: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    var cancallable: Set<AnyCancellable> = []
    
    private func mockReview(
        name: String = "Loreum", review: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat", rating: Int = 1
    ) -> CoffeeShop {
        return CoffeeShop(
            name: name, review: review, rating: rating
        )
    }
    
    private func expect(_ sut: ReviewViewModel, toCompleteWith resultSet: (expectedState: ReviewViewModelState, expectedResult: [CoffeeShop]), when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        action()
        sut.loadReviews()
        sut.$state
            .sink( receiveValue: { value in
                XCTAssertEqual(value, resultSet.expectedState, file: file, line: line)
            }
        ).store(in: &cancallable)
    }
}
