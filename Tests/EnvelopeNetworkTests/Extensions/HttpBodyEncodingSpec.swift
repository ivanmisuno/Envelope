//
//  HttpBodyEncodingSpec.swift
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

class HttpBodyEncodingSpec: TestSpec {
    override func spec() {
        describe("HttpBodyEncoding") {
            let mockData = UUID().uuidString.data(using: .utf8)!
            let contentType = "application/binary"
            var sut: HttpBodyEncoding!
            beforeEach {
                sut = HttpBodyEncoding(httpBody: mockData, contentType: contentType, defaultParametersEncoding: URLEncoding.queryString)
            }
            describe("encode()") {
                let request = try! URLRequest(url: "https://host.server.org", method: .post)
                let queryParameters: [String: Any] = ["uploadId": UUID().uuidString, "userId": UUID().uuidString]
                var resultingRequest: URLRequest?
                beforeEach {
                    resultingRequest = try! sut.encode(request, with: queryParameters)
                }
                it("httpBody is set") {
                    expect(resultingRequest?.httpBody) == mockData
                }
                it("contentType is set") {
                    expect(resultingRequest?.value(forHTTPHeaderField: "Content-Type")) == contentType
                }
                it("url query parameters are set") {
                    let url: URL = (resultingRequest?.url!)!
                    let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
                    expect(urlComponents.queryItems).to(allPass { (queryParameters[$0!.name]! as! String) == $0!.value })
                }
            } // describe("encode()")
        } // describe("HttpBodyEncoding")
    }
}
