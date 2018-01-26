//
//  JsonEncodableBodyEncoding.swift
//  Envelope-ios
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire

final class JsonEncodableBodyEncoding<T: Encodable>: ParameterEncoding {

    let jsonObject: T
    let contentType: String
    let defaultParametersEncoding: ParameterEncoding
    let mapEncodingError: ((Error) -> Error)?

    init(jsonObject: T,
         contentType: String = "application/json",
         defaultParametersEncoding: ParameterEncoding = URLEncoding.methodDependent,
         mapEncodingError: ((Error) -> Error)? = nil) {

        self.jsonObject = jsonObject
        self.contentType = contentType
        self.defaultParametersEncoding = defaultParametersEncoding
        self.mapEncodingError = mapEncodingError
    }

    // MARK: - ParameterEncoding
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
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
