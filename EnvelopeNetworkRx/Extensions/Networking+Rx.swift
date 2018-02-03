//
//  Networking+Rx.swift
//  EnvelopeNetworkRx-ios
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import EnvelopeNetwork
import Alamofire
import RxSwift

public extension Result {

    struct MappingError: Error {
        let value: Any
    }

    static func defaultMapping<T>(_ value: Any) -> Result<T> {
        guard let mappedValue = value as? T else {
            return .failure(MappingError(value: value))
        }
        return .success(mappedValue)
    }

    func toSingle() -> Single<Value> {
        switch self {
        case .success(let value):
            return Single.just(value)
        case .failure(let error):
            return Single.error(error)
        }
    }
    func toAnyValue() -> Result<Any> {
        return map { $0 }
    }
    func map<T>(_ convert: ((Any) -> Result<T>) = Result.defaultMapping) -> Result<T> {
        switch self {
        case .success(let value):
            return convert(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}

public final class RxNetworkError: Error {
    private let dataResponse: DataResponse<Any>
    init<T>(_ dataResponse: DataResponse<T>) {
        self.dataResponse = DataResponse(
            request: dataResponse.request,
            response: dataResponse.response,
            data: dataResponse.data,
            result: dataResponse.result.toAnyValue(),
            timeline: dataResponse.timeline)
    }
    func toDataResponse<T>(_ convert: ((Any) -> Result<T>) = Result<T>.defaultMapping) -> DataResponse<T> {
        return DataResponse(
            request: dataResponse.request,
            response: dataResponse.response,
            data: dataResponse.data,
            result: dataResponse.result.map(convert),
            timeline: dataResponse.timeline)
    }
}

extension RxNetworkError: LocalizedError {
    public var errorDescription: String? {
        return "RxNetworkError: status \(dataResponse.response?.statusCode ?? -1) - \(String(data: dataResponse.data ?? Data(), encoding: .utf8) ?? "")"
    }
}

public extension DataResponse {
    func toSingleEvent() -> SingleEvent<DataResponse<Value>> {
        switch result {
        case .success:
            return .success(self)
        case .failure:
            return .error(RxNetworkError(self))
        }
    }
}

// MARK: - Networking rx extensions
public protocol RxNetworking {
    func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?)
        -> RxNetworkRequesting

    func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?)
        -> RxNetworkUploadRequesting
}

public final class RxNetwork: RxNetworking {

    private let network: Networking

    init(_ network: Networking) {
        self.network = network
    }

    // MARK: - RxNetworking
    public func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?)
        -> RxNetworkRequesting {

        return RxNetworkRequest {
            return self.network.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        }
    }

    public func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?)
        -> RxNetworkUploadRequesting {

        return RxNetworkUploadRequest {
            return self.network.upload(data, to: url, method: method, headers: headers)
        }
    }

}

// : ReactiveCompatible
extension Networking {

    /// Reactive extensions.
    public static var rx: Reactive<RxNetwork>.Type {
        get {
            return Reactive<RxNetwork>.self
        }
        set {
            // this enables using Reactive to "mutate" base type
        }
    }

    /// Reactive extensions.
    public var rx: Reactive<RxNetwork> {
        get {
            return Reactive(RxNetwork(self))
        }
        set {
            // this enables using Reactive to "mutate" base object
        }
    }
}

public extension Reactive where Base: RxNetworking {

    // MARK: - main interface
    /// `rx.request()`
    public func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> RxNetworkRequesting {

            return base.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }

    /// `rx.upload()`
    public func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod = .put,
        headers: HTTPHeaders? = nil)
        -> RxNetworkUploadRequesting {

            return base.upload(data, to: url, method: method, headers: headers)
    }

}

public extension Reactive where Base: RxNetworking {

    // MARK: - helper extensions
    public func get(
        _ url: URLConvertible,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.methodDependent,
        headers: HTTPHeaders? = nil)
        -> RxNetworkRequesting {

        return request(url, method: .get, parameters: parameters, encoding: encoding, headers: headers)
    }

    public func post(
        _ url: URLConvertible,
        httpBody: Data,
        contentType: String = "application/octet-stream",
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.methodDependent,
        headers: HTTPHeaders? = nil)
        -> RxNetworkRequesting {

        return request(url, method: .post, parameters: parameters, encoding: HttpBodyEncoding(httpBody: httpBody, contentType: contentType, defaultParametersEncoding: encoding), headers: headers)
    }

    public func post<T: Encodable>(
        _ url: URLConvertible,
        jsonObject: T,
        contentType: String = "application/json",
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.methodDependent,
        headers: HTTPHeaders? = nil,
        mapEncodingError: ((Error) -> Error)? = nil)
        -> RxNetworkRequesting {

        return request(url, method: .post, parameters: parameters, encoding: JsonEncodableBodyEncoding(jsonObject: jsonObject, contentType: contentType, defaultParametersEncoding: encoding, mapEncodingError: mapEncodingError), headers: headers)
    }

    public func put(
        _ url: URLConvertible,
        httpBody: Data,
        contentType: String = "application/octet-stream",
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.methodDependent,
        headers: HTTPHeaders? = nil)
        -> RxNetworkRequesting {

        return request(url, method: .put, parameters: parameters, encoding: HttpBodyEncoding(httpBody: httpBody, contentType: contentType, defaultParametersEncoding: encoding), headers: headers)
    }

}

// MARK: - NetworkRequesting rx extensions
public protocol RxNetworkRequesting {

