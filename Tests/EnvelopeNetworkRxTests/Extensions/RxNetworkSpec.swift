//
//  RxNetworkSpec.swift
//  AllTests-ios
//
//  Created by Ivan Misuno on 03-02-2018.
//

import Alamofire
import RxSwift
import Quick
import Nimble
@testable import EnvelopeNetwork
@testable import EnvelopeNetworkRx
import EnvelopeTest

class RxNetworkSpec: TestSpec {
    override func spec() {
        describe("RxNetwork") {
            var network: NetworkingMock!
            var sut: RxNetwork!
            beforeEach {
                network = NetworkingMock()
                sut = RxNetwork(network)
            }

            let mockUrl = URL(string: "http://a.com")!

            describe("request()") {
                var rxRequest: RxNetworkRequesting!
                var requestMock: NetworkRequestingMock<DataResponseSerializer<Void>>!
                beforeEach {
                    requestMock = NetworkRequestingMock()

                    network.requestHandler = { (url: URLConvertible,
                        method: HTTPMethod,
                        parameters: Parameters?,
                        encoding: ParameterEncoding,
                        headers: HTTPHeaders?) -> NetworkRequesting in

                        expect { try url.asURL() } == mockUrl
                        expect(method.rawValue) == HTTPMethod.get.rawValue
                        expect(parameters?["a"] as? String) == "b"
                        expect((encoding as? URLEncoding)?.destination) == URLEncoding.Destination.queryString
                        expect(headers?["a"]) == "b"

                        return requestMock
                    }

                    rxRequest = sut.request(mockUrl, method: .get, parameters: ["a": "b"], encoding: URLEncoding.queryString, headers: ["a": "b"])
                }
                it("does not call network.request() yet") {
                    expect(network.requestCallCount) == 0
                }
                context("progress block set") {
                    var progressHandlerCallCount: Int = 0
                    beforeEach {
                        progressHandlerCallCount = 0
                        rxRequest.progress { (Progress) -> Void in
                            progressHandlerCallCount += 1
                        }
                    }
                    it("does not call requestMock.progress() yet") {
                        expect(requestMock.progressCallCount) == 0
                    }

                    context("validation block set") {
                        var validationHandlerCallCount: Int = 0
                        beforeEach {
                            validationHandlerCallCount = 0
                            rxRequest.validate { (request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult in
                                validationHandlerCallCount += 1
                                return .success
                            }
                        }
                        it("does not call requestMock.validate() yet") {
                            expect(requestMock.validateCallCount) == 0
                        }

                        context("operation is requested") {
                            var operation: Single<DataResponse<Void>>!
                            beforeEach {
                                operation = rxRequest.response()
                            }
                            it("requestMock.response() is not called yet") {
                                expect(requestMock.responseCallCount) == 0
                            }

                            context("operation is subscribed to") {
                                var completionHandler: ((DataResponse<DataResponseSerializer<Void>.SerializedObject>) -> ())!
                                var observedEvent: SingleEvent<DataResponse<Void>>?
                                beforeEach {
                                    requestMock.validateHandler = { (validation: @escaping DataRequest.Validation) -> () in
                                        validationHandlerCallCount = 0
                                        _ = validation(nil, HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!, nil)
                                        expect(validationHandlerCallCount) == 1
                                    }
                                    requestMock.progressHandler = { (_ queue: DispatchQueue, _ progressHandler: @escaping Request.ProgressHandler) -> () in
                                        progressHandlerCallCount = 0
                                        progressHandler(Progress(totalUnitCount: 0))
                                        expect(progressHandlerCallCount) == 1
                                    }
                                    requestMock.responseHandler = { (_ queue: DispatchQueue, _ responseSerializer: DataResponseSerializer<Void>, _ completion: @escaping (DataResponse<Void>) -> ()) -> () in
                                        completionHandler = completion
                                    }

                                    operation
                                        .subscribe { (event: SingleEvent<DataResponse<Void>>) in
                                            observedEvent = event
                                        }
                                        .disposed(afterEach: self)
                                }
                                it("requestMock.validate() is called with the validation handler") {
                                    expect(requestMock.validateCallCount) == 1
                                }
                                it("requestMock.progress() is called with the progress handler") {
                                    expect(requestMock.progressCallCount) == 1
                                }
                                it("requestMock.response() is called") {
                                    expect(requestMock.responseCallCount) == 1
                                }

                                context("response is ready") {
                                    let mockDataResponse = DataResponse<Void>(request: nil,
                                                                              response: nil,
                                                                              data: nil,
                                                                              result: Result<Void>.success(Void()))
                                    beforeEach {
                                        completionHandler(mockDataResponse)
                                    }
                                    it("observed response") {
                                        expect(observedEvent).to(beSuccess())
                                    }
                                } // context("response is ready")
                            } // context("operation is subscribed to")
                        } // context("operation is requested")
                    } // context("validation block set")
                } // context("progress block set")
            } // describe("request()")
            describe("upload()") {
                let mockData = "a".data(using: .utf8)!
                var rxUploadRequest: RxNetworkUploadRequesting!
                var uploadRequestMock: NetworkUploadRequestingMock<DataResponseSerializer<Void>>!
                beforeEach {
                    uploadRequestMock = NetworkUploadRequestingMock()

                    network.uploadHandler = { (_ data: Data,
                        _ url: URLConvertible,
                        _ method: HTTPMethod,
                        _ headers: HTTPHeaders?) -> NetworkUploadRequesting in

                        expect(data) == mockData
                        expect { try url.asURL() } == mockUrl
                        expect(method.rawValue) == HTTPMethod.put.rawValue
                        expect(headers?["a"]) == "b"

                        return uploadRequestMock
                    }

                    rxUploadRequest = sut.upload(mockData, to: mockUrl, method: .put, headers: ["a": "b"])
                }
                it("does not call network.upload() yet") {
                    expect(network.uploadCallCount) == 0
                }
                context("uploadProgress block set") {
                    var uploadProgressHandlerCallCount: Int = 0
                    beforeEach {
                        uploadProgressHandlerCallCount = 0
                        rxUploadRequest.uploadProgress { (Progress) -> Void in
                            uploadProgressHandlerCallCount += 1
                        }
                    }
                    it("does not call uploadRequestMock.uploadProgress() yet") {
                        expect(uploadRequestMock.uploadProgressCallCount) == 0
                    }

                    context("operation is requested") {
                        var operation: Single<DataResponse<Void>>!
                        beforeEach {
                            operation = rxUploadRequest.response()
                        }
                        it("uploadRequestMock.response() is not called yet") {
                            expect(uploadRequestMock.responseCallCount) == 0
                        }

                        context("operation is subscribed to") {
                            var completionHandler: ((DataResponse<DataResponseSerializer<Void>.SerializedObject>) -> ())!
                            var observedEvent: SingleEvent<DataResponse<Void>>?
                            beforeEach {
                                uploadRequestMock.uploadProgressHandler = { (_ queue: DispatchQueue, _ progressHandler: @escaping Request.ProgressHandler) -> () in
                                    uploadProgressHandlerCallCount = 0
                                    progressHandler(Progress(totalUnitCount: 0))
                                    expect(uploadProgressHandlerCallCount) == 1
                                }
                                uploadRequestMock.responseHandler = { (_ queue: DispatchQueue, _ responseSerializer: DataResponseSerializer<Void>, _ completion: @escaping (DataResponse<Void>) -> ()) -> () in
                                    completionHandler = completion
                                }

                                operation
                                    .subscribe { (event: SingleEvent<DataResponse<Void>>) in
                                        observedEvent = event
                                    }
                                    .disposed(afterEach: self)
                            }
                            it("uploadRequestMock.uploadProgress() is called with the progress handler") {
                                expect(uploadRequestMock.uploadProgressCallCount) == 1
                            }
                            it("uploadRequestMock.response() is called") {
                                expect(uploadRequestMock.responseCallCount) == 1
                            }

                            context("response is ready") {
                                let mockDataResponse = DataResponse<Void>(request: nil,
                                                                          response: nil,
                                                                          data: nil,
                                                                          result: Result<Void>.success(Void()))
                                beforeEach {
                                    completionHandler(mockDataResponse)
                                }
                                it("observed response") {
                                    expect(observedEvent).to(beSuccess())
                                }
                            } // context("response is ready")
                        } // context("operation is subscribed to")
                    } // context("operation is requested")
                } // context("progress block set")
            } // describe("upload()")
        } // describe("RxNetwork")
    } // spec()
}
