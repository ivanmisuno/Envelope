//
//  AlamofireNetworkRequest.swift
//  Envelope-ios
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire

// Cannot make it `final`, AlamofireNetworkUploadRequest inherits from it.
public class AlamofireNetworkRequest: NetworkRequesting {

    private let alamofireRequest: DataRequest

    public init(alamofireRequest: DataRequest) {
        self.alamofireRequest = alamofireRequest
    }

    // MARK: - NetworkRequesting
    public final var request: URLRequest? { return alamofireRequest.request }
    public final var response: HTTPURLResponse? { return alamofireRequest.response }

    public final func cancel() {
        alamofireRequest.cancel()
    }

    @discardableResult
    public final func progress(
        queue: DispatchQueue,
        progressHandler: @escaping Request.ProgressHandler)
        -> Self {

        alamofireRequest.downloadProgress(queue: queue, closure: progressHandler)

        return self
    }

    @discardableResult
    public final func response<T: DataResponseSerializerProtocol>(
        queue: DispatchQueue,
        responseSerializer: T,
        completionHandler: @escaping (DataResponse<T.SerializedObject>) -> Void)
        -> Self {

        alamofireRequest
            .response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
            .validate()

        return self
    }

    @discardableResult
    public final func validate(validation: @escaping DataRequest.Validation)
        -> Self {

        alamofireRequest.validate(validation)

        return self
    }
}
