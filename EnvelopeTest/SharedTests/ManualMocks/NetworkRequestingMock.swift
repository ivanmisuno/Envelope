//
//  NetworkRequestingMock.swift
//  EnvelopeNetwork-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

@testable import EnvelopeNetwork
import Alamofire

public class NetworkRequestingMock<T: DataResponseSerializerProtocol>: NetworkRequesting {

    public init() {
    }

    // MARK: - NetworkRequesting
    public var request: URLRequest?
    public var response: HTTPURLResponse?

    public func cancel() {
        cancelCallCount += 1
        cancelHandler?()
    }
    public var cancelCallCount: Int = 0
    public var cancelHandler: (() -> ())? = nil

    @discardableResult
    public func progress(
        queue: DispatchQueue,
        progressHandler: @escaping Request.ProgressHandler)
        -> Self {

            progressCallCount += 1
            self.progressHandler?(queue, progressHandler)
            return self
    }
    public var progressCallCount: Int = 0
    public var progressHandler: ((_ queue: DispatchQueue, _ progressHandler: @escaping Request.ProgressHandler) -> ())? = nil

    @discardableResult
    public func response<U: DataResponseSerializerProtocol>(
        queue: DispatchQueue,
        responseSerializer: U,
        completionHandler: @escaping (DataResponse<U.SerializedObject>) -> Void)
        -> Self {

            responseCallCount += 1

            if let responseHandler = responseHandler {
                guard let responseSerializer = responseSerializer as? T else {
                    let sourceLocation: String
                    if let responseHandlerContextLocation = responseHandlerContextLocation {
                        sourceLocation = "\n\tat \(responseHandlerContextLocation.file):\(responseHandlerContextLocation.line)"
                    } else {
                        sourceLocation = ""
                    }
                    preconditionFailure("⛔️ Expected responseSerializer of type `\(U.self)`\n\tprovided `\(T.self)`\(sourceLocation).\n\tFailure here likely means that the mocked response's type does not match that of the actual response callback closure.")
                }

                responseHandler(queue, responseSerializer) { (dataResponse: DataResponse<T.SerializedObject>) in
                    completionHandler(dataResponse as! DataResponse<U.SerializedObject>)
                }
            }

            return self
    }
    public var responseCallCount: Int = 0
    public var responseHandler: ((_ queue: DispatchQueue, _ responseSerializer: T, _ completionHandler: (DataResponse<T.SerializedObject>) -> ()) -> ())? = nil
    public var responseHandlerContextLocation: (file: StaticString, line: UInt)? = nil

    @discardableResult
    public func validate(validation: @escaping DataRequest.Validation)
        -> Self {

            validateCallCount += 1
            validateHandler?(validation)
            return self
    }
    public var validateCallCount: Int = 0
    public var validateHandler: ((_ validation: @escaping DataRequest.Validation) -> ())? = nil

}

fileprivate func executeValidations(_ validations: [DataRequest.Validation],
                                    request: URLRequest?,
                                    response: HTTPURLResponse,
                                    data: Data?) -> Error? {
    var validationError: Error?
    for validation in validations {
        if validationError == nil,
            case let .failure(error) = validation(request, response, data) {
            validationError = error
        }
    }
    return validationError
}

extension NetworkingMock {

    public func mockResponse<T: Decodable>(
        _ mockResult: Result<T>,
        mockData: Data? = nil,
        resultStatusCode: Int = 200,
        resultHttpHeaders: [String: String]? = nil,
        validateRequest: ((_ url: URLConvertible, _ method: HTTPMethod, _ parameters: Parameters?, _ encoding: ParameterEncoding, _ headers: HTTPHeaders?) -> ())? = nil,
        file: StaticString = #file,
        line: UInt = #line
        ) {

        requestHandler = { (url: URLConvertible,
            method: HTTPMethod,
            parameters: Parameters?,
            encoding: ParameterEncoding,
            headers: HTTPHeaders?) -> NetworkRequesting in

            typealias SerializerType = CodableSerializer<T>
            let request = NetworkRequestingMock<SerializerType>()

            var validations = [DataRequest.Validation]()
            request.validateHandler = { (validation: @escaping DataRequest.Validation) -> () in
                validations.append(validation)
            }

            request.responseHandlerContextLocation = (file: file, line: line)
            request.responseHandler = { (_ queue: DispatchQueue, _ responseSerializer: SerializerType, _ completionHandler: (DataResponse<SerializerType.SerializedObject>) -> ()) in

                let url = try! url.asURL()
                let urlRequest = URLRequest(url: url)
                let httpResponse = HTTPURLResponse(url: url, statusCode: resultStatusCode, httpVersion: "HTTP/1.1", headerFields: resultHttpHeaders)!

                let result: Result<T>
                switch mockResult {
                case .failure:
                    result = mockResult
                case .success:
                    if let validationError = executeValidations(validations, request: urlRequest, response: httpResponse, data: mockData) {
                        result = .failure(validationError)
                    } else {
                        result = mockResult
                    }
                }

                let dataResponse = DataResponse<SerializerType.SerializedObject>(request: urlRequest, response: httpResponse, data: mockData, result: result, timeline: Timeline())
                completionHandler(dataResponse)

                request.responseHandler = nil
                request.responseHandlerContextLocation = nil
            }

            validateRequest?(url, method, parameters, encoding, headers)

            return request
        }
    }

