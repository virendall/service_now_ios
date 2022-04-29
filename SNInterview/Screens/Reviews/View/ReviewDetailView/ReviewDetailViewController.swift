//
//  ReviewDetailViewController.swift
//  SNInterview
//
//  Created by Virender Dall on 29/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import UIKit

class ReviewDetailViewController: UIViewController {
    var review: CoffeeShop!
    
    @IBOutlet weak var reviewView: CoffeeShopItemView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewView.updateView(info: review)
    }

    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
