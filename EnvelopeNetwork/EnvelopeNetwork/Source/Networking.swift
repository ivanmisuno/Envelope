//
//  Networking.swift
//  Envelope
//
//  Created by Ivan Misuno on 23-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire

/// A network abstraction layer protocol.
/// It follows Alamofire conventions and references Alamofire primitive types, which is fine, since we only want to abstract the functional layer.
protocol Networking {
    func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?)
        -> NetworkRequesting

    func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?)
        -> NetworkUploadRequesting
}

extension Networking {
    func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding)
        -> NetworkRequesting {

            return request(url, method: method, parameters: parameters, encoding: encoding, headers: nil)
    }

    func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?)
        -> NetworkRequesting {

            return request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil)
    }

    func request(
        _ url: URLConvertible,
        method: HTTPMethod)
        -> NetworkRequesting {

            return request(url, method: method, parameters: nil, encoding: URLEncoding.default, headers: nil)
    }

    func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod = .put)
        -> NetworkUploadRequesting {

            return upload(data, to: url, method: method, headers: nil)
    }

}

extension Networking {
    func post(
        _ url: URLConvertible,
        httpBody: Data,
        contentType: String = "application/octet-stream",
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.methodDependent,
        headers: HTTPHeaders? = nil)
        -> NetworkRequesting {

            return request(url, method: .post, parameters: parameters, encoding: HttpBodyEncoding(httpBody: httpBody, contentType: contentType, defaultParametersEncoding: encoding), headers: headers)
    }

    func post<T: Encodable>(
        _ url: URLConvertible,
        jsonObject: T,
        contentType: String = "application/json",
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.methodDependent,
        headers: HTTPHeaders? = nil,
        mapEncodingError: ((Error) -> Error)? = nil)
        -> NetworkRequesting {

            return request(url, method: .post, parameters: parameters, encoding: JsonEncodableBodyEncoding(jsonObject: jsonObject, contentType: contentType, defaultParametersEncoding: encoding, mapEncodingError: mapEncodingError), headers: headers)
    }

    func put(
        _ url: URLConvertible,
        httpBody: Data,
        contentType: String = "application/octet-stream",
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.methodDependent,
        headers: HTTPHeaders? = nil)
        -> NetworkRequesting {

            return request(url, method: .put, parameters: parameters, encoding: HttpBodyEncoding(httpBody: httpBody, contentType: contentType, defaultParametersEncoding: encoding), headers: headers)
    }
}
