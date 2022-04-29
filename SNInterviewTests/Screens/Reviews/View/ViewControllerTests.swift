//
//  ViewControllerTests.swift
//  SNInterviewTests
//
//  Created by Virender Dall on 28/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import XCTest
import Combine
@testable import SNInterview
extension ReviewTableViewCell {
    
    var nameText: String? {
        return reviewView.nameLabel.text
    }
    
    var reviewText: String? {
        return reviewView.reviewLabel.text
    }
    
    var ratingText: String? {
        return reviewView.ratingLabel.text
    }
}

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}

extension ViewController {
    func simulateUserInitiatedReviewReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func numberOfRenderedReviews() -> Int {
        return tableView.numberOfRows(inSection: reviewSection)
    }
    
    func reviewView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: reviewSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var reviewSection: Int {
        return 0
    }
}

class ViewControllerTests: XCTestCase {
    var cancallables: Set<AnyCancellable> = []
    func test_loadAction_requestFromLoader() {
        let(sut, loader) = makeSUTWithMemoryLeak()
        XCTAssertEqual(loader.callCount, 0, "before view load expecting no request loading call")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.callCount, 1, "a loading request expected after view loaded")
        
        sut.simulateUserInitiatedReviewReload()
        XCTAssertEqual(loader.callCount, 2, "Expected loading request once user initiates a reload")
    }
    
    func test_loadSuccess_rendersReviews() {
        let(sut, loader) = makeSUTWithMemoryLeak()
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        let result = [mockReview(rating: 0), mockReview(rating:1), mockReview(rating: 2)]
        loader.result = .success(result)
        let exp = expectation(description: "Waiting for data fetch")
        sut.viewModel.loadReviews()
        sut.viewModel.$reviews
            .receive(on: DispatchQueue.main)
            .sink { _ in
                exp.fulfill()
            }.store(in: &cancallables)
        wait(for: [exp], timeout: 2)
        assertThat(sut, isRendering: result)
    }
    
    func test_loadFailure_presentAlert() {
        let sut = MockViewController()
        let loader = ReviewLoaderSpy()
        sut.viewModel = ReviewViewModel(loader: loader)
        sut.loadViewIfNeeded()
        loader.result = .failure(FileError.invalidPath)
        let exp = expectation(description: "Waiting for data fetch")
        sut.viewModel.loadReviews()
        sut.viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { _ in
                exp.fulfill()
            }.store(in: &cancallables)
        wait(for: [exp], timeout: 1)
        let alertController = sut.presentViewControllerTarget as? UIAlertController
        XCTAssertNotNil(alertController, "UIAlertController was not presented")
        XCTAssertEqual(alertController?.title, "Error")
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(loader)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ViewController, loader: ReviewLoaderSpy) {
        let loader = ReviewLoaderSpy()
        let bundle = Bundle(for: ViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let sut = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        sut.viewModel = ReviewViewModel(loader: loader)
        return (sut, loader)
    }
    private func makeSUTWithMemoryLeak(file: StaticString = #file, line: UInt = #line) -> (sut: ViewController, loader: ReviewLoaderSpy) {
        let (sut, loader) = makeSUT()
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    func assertThat(_ sut: ViewController, isRendering review: [CoffeeShop], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedReviews() == review.count else {
            return XCTFail("Expected \(review.count) images, got \(sut.numberOfRenderedReviews()) instead.", file: file, line: line)
        }
        
        review.enumerated().forEach { index, review in
            assertThat(sut, hasViewConfiguredFor: review, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: ViewController, hasViewConfiguredFor review: CoffeeShop, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.reviewView(at: index)
        
        guard let cell = view as? ReviewTableViewCell else {
            return XCTFail("Expected \(ReviewTableViewCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        XCTAssertEqual(cell.nameText, review.name, "Expected name text to be \(String(describing: review.name)) for review view at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell.reviewText, review.review, "Expected review text to be \(String(describing: review.review)) for review view at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell.ratingText, "\(review.rating)%", "Expected review rating to be \(String(describing: review.rating)) for review view at index (\(index))", file: file, line: line)
    }
    
    private func mockReview(
        name: String = "Loreum", review: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat", rating: Int = 1
    ) -> CoffeeShop {
        return CoffeeShop(
            name: name, review: review, rating: rating
        )
    }
    
    class MockViewController: ViewController {
        var presentViewControllerTarget: UIViewController?
        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            presentViewControllerTarget = viewControllerToPresent
        }
    }
}
