//
//  AlamofireNetwork.swift
//  Envelope-ios
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire

public final class AlamofireNetwork: Networking {

    private let alamofireSessionManager: SessionManager

    public init(alamofireSessionManager: SessionManager) {
        self.alamofireSessionManager = alamofireSessionManager
    }

    // MARK: - Networking
    public func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?)
        -> NetworkRequesting {

            let alamofireRequest = alamofireSessionManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
            return AlamofireNetworkRequest(alamofireRequest: alamofireRequest)
    }

    public func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?)
        -> NetworkUploadRequesting {

            let alamofireUploadRequest = alamofireSessionManager.upload(data, to: url, method: method, headers: headers)
            return AlamofireNetworkUploadRequest(alamofireUploadRequest: alamofireUploadRequest)
    }
}
