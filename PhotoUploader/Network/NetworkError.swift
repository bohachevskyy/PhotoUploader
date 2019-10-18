//
//  NetworkError.swift
//  NewsApp
//
//  Created by Dmytro Bohachevskyi on 30/05/2019.
//  Copyright © 2019 Dmytro Bohachevskyi. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case encodingFailed
    case decodingFailed
    case noData
    case serverError(description: String)
    case connectionError(error: Error)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingFailed:
            return "Encoding Failed"
        case .decodingFailed:
            return "Decoding Failed"
        case .noData:
            return "No Data"
        case .serverError(let description):
            if description.lowercased().contains("limit") && description.lowercased().contains("error") {
                return "You have reached API limit for this key. Please change it inside of RecipeAPIRouter.swift"
            } else {
                return description
            }
        case .connectionError(let error):
            return error.localizedDescription
        }
    }
}
