//
//  ResponseSerializationSpec.swift
//  EnvelopeNetwork-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire
import Quick
import Nimble
@testable import EnvelopeNetwork
import EnvelopeTest

class ResponseSerializationSpec: TestSpec {
    override func spec() {
        describe("response serialization") {

            let mockUrl = URL(string: "http://httpbin.org/get")!

            context("valid request") {
                let rawHttpBinGetResponse = HttpBinResponse.rawHttpBinGetResponse

                describe("DefaultDataResponse") {
                    context("no error") {
                        var request: NetworkRequestingMock<DataResponseSerializer<Void>>!
                        var response: DataResponse<Void>?
                        beforeEach {
                            request = NetworkRequestingMock()
                            request.responseHandler = { (queue: DispatchQueue, responseSerializer: DataResponseSerializer<Void>, completionHandler: (DataResponse<Void>) -> ()) -> () in
                                let urlRequest = URLRequest(url: mockUrl)
                                let urlResponse = HTTPURLResponse()
                                let result = responseSerializer.serializeResponse(urlRequest, urlResponse, rawHttpBinGetResponse, nil)
                                let dataResponse = DataResponse<Void>(request: urlRequest, response: urlResponse, data: rawHttpBinGetResponse, result: result, timeline: Timeline())
                                completionHandler(dataResponse)
                            }

                            request.response { (response_: DataResponse<Void>) in
                                response = response_
                            }
                        }
                        it("valid response") {
                            expect(response).toNot(beNil())
                            expect(response?.error).to(beNil())
                            expect(response?.data).toNot(beNil())
                            expect(response?.data).toNot(beEmpty())
                            expect(response?.result).to(beSuccess())
                        }
                    } // context("no error")
                    context("error") {
                        let mockError = SampleError()
                        var request: NetworkRequestingMock<DataResponseSerializer<Void>>!
                        var response: DataResponse<Void>?
                        beforeEach {
                            request = NetworkRequestingMock()
                            request.responseHandler = { (queue: DispatchQueue, responseSerializer: DataResponseSerializer<Void>, completionHandler: (DataResponse<Void>) -> ()) -> () in
                                let urlRequest = URLRequest(url: mockUrl)
                                let urlResponse = HTTPURLResponse()
                                let result = responseSerializer.serializeResponse(urlRequest, urlResponse, rawHttpBinGetResponse, mockError)
                                let dataResponse = DataResponse<Void>(request: urlRequest, response: urlResponse, data: rawHttpBinGetResponse, result: result, timeline: Timeline())
                                completionHandler(dataResponse)
                            }

                            request.response { (response_: DataResponse<Void>) in
                                response = response_
                            }
                        }
                        it("error") {
                            expect(response).toNot(beNil())
                            expect(response?.error).toNot(beNil())
                            expect(response?.result).to(beFailure())
                        }
                    } // context("error")
                } // describe("DefaultDataResponse")
                describe("responseData()") {
                    var request: NetworkRequestingMock<DataResponseSerializer<Data>>!
                    var response: DataResponse<Data>?
                    beforeEach {
                        request = NetworkRequestingMock()
                        request.responseHandler = { (queue: DispatchQueue, responseSerializer: DataResponseSerializer<Data>, completionHandler: (DataResponse<Data>) -> ()) -> () in
                            let dataResponse = DataResponse<Data>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.success(rawHttpBinGetResponse), timeline: Timeline())
                            completionHandler(dataResponse)
                        }

                        request.responseData { (response_: DataResponse<Data>) in
                            response = response_
                        }
                    }
                    it("valid result") {
                        expect(response).toNot(beNil())
                        expect(response?.result).to(beSuccess())
                        expect(response?.result.error).to(beNil())
                        expect(response?.result.value).toNot(beNil())
                        expect(response?.result.value).toNot(beEmpty())
                    }
                } // describe("responseData()")
                describe("responseJSON()") {
                    let json = try! JSONSerialization.jsonObject(with: rawHttpBinGetResponse, options: [])
                    var request: NetworkRequestingMock<DataResponseSerializer<Any>>!
                    var response: DataResponse<Any>?
                    beforeEach {
                        request = NetworkRequestingMock()
                        request.responseHandler = { (queue: DispatchQueue, responseSerializer: DataResponseSerializer<Any>, completionHandler: (DataResponse<Any>) -> ()) -> () in
                            let dataResponse = DataResponse<Any>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.success(json), timeline: Timeline())
                            completionHandler(dataResponse)
                        }

                        request.responseJSON { (response_: DataResponse<Any>) in
                            response = response_
                        }
                    }
                    it("valid result") {
                        expect(response).toNot(beNil())
                        expect(response?.result).to(beSuccess())
                        expect(response?.result.error).to(beNil())
                        expect(response?.result.value).toNot(beNil())
                        guard let json = response?.result.value as? [String: Any] else {
                            fail("Expected a [String: Any]")
                            return
                        }
                        expect(json).toNot(beEmpty())
                        expect(json["url"]! as? String) == "http://httpbin.org/get"
                    }
                } // describe("responseJSON()")
                describe("responseObject()") {
                    context("valid response type") {
                        let responseObject: HttpBinResponse = try! JSONDecoder().decode(HttpBinResponse.self, from: rawHttpBinGetResponse)
                        var request: NetworkRequestingMock<CodableSerializer<HttpBinResponse>>!
                        var response: DataResponse<HttpBinResponse>?
                        beforeEach {
                            request = NetworkRequestingMock()
                            request.responseHandler = { (queue: DispatchQueue, responseSerializer: CodableSerializer<HttpBinResponse>, completionHandler: (DataResponse<HttpBinResponse>) -> ()) -> () in
                                let dataResponse = DataResponse<HttpBinResponse>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.success(responseObject), timeline: Timeline())
                                completionHandler(dataResponse)
                            }

                            request.responseObject { (response_: DataResponse<HttpBinResponse>) in
                                response = response_
                            }
                        }
                        it("valid result") {
                            expect(response).toNot(beNil())
                            expect(response?.result).to(beSuccess())
                            expect(response?.result.error).to(beNil())
                            expect(response?.result.value).toNot(beNil())
                            expect(response?.result.value?.url) == "http://httpbin.org/get"
                            expect(response?.result.value?.origin).toNot(beEmpty())
                            expect(response?.result.value?.headers).toNot(beEmpty())
                            expect(response?.result.value?.args).to(beEmpty())
                        }
                    } // context("valid response type")
                    context("response could not be deserialized") {
                        var request: NetworkRequestingMock<CodableSerializer<UnknownResponse>>!
                        var response: DataResponse<UnknownResponse>?
                        beforeEach {
                            request = NetworkRequestingMock()
                            request.responseHandler = { (queue: DispatchQueue, responseSerializer: CodableSerializer<UnknownResponse>, completionHandler: (DataResponse<UnknownResponse>) -> ()) -> () in
                                let dataResponse = DataResponse<UnknownResponse>(request: nil, response: nil, data: rawHttpBinGetResponse, result: Result.failure(SampleError()), timeline: Timeline())
                                completionHandler(dataResponse)
                            }

                            request.responseObject { (response_: DataResponse<UnknownResponse>) in
                                response = response_
                            }
                        }
                        it("result is error") {
                            expect(response).toNot(beNil())
                            expect(response?.result).to(beFailure())
                            expect(response?.result.error).toNot(beNil())
                            expect(response?.result.value).to(beNil())
                        }
                    } // context("response could not be deserialized")
                } // describe("responseObject()")
            } // context("valid request")
        } // describe("response serialization")
    }
}
