//
//  AlamofireNetworkSpec.swift
//  EnvelopeNetwork-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Quick
import Nimble
@testable import EnvelopeNetwork
import Alamofire

class AlamofireNetworkSpec: TestSpec {
    override func spec() {
        describe("AlamofireNetwork") {
            var sut: AlamofireNetwork!
            beforeEach {
                sut = AlamofireNetwork(alamofireSessionManager: SessionManager.default)
            }

            describe("request()") {

                context("valid URL") {
                    var request: NetworkRequesting!
                    beforeEach {
                        request = sut.request("http://eu.httpbin.org/get", method: .get)
                    }
                    it("not nil") {
                        expect(request).toNot(beNil())
                    }
                    describe(".request") {
                        it("not nil") {
                            expect(request.request).toNot(beNil())
                        }
                    } // describe(".request")
                    describe("response()") {
                        var responseError: Error? = nil
                        var responseValue: Data? = nil
                        beforeEach {
                            waitUntil(timeout: 5) { done in
                                request.response(responseSerializer: DataRequest.dataResponseSerializer()) { (response: DataResponse<Data>) in
                                    responseError = response.error
                                    responseValue = response.value
                                    done()
                                }
                            }
                        }
                        it("error is nil") {
                            expect(responseError).to(beNil())
                        }
                        it("value is not empty") {
                            expect(responseValue).toNot(beNil())
                            expect(responseValue).toNot(beEmpty())
                        }
                        describe(".response") {
                            it("not nil") {
                                expect(request.response).toNot(beNil())
                            }
                        } // describe(".response")
                    } // describe("response()")
                    describe("progress()") {
                        var progressCalledTimes: Int = 0
                        var completedUnitCount: Int64 = 0
                        beforeEach {
                            progressCalledTimes = 0
                            completedUnitCount = 0
                            request.progress { (progress: Progress) in
                                progressCalledTimes += 1
                                expect(progress.totalUnitCount) >= 1
                                expect(progress.completedUnitCount) <= progress.totalUnitCount
                                completedUnitCount = progress.completedUnitCount
                            }
                            waitUntil(timeout: 5) { done in
                                request.response(responseSerializer: DataRequest.dataResponseSerializer()) { _ in
                                    done()
                                }
                            }
                        }
                        it("progress handler is called") {
                            expect(progressCalledTimes) >= 1
                        }
                        it("completedUnitCount reports progress") {
                            expect(completedUnitCount) >= 1
                        }
                    } // describe("progress()")
                    describe("validate()") {
                        context("validation succeedes") {
                            var validateCalled: Bool = false
                            beforeEach {
                                validateCalled = false
                                request.validate(validation: { (request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult in
                                    expect(response.statusCode) == 200
                                    expect(data).toNot(beNil())
                                    expect(data).toNot(beEmpty())
                                    validateCalled = true
                                    return .success
                                })
                            }
                            it("validate() is being called, response is success") {
                                waitUntil(timeout: 5) { done in
                                    request.response(responseSerializer: DataRequest.dataResponseSerializer(), completionHandler: { (response: DataResponse<Data>) in
                                        expect(response.error).to(beNil())
                                        done()
                                    })
                                }
                                expect(validateCalled) == true
                            }
                        } // context("validation succeedes")
                        context("validation fails") {
                            beforeEach {
                                request.validate(validation: { (request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult in
                                    return .failure(SampleError())
                                })
                            }
                            it("response is failure") {
                                waitUntil(timeout: 5) { done in
                                    request.response(responseSerializer: DataRequest.dataResponseSerializer(), completionHandler: { (response: DataResponse<Data>) in
                                        expect(response.error).toNot(beNil())
                                        done()
                                    })
                                }
                            }
                        } // context("validation fails")
                    } // describe("validate()")
                } // context("valid URL")
                context("invalid URL (404)") {
                    var request: NetworkRequesting!
                    beforeEach {
                        request = sut.request("http://eu.httpbin.org/status/404", method: .get)
                    }
                    describe("response()") {
                        it("returns error") {
                            let serializer = DataRequest.dataResponseSerializer()
                            waitUntil(timeout: 5) { done in
                                request.response(responseSerializer: serializer, completionHandler: { (response: DataResponse<Data>) in
                                    expect(response.error).toNot(beNil())
                                    expect(response.value).to(beNil())
                                    done()
                                })
                            }
                        }
                    } // describe("response()")
                    describe("response()") {
                        it("returns error") {
                            waitUntil(timeout: 5) { done in
                                request.response { (response: DataResponse<Void>) in
                                    expect(response.error).toNot(beNil())
                                    expect(response.value).to(beNil())
                                    done()
                                }
                            }
                        }
                    } // describe("response()")
                    describe("responseObject()") {
                        var response: DataResponse<HttpBinResponse>?
                        beforeEach {
                            waitUntil(timeout: 5) { done in
                                request.responseObject { (response_: DataResponse<HttpBinResponse>) in
                                    response = response_
                                    done()
                                }
                            }
                        }
                        it("result is error") {
                            expect(response).toNot(beNil())
                            expect(response?.result).to(beFailure())
                            expect(response?.result.error).toNot(beNil())
                            expect(response?.result.value).to(beNil())
                        }

                    } // describe("responseObject()")
                } // context("invalid URL (404)")
            } // describe("request()")
            describe("upload()") {
                let mockData = UUID().uuidString.data(using: .utf8)!
                var request: NetworkUploadRequesting!
                beforeEach {
                    request = sut.upload(mockData, to: "http://eu.httpbin.org/anything", method: .put, headers: ["Content-Type": "application/octet-stream"])
                }
                it("not nil") {
                    expect(request).toNot(beNil())
                }

                describe("uploadProgress()") {
                    var uploadProgressCallTimes: Int = 0
                    beforeEach {
                        uploadProgressCallTimes = 0
                        request.uploadProgress { (progress: Progress) in
                            uploadProgressCallTimes += 1
                        }
                        waitUntil(timeout: 5) { done in
                            request.response(responseSerializer: DataRequest.dataResponseSerializer()) { (response: DataResponse<Data>) in
                                expect(response.error).to(beNil())
                                expect(response.data).toNot(beNil())
                                expect(response.data).toNot(beEmpty())
                                done()
                            }
                        }
                    }
                    it("is called") {
                        expect(uploadProgressCallTimes) >= 1
                    }
                } // describe("uploadProgress()")

            } // describe("upload()")
        } // describe("AlamofireNetwork")
    } // spec()
}
