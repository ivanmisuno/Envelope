//
//  NetworkUploadRequestingMock.swift
//  EnvelopeNetwork-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

@testable import EnvelopeNetwork
import Alamofire

public class NetworkUploadRequestingMock<T: DataResponseSerializerProtocol>: NetworkRequestingMock<T>, NetworkUploadRequesting {

    // MARK: - NetworkUploadRequesting
    @discardableResult
    public func uploadProgress(
        queue: DispatchQueue,
        closure: @escaping Request.ProgressHandler)
        -> Self {

            uploadProgressCallCount += 1
            self.uploadProgressHandler?(queue, closure)
            return self
    }
    public var uploadProgressCallCount: Int = 0
    public var uploadProgressHandler: ((_ queue: DispatchQueue, _ closure: @escaping Request.ProgressHandler) -> ())? = nil
}
