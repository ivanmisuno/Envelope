//
//  CodableSerializerSpec.swift
//  EnvelopeNetwork-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Quick
import Nimble
@testable import EnvelopeNetwork
import Alamofire

class CodableSerializerSpec: TestSpec {
    override func spec() {
        describe("CodableSerializer") {
            var sut: CodableSerializer<HttpBinResponse>!
            beforeEach {
                sut = CodableSerializer()
            }
            describe(".serializeResponse") {
                var serializer: ((URLRequest?, HTTPURLResponse?, Data?, Error?) -> Result<HttpBinResponse>)!
                beforeEach {
                    serializer = sut.serializeResponse
                }
                describe("serialization") {
                    var request: URLRequest?
                    var response: HTTPURLResponse?
                    var result: Result<HttpBinResponse>!

                    beforeEach {
                        request = URLRequest(url: URL(string: "http://host.org")!)
                        response = HTTPURLResponse()
                    }

                    context("expected data response") {
                        beforeEach {
                            result = serializer(request, response, HttpBinResponse.rawHttpBinGetResponse, nil)
                        }
                        it("success") {
                            expect(result).to(beSuccess())
                            expect(result.value).toNot(beNil())
                            expect(result.value?.url) == "http://httpbin.org/get"
                        }
                    } // context("expected data response")
                    context("unexpected data response") {
                        beforeEach {
                            result = serializer(request, response, "".data(using: .utf8), nil)
                        }
                        it("failure") {
                            expect(result).to(beFailure())
                        }
                    } // context("unexpected data response")
                    context("nil data response") {
                        beforeEach {
                            result = serializer(request, response, nil, nil)
                        }
                        it("failure") {
                            expect(result).to(beFailure())
                        }
                    } // context("nil data response")
                    context("error response") {
                        beforeEach {
                            result = serializer(request, response, HttpBinResponse.rawHttpBinGetResponse, AFError.responseValidationFailed(reason: AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: 500)))
                        }
                        it("failure") {
                            expect(result).to(beFailure())
                        }
                    } // context("error response")
                } // describe("serialization")
            } // describe(".serializeResponse")
        } // describe("CodableSerializer")
    }
}