    @discardableResult
    func progress(
        queue: DispatchQueue,
        progressHandler: @escaping Request.ProgressHandler)
        -> Self

    @discardableResult
    func validate(validation: @escaping DataRequest.Validation)
        -> Self

    func response<T: DataResponseSerializerProtocol>(
        queue: DispatchQueue,
        responseSerializer: T)
        -> Single<DataResponse<T.SerializedObject>>
}

public extension RxNetworkRequesting {

    // MARK: Default arguments
    @discardableResult
    func progress(
        progressHandler: @escaping Request.ProgressHandler)
        -> Self {

        return progress(queue: DispatchQueue.main, progressHandler: progressHandler)
    }
}

public extension RxNetworkRequesting {

    // MARK: - Response serialization
    func response(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<DataResponse<Void>> {

        let serializer = DataResponseSerializer<Void> { (request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<Void> in
            if let error = error {
                return .failure(error)
            }

            return .success(Void())
        }
        return response(queue: queue, responseSerializer: serializer)
    }

    func void(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<Void> {

        return response(queue: queue).map { _ in }
    }

    func responseData(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<DataResponse<Data>> {

        return response(queue: queue, responseSerializer: DataRequest.dataResponseSerializer())
    }

    func data(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<Data> {

        return responseData(queue: queue).flatMap { $0.result.toSingle() }
    }

    func responseJSON(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<DataResponse<Any>> {

        return response(queue: queue, responseSerializer: DataRequest.jsonResponseSerializer())
    }

    func json(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<Any> {

        return responseJSON(queue: queue).flatMap { $0.result.toSingle() }
    }

    func responseObject<T: Decodable>(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<DataResponse<T>> {

        return response(queue: queue, responseSerializer: CodableSerializer<T>())
    }

    func object<T: Decodable>(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<T> {

        return responseObject(queue: queue).flatMap { $0.result.toSingle() }
    }

}

class RxNetworkRequest: RxNetworkRequesting {

    private let networkRequestFactory: () -> NetworkRequesting
    private var progressHandlers: [(queue: DispatchQueue, progressHandler: Request.ProgressHandler)] = []
    private var validations: [DataRequest.Validation] = []

    init(_ networkRequestFactory: @escaping () -> NetworkRequesting) {
        self.networkRequestFactory = networkRequestFactory
    }

    // MARK: - NetworkRequesting
    @discardableResult
    func progress(
        queue: DispatchQueue,
        progressHandler: @escaping Request.ProgressHandler)
        -> Self {

        progressHandlers.append((queue: queue, progressHandler: progressHandler))

        return self
    }

    @discardableResult
    func validate(validation: @escaping DataRequest.Validation)
        -> Self {

        validations.append(validation)

        return self
    }

    func response<T: DataResponseSerializerProtocol>(
        queue: DispatchQueue,
        responseSerializer: T)
        -> Single<DataResponse<T.SerializedObject>> {

            return Single.create { (observer: @escaping (SingleEvent<DataResponse<T.SerializedObject>>) -> ()) -> Disposable in

                let networkRequest = self.networkRequestFactory()
                self.requestCreated(networkRequest)

                networkRequest.response(queue: queue, responseSerializer: responseSerializer) { (response: DataResponse<T.SerializedObject>) in
                    observer(response.toSingleEvent())
                }

                return Disposables.create {
                    networkRequest.cancel()
                }
            }
    }

    // MARK: - Internal
    final func requestCreated(_ request: NetworkRequesting) {

        // install progress handlers and validations
        progressHandlers.forEach { (arg) in
            request.progress(queue: arg.queue, progressHandler: arg.progressHandler)
        }

        validations.forEach { (validation) in
            request.validate(validation: validation)
        }

        // pass to derived classes
        onRequestCreated(request)
    }

    /// Override point
    open func onRequestCreated(_ request: NetworkRequesting) {
    }

}

// MARK: - NetworkUploadRequesting rx extensions
public protocol RxNetworkUploadRequesting: RxNetworkRequesting {

    @discardableResult
    func uploadProgress(
        queue: DispatchQueue,
        closure: @escaping Request.ProgressHandler)
        -> Self
}

public extension RxNetworkUploadRequesting {

    // MARK: - Default arguments
    @discardableResult
    func uploadProgress(
        closure: @escaping Request.ProgressHandler)
        -> Self {

        return uploadProgress(queue: DispatchQueue.main, closure: closure)
    }
}

final class RxNetworkUploadRequest: RxNetworkRequest, RxNetworkUploadRequesting {

    private let uploadRequestFactory: () -> NetworkUploadRequesting
    private var uploadProgressHandlers: [(queue: DispatchQueue, closure: Request.ProgressHandler)] = []

    init(_ uploadRequestFactory: @escaping () -> NetworkUploadRequesting) {
        self.uploadRequestFactory = uploadRequestFactory
        super.init(uploadRequestFactory)
    }

    // MARK: - NetworkUploadRequesting
    @discardableResult
    func uploadProgress(
        queue: DispatchQueue,
        closure: @escaping Request.ProgressHandler)
        -> Self {

        uploadProgressHandlers.append((queue: queue, closure: closure))

        return self
    }

    // MARK: - Internal
    override func onRequestCreated(_ request: NetworkRequesting) {
        guard let uploadRequest = request as? NetworkUploadRequesting else {
            return
        }

        uploadProgressHandlers.forEach { (arg) in
            let (queue, closure) = arg
            uploadRequest.uploadProgress(queue: queue, closure: closure)
        }
    }
}
