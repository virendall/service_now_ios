//
//  ViewController.swift
//  SNInterview
//
//  Copyright © 2019 ServiceNow. All rights reserved.
//

import UIKit
import Combine

class ViewController: UITableViewController {

    lazy var viewModel = ReviewViewModel()
    
    private var bindings = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBindings()
        viewModel.loadReviews()
    }
    
    @IBAction private func refresh() {
        viewModel.loadReviews()
    }
    
    private func setUpBindings() {
        viewModel.$reviews
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &bindings)
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] state in
                self?.stateValueHandler(state)
            })
            .store(in: &bindings)
    }
    
    func display(_ state: ReviewViewModelState) {
        if state == .loading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    func showError(_ state: ReviewViewModelState) {
        if case .error(let err) = state {
            showAlert("Error", msg: err)
        }
    }
    
    private func stateValueHandler(_ state: ReviewViewModelState) {
        self.display(state)
        self.showError(state)
    }
}

// MARK: - Table DataSource

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reviews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReviewTableViewCell = tableView.dequeueReusableCell()
        cell.reviewView.nameLabel.text = viewModel.reviews[indexPath.row].name
        cell.reviewView.reviewLabel.text = viewModel.reviews[indexPath.row].review
        cell.reviewView.ratingLabel.text = "\(viewModel.reviews[indexPath.row].rating)%"
        return cell
    }
}

// MARK: - Table Delegate

extension ViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
