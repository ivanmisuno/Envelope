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
            context("valid request") {
                let rawHttpBinGetResponse = HttpBinResponse.rawHttpBinGetResponse

                describe("response()") {
                    context("Result.success") {
                        var request: NetworkRequestingMock<DataResponseSerializer<Void>>!
                        var observedEvent: SingleEvent<DataResponse<Void>>?
                        beforeEach {
                            request = NetworkRequestingMock()
                            request.responseHandler = { (queue: DispatchQueue, responseSerializer: DataResponseSerializer<Void>, completionHandler: (DataResponse<Void>) -> ()) -> () in
                                let dataResponse = DataResponse<Void>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.success(Void()), timeline: Timeline())
                                completionHandler(dataResponse)
                            }

                            request
                                .rx.response()
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
                        var request: NetworkRequestingMock<DataResponseSerializer<Void>>!
                        var observedEvent: SingleEvent<Void>?
                        beforeEach {
                            request = NetworkRequestingMock()
                            request.responseHandler = { (queue: DispatchQueue, responseSerializer: DataResponseSerializer<Void>, completionHandler: (DataResponse<Void>) -> ()) -> () in
                                let dataResponse = DataResponse<Void>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result<Void>.failure(SampleError()), timeline: Timeline())
                                completionHandler(dataResponse)
                            }

                            request
                                .rx.response()
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
                    var request: NetworkRequestingMock<DataResponseSerializer<Data>>!
                    var observedEvent: SingleEvent<Data>?
                    beforeEach {
                        request = NetworkRequestingMock()
                        request.responseHandler = { (queue: DispatchQueue, responseSerializer: DataResponseSerializer<Data>, completionHandler: (DataResponse<Data>) -> ()) -> () in
                            let dataResponse = DataResponse<Data>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.success(rawHttpBinGetResponse), timeline: Timeline())
                            completionHandler(dataResponse)
                        }

                        request
                            .rx.data()
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
                    var request: NetworkRequestingMock<DataResponseSerializer<Any>>!
                    var observedEvent: SingleEvent<Any>?
                    beforeEach {
                        request = NetworkRequestingMock()
                        request.responseHandler = { (queue: DispatchQueue, responseSerializer: DataResponseSerializer<Any>, completionHandler: (DataResponse<Any>) -> ()) -> () in
                            let dataResponse = DataResponse<Any>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.success(json), timeline: Timeline())
                            completionHandler(dataResponse)
                        }


                        request
                            .rx.json()
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
                        var request: NetworkRequestingMock<CodableSerializer<HttpBinResponse>>!
                        var observedEvent: SingleEvent<HttpBinResponse>?
                        beforeEach {
                            request = NetworkRequestingMock()
                            request.responseHandler = { (queue: DispatchQueue, responseSerializer: CodableSerializer<HttpBinResponse>, completionHandler: (DataResponse<HttpBinResponse>) -> ()) -> () in
                                let dataResponse = DataResponse<HttpBinResponse>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.success(responseObject), timeline: Timeline())
                                completionHandler(dataResponse)
                            }

                            request
                                .rx.object()
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
                        var request: NetworkRequestingMock<CodableSerializer<UnknownResponse>>!
                        var observedEvent: SingleEvent<UnknownResponse>?
                        beforeEach {
                            request = NetworkRequestingMock()
                            request.responseHandler = { (queue: DispatchQueue, responseSerializer: CodableSerializer<UnknownResponse>, completionHandler: (DataResponse<UnknownResponse>) -> ()) -> () in
                                let dataResponse = DataResponse<UnknownResponse>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.failure(SampleError()), timeline: Timeline())
                                completionHandler(dataResponse)
                            }

                            request
                                .rx.object()
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
        } // describe("Networking+Rx")
    }
}
