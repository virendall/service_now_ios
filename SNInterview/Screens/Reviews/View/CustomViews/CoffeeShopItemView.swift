//
//  CoffeeShopItemView.swift
//  SNInterview
//
//  Copyright © 2019 ServiceNow. All rights reserved.
//

import UIKit

class CoffeeShopItemView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        loadView(CoffeeShopItemView.self)
        contentView.fixIn(superview: self)
    }
    
    func updateView(info: CoffeeShop) {
        self.nameLabel.text = info.name
        self.ratingLabel.text = "\(info.rating)%"
        self.reviewLabel.text = info.review
    }
}
