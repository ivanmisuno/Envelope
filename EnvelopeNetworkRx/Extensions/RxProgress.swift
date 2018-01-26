//
//  RxProgress.swift
//  EnvelopeNetworkRx-ios
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

// MARK: RxProgress (thanks https://github.com/RxSwiftCommunity/RxAlamofire/)
public struct RxProgress {
    public let bytesWritten: Int64
    public let totalBytes: Int64

    public init(bytesWritten: Int64, totalBytes: Int64) {
        self.bytesWritten = bytesWritten
        self.totalBytes = totalBytes
    }
}

public extension RxProgress {
    public var bytesRemaining: Int64 {
        return totalBytes - bytesWritten
    }

    public var isCompleted: Bool {
        return bytesWritten >= totalBytes
    }

    public var ratioCompleted: Float {
        if totalBytes > 0 {
            return Float(bytesWritten) / Float(totalBytes)
        }
        else {
            return 0
        }
    }
}

extension RxProgress: Equatable {}

public func ==(lhs: RxProgress, rhs: RxProgress) -> Bool {
    return lhs.bytesWritten == rhs.bytesWritten &&
        lhs.totalBytes == rhs.totalBytes
}
