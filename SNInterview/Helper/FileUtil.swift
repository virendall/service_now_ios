//
//  FileUtil.swift
//  SNInterview
//
//  Created by Virender Dall on 28/04/22.
//  Copyright © 2022 ServiceNow. All rights reserved.
//

import Foundation

class FileUtil {
    class func readJsonFile(name: String, bundle: Bundle) throws -> Data {
        guard let path = bundle.path(forResource: name, ofType: "json") else {
            throw FileError.invalidPath
        }
        return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    }
    
    class func readJsonFile(name: String) throws -> Data {
        let bundle: Bundle = Bundle(for: FileUtil.self)
        return try readJsonFile(name: name, bundle: bundle)
    }
}

enum FileError: Error {
    case invalidPath
}

extension FileError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidPath:
            return NSLocalizedString("Invalid file path.", comment: "")
        }
    }
}
