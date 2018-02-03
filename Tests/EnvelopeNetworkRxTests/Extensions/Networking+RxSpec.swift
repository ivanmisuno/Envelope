//
//  Networking+RxSpec.swift
//  EnvelopeNetworkRx-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire
import RxSwift
import Quick
import Nimble
@testable import EnvelopeNetwork
@testable import EnvelopeNetworkRx
import EnvelopeTest

class NetworkingRxSpec: TestSpec {
    override func spec() {
        describe("Networking+Rx") {

            describe(".rx extension") {
                var network: NetworkingMock!
                beforeEach {
                    network = NetworkingMock()
                }
                describe(".rx") {
                    var rx: Reactive<RxNetwork>!
                    beforeEach {
                        rx = network.rx
                    }
                    it("not nil") {
                        expect(rx).toNot(beNil())
                    }

                    let mockUrl = URL(string: "http://a.b")!

                    describe("rx.request()") {
                        beforeEach {
                            network.mockResponse(Result<Void>.success(Void()))

                            rx.request(mockUrl, method: .get).void().subscribe { event in
                                expect(event).to(beSuccess())
                                }.disposed(afterEach: self)
                        }
                        it("calls network.request") {
                            expect(network.requestCallCount) == 1
                        }
                    } // describe("rx.request()")
                    describe("rx.upload()") {
                        let mockData = "a".data(using: .utf8)!
                        beforeEach {
                            network.mockUpload(Result<Void>.success(Void()))

                            rx.upload(mockData, to: mockUrl).void().subscribe { event in
                                expect(event).to(beSuccess())
                                }.disposed(afterEach: self)
                        }
                        it("calls network.upload") {
                            expect(network.uploadCallCount) == 1
                        }
                    } // describe("rx.upload()")
                } // describe(".rx")
            } // describe(".rx extension")
            describe("serialization") {
                context("valid request") {
                    let rawHttpBinGetResponse = HttpBinResponse.rawHttpBinGetResponse

                    describe("response()") {
                        context("Result.success") {
                            var rxRequest: RxNetworkRequest!
                            var observedEvent: SingleEvent<DataResponse<Void>>?
                            beforeEach {
                                rxRequest = RxNetworkRequest {
                                    let request = NetworkRequestingMock<DataResponseSerializer<Void>>()
                                    request.responseHandler = { (queue: DispatchQueue, responseSerializer: DataResponseSerializer<Void>, completionHandler: (DataResponse<Void>) -> ()) -> () in
                                        let dataResponse = DataResponse<Void>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.success(Void()), timeline: Timeline())
                                        completionHandler(dataResponse)
                                    }
                                    return request
                                }

                                rxRequest
                                    .response()
                                    .subscribe { (event: SingleEvent<DataResponse<Void>>) in
                                        observedEvent = event
                                    }
                                    .disposed(afterEach: self)
                            }
                            it("succeeds") {
                                expect(observedEvent).to(beSuccess())
                            }
                        } // context("Result.success")
                        context("Result.failure") {
                            var rxRequest: RxNetworkRequest!
                            var observedEvent: SingleEvent<Void>?
                            beforeEach {
                                rxRequest = RxNetworkRequest {
                                    let request = NetworkRequestingMock<DataResponseSerializer<Void>>()
                                    request.responseHandler = { (queue: DispatchQueue, responseSerializer: DataResponseSerializer<Void>, completionHandler: (DataResponse<Void>) -> ()) -> () in
                                        let dataResponse = DataResponse<Void>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result<Void>.failure(SampleError()), timeline: Timeline())
                                        completionHandler(dataResponse)
                                    }
                                    return request
                                }

                                rxRequest
                                    .response()
                                    .flatMap { (dataResponse: DataResponse<Void>) -> Single<Void> in
                                        fail("Response is .failure, not expected to get here!")
                                        return Single.just(Void())
                                    }
                                    .subscribe { (event: SingleEvent<Void>) in
                                        observedEvent = event
                                    }
                                    .disposed(afterEach: self)
                            }
                            it("succeeds") {
                                expect(observedEvent).to(beFailure())
                            }
                        } // context("Result.failure")
                    } // describe("response()")
                    describe("responseData()") {
                        var rxRequest: RxNetworkRequest!
                        var observedEvent: SingleEvent<Data>?
                        beforeEach {
                            rxRequest = RxNetworkRequest {
                                let request = NetworkRequestingMock<DataResponseSerializer<Data>>()
                                request.responseHandler = { (queue: DispatchQueue, responseSerializer: DataResponseSerializer<Data>, completionHandler: (DataResponse<Data>) -> ()) -> () in
                                    let dataResponse = DataResponse<Data>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.success(rawHttpBinGetResponse), timeline: Timeline())
                                    completionHandler(dataResponse)
                                }
                                return request
                            }

                            rxRequest
                                .data()
                                .subscribe { (event: SingleEvent<Data>) in
                                    observedEvent = event
                                }
                                .disposed(afterEach: self)
                        }
                        it("succeeds") {
                            expect(observedEvent).to(beSuccess())
                            expect(observedEvent?.value).toNot(beEmpty())
                        }
                    } // describe("responseData()")
                    describe("responseJSON()") {
                        let json = try! JSONSerialization.jsonObject(with: rawHttpBinGetResponse, options: [])
                        var rxRequest: RxNetworkRequest!
                        var observedEvent: SingleEvent<Any>?
                        beforeEach {
                            rxRequest = RxNetworkRequest {
                                let request = NetworkRequestingMock<DataResponseSerializer<Any>>()
                                request.responseHandler = { (queue: DispatchQueue, responseSerializer: DataResponseSerializer<Any>, completionHandler: (DataResponse<Any>) -> ()) -> () in
                                    let dataResponse = DataResponse<Any>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.success(json), timeline: Timeline())
                                    completionHandler(dataResponse)
                                }
                                return request
                            }

                            rxRequest
                                .json()
                                .subscribe { (event: SingleEvent<Any>) in
                                    observedEvent = event
                                }
                                .disposed(afterEach: self)
                        }
                        it("succeeds") {
                            expect(observedEvent).to(beSuccess())
                            expect(observedEvent?.value as? [String: Any]).toNot(beEmpty())
                        }
                    } // describe("responseJSON()")
                    describe("responseObject()") {
                        context("valid response type") {
                            let responseObject: HttpBinResponse = try! JSONDecoder().decode(HttpBinResponse.self, from: rawHttpBinGetResponse)
                            var rxRequest: RxNetworkRequest!
                            var observedEvent: SingleEvent<HttpBinResponse>?
                            beforeEach {
                                rxRequest = RxNetworkRequest {
                                    let request = NetworkRequestingMock<CodableSerializer<HttpBinResponse>>()
                                    request.responseHandler = { (queue: DispatchQueue, responseSerializer: CodableSerializer<HttpBinResponse>, completionHandler: (DataResponse<HttpBinResponse>) -> ()) -> () in
                                        let dataResponse = DataResponse<HttpBinResponse>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.success(responseObject), timeline: Timeline())
                                        completionHandler(dataResponse)
                                    }
                                    return request
                                }

                                rxRequest
                                    .object()
                                    .subscribe { (event: SingleEvent<HttpBinResponse>) in
                                        observedEvent = event
                                    }
                                    .disposed(afterEach: self)
                            }
                            it("succeeds") {
                                expect(observedEvent).to(beSuccess())
                                expect(observedEvent?.value?.url) == "http://httpbin.org/get"
                                expect(observedEvent?.value?.origin).toNot(beEmpty())
                                expect(observedEvent?.value?.headers).toNot(beEmpty())
                                expect(observedEvent?.value?.args).to(beEmpty())
                            }
                        } // context("valid response type")
                        context("response could not be deserialized") {
                            var rxRequest: RxNetworkRequest!
                            var observedEvent: SingleEvent<UnknownResponse>?
                            beforeEach {
                                rxRequest = RxNetworkRequest {
                                    let request = NetworkRequestingMock<CodableSerializer<UnknownResponse>>()
                                    request.responseHandler = { (queue: DispatchQueue, responseSerializer: CodableSerializer<UnknownResponse>, completionHandler: (DataResponse<UnknownResponse>) -> ()) -> () in
                                        let dataResponse = DataResponse<UnknownResponse>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.failure(SampleError()), timeline: Timeline())
                                        completionHandler(dataResponse)
                                    }
                                    return request
                                }

                                rxRequest
                                    .object()
                                    .subscribe { (event: SingleEvent<UnknownResponse>) in
                                        observedEvent = event
                                    }
                                    .disposed(afterEach: self)
                            }
                            it("returns error") {
                                expect(observedEvent).to(beFailure())
                                expect(observedEvent?.error).to(beAKindOf(RxNetworkError.self))
                                if let error = observedEvent?.error as? RxNetworkError {
                                    let dataResponse: DataResponse<UnknownResponse> = error.toDataResponse()
                                    expect(dataResponse.data).toNot(beNil())
                                }
                            }
                        } // context("response could not be deserialized")
                    } // describe("responseObject()")
                } // context("valid request")
            } // describe("serialization")
        } // describe("Networking+Rx")
    }
}
