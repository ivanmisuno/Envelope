//
//  JsonEncodableBodyEncoding.swift
//  Envelope-ios
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire

public final class JsonEncodableBodyEncoding<T: Encodable>: ParameterEncoding {

    public let jsonObject: T
    public let contentType: String
    public let defaultParametersEncoding: ParameterEncoding
    public let mapEncodingError: ((Error) -> Error)?

    public init(jsonObject: T,
         contentType: String = "application/json",
         defaultParametersEncoding: ParameterEncoding = URLEncoding.methodDependent,
         mapEncodingError: ((Error) -> Error)? = nil) {

        self.jsonObject = jsonObject
        self.contentType = contentType
        self.defaultParametersEncoding = defaultParametersEncoding
        self.mapEncodingError = mapEncodingError
    }

    // MARK: - ParameterEncoding
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        if let parameters = parameters {
            urlRequest = try defaultParametersEncoding.encode(urlRequest, with: parameters)
        }

        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        do {
            let httpBody = try JSONEncoder().encode(jsonObject)
            urlRequest.httpBody = httpBody
        } catch let error {
            throw mapEncodingError?(error) ?? error
        }

        return urlRequest
    }
}
