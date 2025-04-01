//
//  AsyncExtensions.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 30/3/25.
//

import Foundation

extension Array {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var results = [T]()
        results.reserveCapacity(count)

        for element in self {
            try await results.append(transform(element))
        }

        return results
    }
}
