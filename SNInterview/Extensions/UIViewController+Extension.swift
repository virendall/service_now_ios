//
//  UIViewController+Extension.swift
//  SNInterview
//
//  Created by Virender Dall on 28/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(_ title: String? = nil, msg: String?, buttonText: String = "OK") {
        let alert = UIAlertController(
            title: title,
            message: msg,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: buttonText, style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