    public func mockResponse<T>(
        _ mockResult: Result<T>,
        mockData: Data? = nil,
        resultStatusCode: Int = 200,
        resultHttpHeaders: [String: String]? = nil,
        validateRequest: ((_ url: URLConvertible, _ method: HTTPMethod, _ parameters: Parameters?, _ encoding: ParameterEncoding, _ headers: HTTPHeaders?) -> ())? = nil,
        file: StaticString = #file,
        line: UInt = #line
        ) {

        requestHandler = { (url: URLConvertible,
            method: HTTPMethod,
            parameters: Parameters?,
            encoding: ParameterEncoding,
            headers: HTTPHeaders?) -> NetworkRequesting in

            typealias SerializerType = DataResponseSerializer<T>
            let request = NetworkRequestingMock<SerializerType>()

            var validations = [DataRequest.Validation]()
            request.validateHandler = { (validation: @escaping DataRequest.Validation) -> () in
                validations.append(validation)
            }

            request.responseHandlerContextLocation = (file: file, line: line)
            request.responseHandler = { (_ queue: DispatchQueue, _ responseSerializer: SerializerType, _ completionHandler: (DataResponse<SerializerType.SerializedObject>) -> ()) in

                let url = try! url.asURL()
                let urlRequest = URLRequest(url: url)
                let httpResponse = HTTPURLResponse(url: url, statusCode: resultStatusCode, httpVersion: "HTTP/1.1", headerFields: resultHttpHeaders)!

                let result: Result<T>
                switch mockResult {
                case .failure:
                    result = mockResult
                case .success:
                    if let validationError = executeValidations(validations, request: urlRequest, response: httpResponse, data: mockData) {
                        result = .failure(validationError)
                    } else {
                        result = mockResult
                    }
                }

                let dataResponse = DataResponse<SerializerType.SerializedObject>(request: urlRequest, response: httpResponse, data: mockData, result: result, timeline: Timeline())
                completionHandler(dataResponse)

                request.responseHandler = nil
                request.responseHandlerContextLocation = nil
            }

            validateRequest?(url, method, parameters, encoding, headers)

            return request
        }
    }

    public func mockUpload<T>(
        _ mockResult: Result<T>,
        mockData: Data? = nil,
        resultStatusCode: Int = 200,
        resultHttpHeaders: [String: String]? = nil,
        validateRequest: ((_ data: Data, _ url: URLConvertible, _ method: HTTPMethod, _ headers: HTTPHeaders?) -> ())? = nil,
        file: StaticString = #file,
        line: UInt = #line
        ) {

        uploadHandler = { (data: Data,
            url: URLConvertible,
            method: HTTPMethod,
            headers: HTTPHeaders?) -> NetworkUploadRequesting in

            typealias SerializerType = DataResponseSerializer<T>
            let request = NetworkUploadRequestingMock<SerializerType>()

            var validations = [DataRequest.Validation]()
            request.validateHandler = { (validation: @escaping DataRequest.Validation) -> () in
                validations.append(validation)
            }

            request.responseHandlerContextLocation = (file: file, line: line)
            request.responseHandler = { (_ queue: DispatchQueue, _ responseSerializer: SerializerType, _ completionHandler: (DataResponse<SerializerType.SerializedObject>) -> ()) in

                let url = try! url.asURL()
                let urlRequest = URLRequest(url: url)
                let httpResponse = HTTPURLResponse(url: url, statusCode: resultStatusCode, httpVersion: "HTTP/1.1", headerFields: resultHttpHeaders)!

                let result: Result<T>
                switch mockResult {
                case .failure:
                    result = mockResult
                case .success:
                    if let validationError = executeValidations(validations, request: urlRequest, response: httpResponse, data: mockData) {
                        result = .failure(validationError)
                    } else {
                        result = mockResult
                    }
                }

                let dataResponse = DataResponse<SerializerType.SerializedObject>(request: urlRequest, response: httpResponse, data: mockData, result: result, timeline: Timeline())
                completionHandler(dataResponse)

                request.responseHandler = nil
                request.responseHandlerContextLocation = nil
            }

            validateRequest?(data, url, method, headers)

            return request
        }
    }
}
