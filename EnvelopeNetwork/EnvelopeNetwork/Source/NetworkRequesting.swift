//
//  NetworkRequesting.swift
//  Envelope-ios
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire

protocol NetworkRequesting {
    var request: URLRequest? { get }
    var response: HTTPURLResponse? { get }

    func cancel()

    @discardableResult
    func progress(
        queue: DispatchQueue,
        progressHandler: @escaping Request.ProgressHandler)
        -> Self

    @discardableResult
    func response<T: DataResponseSerializerProtocol>(
        queue: DispatchQueue,
        responseSerializer: T,
        completionHandler: @escaping (DataResponse<T.SerializedObject>) -> Void)
        -> Self

    @discardableResult
    func validate(validation: @escaping DataRequest.Validation)
        -> Self
}

extension NetworkRequesting {

    @discardableResult
    func progress(
        progressHandler: @escaping Request.ProgressHandler)
        -> Self {
            return progress(queue: DispatchQueue.main, progressHandler: progressHandler)
    }

    @discardableResult
    func response<T: DataResponseSerializerProtocol>(
        responseSerializer: T,
        completionHandler: @escaping (DataResponse<T.SerializedObject>) -> Void)
        -> Self {
            return response(queue: DispatchQueue.main, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}
