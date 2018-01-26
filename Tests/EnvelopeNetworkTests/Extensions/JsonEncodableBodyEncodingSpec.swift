//
//  JsonEncodableBodyEncodingSpec.swift
//  EnvelopeNetwork-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Quick
import Nimble
@testable import EnvelopeNetwork
import Alamofire

private struct JsonBody: Codable {
    let a: Double
}
extension JsonBody: Equatable {}
private func ==(lhs: JsonBody, rhs: JsonBody) -> Bool {
    return lhs.a == rhs.a
}

class JsonEncodableBodyEncodingSpec: TestSpec {
    override func spec() {
        describe("JsonEncodableBodyEncoding") {
            let request = try! URLRequest(url: "https://host.server.org", method: .post)
            let queryParameters: [String: Any] = ["uploadId": UUID().uuidString, "userId": UUID().uuidString]

            let mockContentType = "application/json; charset=utf8"
            let mockError = SampleError()

            describe("encode()") {

                context("object can be encoded") {
                    let mockJsonObject = JsonBody(a: 1)
                    var sut: JsonEncodableBodyEncoding<JsonBody>!
                    var resultingRequest: URLRequest?
                    beforeEach {
                        sut = JsonEncodableBodyEncoding(
                            jsonObject: mockJsonObject,
                            contentType: mockContentType,
                            defaultParametersEncoding: URLEncoding.queryString,
                            mapEncodingError: { _ in
                                fail("mapEncodingError() not expected to be called")
                                return mockError
                        })
                        resultingRequest = try! sut.encode(request, with: queryParameters)
                    }
                    it("httpBody is set") {
                        expect(resultingRequest?.httpBody).toNot(beNil())
                        if let data = resultingRequest?.httpBody {
                            let decodedObject = try! JSONDecoder().decode(JsonBody.self, from: data)
                            expect(decodedObject) == mockJsonObject
                        }
                    }
                    it("contentType is set") {
                        expect(resultingRequest?.value(forHTTPHeaderField: "Content-Type")) == mockContentType
                    }
                    it("url query parameters are set") {
                        let url: URL = (resultingRequest?.url!)!
                        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
                        expect(urlComponents.queryItems).to(allPass { (queryParameters[$0!.name]! as! String) == $0!.value })
                    }
                } // context("object can be encoded")
                context("encoding throws an error") {
                    let mockJsonObject = JsonBody(a: Double.signalingNaN)
                    var sut: JsonEncodableBodyEncoding<JsonBody>!
                    beforeEach {
                        sut = JsonEncodableBodyEncoding(
                            jsonObject: mockJsonObject,
                            contentType: mockContentType,
                            defaultParametersEncoding: URLEncoding.queryString,
                            mapEncodingError: { _ in mockError })
                    }
                    it("throws error") {
                        expect { try sut.encode(request, with: queryParameters) }.to(throwError { error in
                            expect(error) === mockError
                        })
                    }
                } // context("encoding throws an error")
            } // describe("encode()")
        } // describe("JsonEncodableBodyEncoding")
    } // spec()
}
