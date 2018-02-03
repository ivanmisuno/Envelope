//
//  SampleError.swift
//  Envelope
//
//  Created by Ivan Misuno on 26-01-2018.
//

import Foundation

public final class SampleError: Error {
    public init() {
    }
}

extension SampleError: LocalizedError {
    public var errorDescription: String? {
        return "Sample error"
    }
}
