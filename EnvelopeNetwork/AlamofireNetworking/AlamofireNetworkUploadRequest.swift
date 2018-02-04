//
//  AlamofireNetworkUploadRequest.swift
//  Envelope-ios
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire

public final class AlamofireNetworkUploadRequest: AlamofireNetworkRequest, NetworkUploadRequesting {

    private let alamofireUploadRequest: UploadRequest

    public init(alamofireUploadRequest: UploadRequest) {
        self.alamofireUploadRequest = alamofireUploadRequest
        super.init(alamofireRequest: alamofireUploadRequest)
    }

    // MARK: - NetworkUploadRequesting
    @discardableResult
    public func uploadProgress(
        queue: DispatchQueue,
        closure: @escaping Request.ProgressHandler)
        -> Self {

        alamofireUploadRequest.uploadProgress(queue: queue, closure: closure)

        return self
    }
}
