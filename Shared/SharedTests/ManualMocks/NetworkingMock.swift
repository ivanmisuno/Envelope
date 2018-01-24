//
//  NetworkingMock.swift
//  EnvelopeNetwork-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

@testable import EnvelopeNetwork
import Alamofire

class NetworkingMock: Networking {

    // MARK: - Networking
    func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?)
        -> NetworkRequesting {

            requestCallCount += 1
            if let requestHandler = requestHandler {
                return requestHandler(url, method, parameters, encoding, headers)
            }
            preconditionFailure("Expected requestHandler to be set!")
    }
    var requestCallCount: Int = 0
    var requestHandler: ((_ url: URLConvertible,
        _ method: HTTPMethod,
        _ parameters: Parameters?,
        _ encoding: ParameterEncoding,
        _ headers: HTTPHeaders?) -> NetworkRequesting)? = nil

    func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?)
        -> NetworkUploadRequesting {

            uploadCallCount += 1
            if let uploadHandler = uploadHandler {
                return uploadHandler(data, url, method, headers)
            }
            preconditionFailure("Expected uploadHandler to be set!")
    }
    var uploadCallCount: Int = 0
    var uploadHandler: ((_ data: Data,
        _ url: URLConvertible,
        _ method: HTTPMethod,
        _ headers: HTTPHeaders?) -> NetworkUploadRequesting)? = nil

}
