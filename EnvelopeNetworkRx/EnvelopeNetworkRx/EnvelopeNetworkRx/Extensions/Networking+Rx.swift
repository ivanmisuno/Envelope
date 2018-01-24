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

// MARK: - NetworkRequesting rx extensions
public class RxNetworkRequest: NetworkRequesting {

    private let networkRequest: NetworkRequesting

    fileprivate init(_ networkRequest: NetworkRequesting) {
        self.networkRequest = networkRequest
    }

    // MARK: - NetworkRequesting
    public final var request: URLRequest? { return networkRequest.request }
    public final var response: HTTPURLResponse? { return networkRequest.response }

    public final func cancel() {
        networkRequest.cancel()
    }

    @discardableResult
    public final func progress(
        queue: DispatchQueue,
        progressHandler: @escaping Request.ProgressHandler)
        -> Self {

            networkRequest.progress(queue: queue, progressHandler: progressHandler)
            return self
    }

    @discardableResult
    public final func response<T: DataResponseSerializerProtocol>(
        queue: DispatchQueue,
        responseSerializer: T,
        completionHandler: @escaping (DataResponse<T.SerializedObject>) -> Void)
        -> Self {

            networkRequest.response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
            return self
    }

    @discardableResult
    public final func validate(validation: @escaping DataRequest.Validation)
        -> Self {

            networkRequest.validate(validation: validation)
            return self
    }

}

// ReactiveCompatible
public extension NetworkRequesting {

    /// Reactive extensions.
    public static var rx: Reactive<RxNetworkRequest>.Type {
        get {
            return Reactive<RxNetworkRequest>.self
        }
        set {
            // this enables using Reactive to "mutate" base type
        }
    }

    /// Reactive extensions.
    public var rx: Reactive<RxNetworkRequest> {
        get {
            return Reactive(RxNetworkRequest(self))
        }
        set {
            // this enables using Reactive to "mutate" base object
        }
    }
}

public extension Reactive where Base: NetworkRequesting {

    func progress(
        queue: DispatchQueue = DispatchQueue.main)
        -> RxSwift.Observable<RxProgress> {

            return RxSwift.Observable.create { observer in
                self.base.progress(queue: queue) { (progress: Progress) in
                    let rxProgress = RxProgress(bytesWritten: progress.completedUnitCount,
                                                totalBytes: progress.totalUnitCount)
                    observer.on(.next(rxProgress))
                    if rxProgress.isCompleted {
                        observer.on(.completed)
                    }
                }
                return Disposables.create()
                }.startWith(RxProgress(bytesWritten: 0, totalBytes: 0))
    }

    // MARK: - Serialized responses
    func response(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<DataResponse<Void>> {

            return Single.create { observer in
                let request = self.base.response { (dataResponse: DataResponse<Void>) in
                    observer(dataResponse.toSingleEvent())
                }
                return Disposables.create {
                    request.cancel()
                }
            }
    }

    func void(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<Void> {

            return response(queue: queue).map { _ in }
    }

    func responseData(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<DataResponse<Data>> {

            return Single.create { observer in
                let request = self.base.responseData { (dataResponse: DataResponse<Data>) in
                    observer(dataResponse.toSingleEvent())
                }
                return Disposables.create {
                    request.cancel()
                }
            }
    }

    func data(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<Data> {

            return responseData(queue: queue).flatMap { $0.result.toSingle() }
    }

    func responseJSON(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<DataResponse<Any>> {

            return Single.create { observer in
                let request = self.base.responseJSON { (dataResponse: DataResponse<Any>) in
                    observer(dataResponse.toSingleEvent())
                }
                return Disposables.create {
                    request.cancel()
                }
            }
    }

    func json(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<Any> {

            return responseJSON(queue: queue).flatMap { $0.result.toSingle() }
    }

    func responseObject<T: Decodable>(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<DataResponse<T>> {

            return Single.create { observer in
                let request = self.base.responseObject { (dataResponse: DataResponse<T>) in
                    observer(dataResponse.toSingleEvent())
                }
                return Disposables.create {
                    request.cancel()
                }
            }
    }

    func object<T: Decodable>(
        queue: DispatchQueue = DispatchQueue.main)
        -> Single<T> {

            return responseObject(queue: queue).flatMap { $0.result.toSingle() }
    }

}

// MARK: - NetworkUploadRequesting rx extensions
public final class RxNetworkUploadRequest: RxNetworkRequest, NetworkUploadRequesting {

    private let uploadRequest: NetworkUploadRequesting

    fileprivate init(_ uploadRequest: NetworkUploadRequesting) {
        self.uploadRequest = uploadRequest
        super.init(uploadRequest)
    }

    // MARK: - NetworkUploadRequesting
    @discardableResult
    public func uploadProgress(
        queue: DispatchQueue,
        closure: @escaping Request.ProgressHandler)
        -> Self {

            uploadRequest.uploadProgress(queue: queue, closure: closure)
            return self
    }

}

// ReactiveCompatible
public extension NetworkUploadRequesting {

    /// Reactive extensions.
    public static var rx: Reactive<RxNetworkUploadRequest>.Type {
        get {
            return Reactive<RxNetworkUploadRequest>.self
        }
        set {
            // this enables using Reactive to "mutate" base type
        }
    }

    /// Reactive extensions.
    public var rx: Reactive<RxNetworkUploadRequest> {
        get {
            return Reactive(RxNetworkUploadRequest(self))
        }
        set {
            // this enables using Reactive to "mutate" base object
        }
    }
}

public extension Reactive where Base: NetworkUploadRequesting {
    func uploadProgress(
        queue: DispatchQueue = DispatchQueue.main)
        -> RxSwift.Observable<RxProgress> {

            return RxSwift.Observable.create { observer in
                self.base.uploadProgress(queue: queue) { (progress: Progress) in
                    let rxProgress = RxProgress(bytesWritten: progress.completedUnitCount,
                                                totalBytes: progress.totalUnitCount)
                    observer.on(.next(rxProgress))
                    if rxProgress.isCompleted {
                        observer.on(.completed)
                    }
                }
                return Disposables.create()
                }.startWith(RxProgress(bytesWritten: 0, totalBytes: 0))
    }
}
