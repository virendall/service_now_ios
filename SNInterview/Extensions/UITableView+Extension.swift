//
//  Created by Virender Dall on 28/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import UIKit

extension UITableView {
	func dequeueReusableCell<T: UITableViewCell>() -> T {
		let identifier = String(describing: T.self)
		return dequeueReusableCell(withIdentifier: identifier) as! T
	}
}
