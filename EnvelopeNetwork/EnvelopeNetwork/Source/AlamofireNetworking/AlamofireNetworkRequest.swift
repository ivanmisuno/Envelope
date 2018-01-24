//
//  AlamofireNetworkRequest.swift
//  Envelope-ios
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire

class AlamofireNetworkRequest: NetworkRequesting {

    private let alamofireRequest: DataRequest

    init(alamofireRequest: DataRequest) {
        self.alamofireRequest = alamofireRequest
    }

    // MARK: - NetworkRequesting
    var request: URLRequest? { return alamofireRequest.request }
    var response: HTTPURLResponse? { return alamofireRequest.response }

    func cancel() {
        alamofireRequest.cancel()
    }

    @discardableResult
    func progress(
        queue: DispatchQueue,
        progressHandler: @escaping Request.ProgressHandler)
        -> Self {

            alamofireRequest.downloadProgress(queue: queue, closure: progressHandler)

            return self
    }

    @discardableResult
    func response<T: DataResponseSerializerProtocol>(
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
    func validate(validation: @escaping DataRequest.Validation)
        -> Self {

            alamofireRequest.validate(validation)

            return self
    }
}
