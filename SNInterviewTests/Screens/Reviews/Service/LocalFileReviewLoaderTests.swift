//
//  LocalFileReviewLoaderTests.swift
//  SNInterviewTests
//
//  Created by Virender Dall on 28/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import XCTest
import Combine
@testable import SNInterview

class LocalFileReviewLoaderTests: XCTestCase {
    var cancallable: Set<AnyCancellable> = []

    func test_load_invalidPathShouldPublishInvalidPathError() {
        let sut = makeSUT()
        expect(toCompleteWith: .failure(FileError.invalidPath)) {
            return sut.load(endPoint: ErrorCaseEndPoint.invalidFile)
        }
    }
    
    func test_load_invalidJsonShouldPublishInvalidPathError() {
        let sut = makeSUT()
        var err: DecodingError!
        do {
            let data = "Invalid Data".data(using: .utf8)
            _ = try JSONDecoder().decode([CoffeeShop].self, from: data!)
        } catch {
            err = error as? DecodingError
        }
        expect(toCompleteWith: .failure(err)) {
            return sut.load(endPoint: ErrorCaseEndPoint.invalidJson)
        }
    }
    
    func test_load_validJsonShouldPublishReviews() {
        let sut = makeSUT()
        let data = try! FileUtil.readJsonFile(name: FileEndPoint.reviews.path)
        let coffeeShop = try! JSONDecoder().decode([CoffeeShop].self, from: data)
        expect(toCompleteWith: .success(coffeeShop)) {
            return sut.load(endPoint: FileEndPoint.reviews)
        }
    }
    
    // MARK: - Helpers
    
    private enum ErrorCaseEndPoint: EndPoint {
        var path: String {
            switch self {
            case .invalidJson:
                return "Invalid"
            case .invalidFile:
                return "NotAFile"
            }
        }
        
        case invalidJson
        case invalidFile
    }
    
    
    private func makeSUT(endPoint: EndPoint = FileEndPoint.reviews, file: StaticString = #file, line: UInt = #line) ->  LocalFileReviewLoader {
        let client = LocalFileReviewLoader()
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }
    
    
    private func expect(toCompleteWith expectedResult: Result<[CoffeeShop], Error>, when action: () -> AnyPublisher<[CoffeeShop], Error>, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Loading Data")
        var receivedResult: Result<[CoffeeShop], Error> = .success([])
        action()
            .sink { completion in
                switch completion {
                case let .failure(err):
                    receivedResult = .failure(err)
                default:
                    break
                }
                exp.fulfill()
                
            } receiveValue: { reviews in
                receivedResult = .success(reviews)
            }
            .store(in: &cancallable)
        wait(for: [exp], timeout: 1)
        switch (receivedResult, expectedResult) {
        case let (.success(receivedImages), .success(expectedImages)):
            XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
        case let (.failure(receivedError), .failure(expectedError)):
            XCTAssertEqual(receivedError.localizedDescription, expectedError.localizedDescription, file: file, line: line)
        default:
            XCTFail("Expected result \(expectedResult), got \(String(describing: receivedResult)) instead", file: file, line: line)
        }
    }
}
