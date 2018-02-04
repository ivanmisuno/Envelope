//
//  CodableSerializer.swift
//  EnvelopeNetwork-ios
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire

public final class CodableSerializer<T: Decodable>: DataResponseSerializerProtocol {

    public init() {
    }

    // MARK: - DataResponseSerializerProtocol
    public typealias SerializedObject = T

    public var serializeResponse: (URLRequest?, HTTPURLResponse?, Data?, Error?) -> Result<SerializedObject> {
        return { (request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<SerializedObject> in
            let result = Request.serializeResponseData(response: response, data: data, error: error)
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    return .success(decodedObject)
                } catch {
                    return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    }
}
