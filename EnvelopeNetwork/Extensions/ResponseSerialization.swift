//
//  ResponseSerialization.swift
//  Envelope-ios
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire

public extension NetworkRequesting {

    @discardableResult
    func response(
        queue: DispatchQueue = DispatchQueue.main,
        completionHandler: @escaping (DataResponse<Void>) -> Void) -> Self {

        let serializer = DataResponseSerializer<Void> { (request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<Void> in
            if let error = error {
                return .failure(error)
            }

            return .success(Void())
        }
        return response(queue: queue, responseSerializer: serializer) { (dataResponse: DataResponse<Void>) in
            completionHandler(dataResponse)
        }
    }
}

public extension NetworkRequesting {

    @discardableResult
    func responseData(
        queue: DispatchQueue = DispatchQueue.main,
        completionHandler: @escaping (DataResponse<Data>) -> Void) -> Self {

        return response(queue: queue, responseSerializer: DataRequest.dataResponseSerializer()) { (dataResponse: DataResponse<Data>) in
            completionHandler(dataResponse)
        }
    }
}

public extension NetworkRequesting {

    @discardableResult
    func responseJSON(
        queue: DispatchQueue = DispatchQueue.main,
        completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self {

        return response(queue: queue, responseSerializer: DataRequest.jsonResponseSerializer()) { (dataResponse: DataResponse<Any>) in
            completionHandler(dataResponse)
        }
    }
}

public extension NetworkRequesting {

    @discardableResult
    func responseObject<T: Decodable>(
        queue: DispatchQueue = DispatchQueue.main,
        completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {

        return response(queue: queue, responseSerializer: CodableSerializer<T>()) { (dataResponse: DataResponse<T>) in
            completionHandler(dataResponse)
        }
    }
}
