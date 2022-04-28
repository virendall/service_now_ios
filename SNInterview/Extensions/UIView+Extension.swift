//
//  UIView+Extension.swift
//  SNInterview
//
//  Created by Virender Dall on 28/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import UIKit

extension UIView {
    
    func loadView<T: UIView>(_ type : T.Type) {
        Bundle.main.loadNibNamed(T.description().className, owner: self, options: nil)
    }
    
    func fixIn(superview: UIView,
                        padding: UIEdgeInsets = UIEdgeInsets.zero){
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = superview.frame;
        superview.addSubview(self);
        superview.addConstraints([
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1.0, constant: padding.top),
            NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: superview, attribute: .left, multiplier: 1.0, constant: padding.left),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1.0, constant: padding.bottom),
            NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: superview, attribute: .right, multiplier: 1.0, constant: padding.right)
        ]);
    }
}
