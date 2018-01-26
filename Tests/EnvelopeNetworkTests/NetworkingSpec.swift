//
//  NetworkingSpec.swift
//  EnvelopeNetwork-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Quick
import Nimble
@testable import EnvelopeNetwork
import Alamofire

private struct JsonBody: Encodable {
    let a: String = "b"
}
extension JsonBody: Equatable {}
private func ==(lhs: JsonBody, rhs: JsonBody) -> Bool {
    return lhs.a == rhs.a
}

class NetworkingSpec: TestSpec {
    override func spec() {
        describe("Networking (extensions)") {
            var sut: NetworkingMock!
            beforeEach {
                sut = NetworkingMock()
            }

            let url = URL(string: "http://sample.com")!
            let mockData = UUID().uuidString.data(using: .utf8)!

            describe("request() overloads") {
                beforeEach {
                    sut.requestHandler = { (url_: URLConvertible,
                        method: HTTPMethod,
                        parameters: Parameters?,
                        encoding: ParameterEncoding,
                        headers: HTTPHeaders?) -> NetworkRequesting in
                        expect { try url_.asURL() } == url
                        expect(method) == HTTPMethod.get
                        expect(parameters).to(beNil())
                        expect((encoding as? URLEncoding)?.destination) == URLEncoding.default.destination
                        expect(headers).to(beNil())
                        return NetworkRequestingMock<DataResponseSerializer<Void>>()
                    }
                }
                describe("request() no headers") {
                    beforeEach {
                        _ = sut.request(
                            url,
                            method: .get,
                            parameters: nil,
                            encoding: URLEncoding.default)
                    }
                    it("calls request()") {
                        expect(sut.requestCallCount) == 1
                    }
                }
                describe("no encoding") {
                    beforeEach {
                        _ = sut.request(
                            url,
                            method: .get,
                            parameters: nil)
                    }
                    it("calls request()") {
                        expect(sut.requestCallCount) == 1
                    }
                }
                describe("no parameters") {
                    beforeEach {
                        _ = sut.request(
                            url,
                            method: .get)
                    }
                    it("calls request()") {
                        expect(sut.requestCallCount) == 1
                    }
                }
            } // describe("request overloads")

            describe("upload() overloads") {
                beforeEach {
                    sut.uploadHandler = { (data: Data,
                        url_: URLConvertible,
                        _ method: HTTPMethod,
                        _ headers: HTTPHeaders?) -> NetworkUploadRequesting in
                        expect(data) == mockData
                        expect { try url_.asURL() } == url
                        expect(method) == HTTPMethod.put
                        expect(headers).to(beNil())
                        return NetworkUploadRequestingMock<DataResponseSerializer<Void>>()
                    }
                }
                describe("no headers") {
                    beforeEach {
                        _ = sut.upload(mockData, to: url, method: .put)
                    }
                    it("calls upload()") {
                        expect(sut.uploadCallCount) == 1
                    }
                }
            } // describe("upload() overloads")

            describe("post() overloads") {
                describe("post()") {
                    beforeEach {
                        sut.requestHandler = { (url_: URLConvertible,
                            method: HTTPMethod,
                            parameters: Parameters?,
                            encoding: ParameterEncoding,
                            headers: HTTPHeaders?) -> NetworkRequesting in
                            expect { try url_.asURL() } == url
                            expect(method) == HTTPMethod.post
                            expect(parameters?["a"] as? String) == "b"
                            expect(encoding).to(beAKindOf(HttpBodyEncoding.self))
                            if let encoding = encoding as? HttpBodyEncoding {
                                expect(encoding.httpBody) === mockData
                                expect(encoding.contentType) == "application/json"
                                expect(encoding.defaultParametersEncoding).to(beAKindOf(URLEncoding.self))
                                if let defaultParametersEncoding = encoding.defaultParametersEncoding as? URLEncoding {
                                    expect(defaultParametersEncoding.destination) == URLEncoding.Destination.queryString
                                }
                            }
                            expect(headers?["a"]) == "b"
                            return NetworkRequestingMock<DataResponseSerializer<Void>>()
                        }

                        _ = sut.post(url, httpBody: mockData, contentType: "application/json", parameters: ["a": "b"], encoding: URLEncoding.queryString, headers: ["a": "b"])
                    }
                    it("calls request()") {
                        expect(sut.requestCallCount) == 1
                    }
                }
                describe("post(jsonObject:)") {
                    beforeEach {
                        let jsonObject = JsonBody()

                        let mapEncodingError: (Error) -> Error = { $0 }

                        sut.requestHandler = { (url_: URLConvertible,
                            method: HTTPMethod,
                            parameters: Parameters?,
                            encoding: ParameterEncoding,
                            headers: HTTPHeaders?) -> NetworkRequesting in
                            expect { try url_.asURL() } == url
                            expect(method) == HTTPMethod.post
                            expect(parameters?["a"] as? String) == "b"
                            expect(encoding).to(beAKindOf(JsonEncodableBodyEncoding<JsonBody>.self))
                            if let encoding = encoding as? JsonEncodableBodyEncoding<JsonBody> {
                                expect(encoding.jsonObject) == jsonObject
                                expect(encoding.contentType) == "application/json"
                                expect(encoding.defaultParametersEncoding).to(beAKindOf(URLEncoding.self))
                                expect(encoding.mapEncodingError).toNot(beNil())
                            }
                            expect(headers?["a"]) == "b"
                            return NetworkRequestingMock<DataResponseSerializer<JsonBody>>()
                        }

                        _ = sut.post(url, jsonObject: jsonObject, contentType: "application/json", parameters: ["a": "b"], encoding: URLEncoding.queryString, headers: ["a": "b"], mapEncodingError: mapEncodingError)
                    }
                    it("calls request()") {
                        expect(sut.requestCallCount) == 1
                    }
                } // describe("post(jsonObject:)")
            } // describe("post() overloads")

            describe("put() overoloads") {
                beforeEach {
                    sut.requestHandler = { (url_: URLConvertible,
                        method: HTTPMethod,
                        parameters: Parameters?,
                        encoding: ParameterEncoding,
                        headers: HTTPHeaders?) -> NetworkRequesting in
                        expect(method) == HTTPMethod.put
                        expect(encoding).to(beAKindOf(HttpBodyEncoding.self))
                        return NetworkRequestingMock<DataResponseSerializer<Void>>()
                    }
                }
                describe("put()") {
                    beforeEach {
                        _ = sut.put(url, httpBody: mockData)
                    }
                    it("calls request()") {
                        expect(sut.requestCallCount) == 1
                    }
                }
            } // describe("put() overoloads")

            describe("response mocking") {
                describe("mockResponse<T: Decodable>()") {
                    let mockData = HttpBinResponse.rawHttpBinGetResponse
                    let mockObject = try! JSONDecoder().decode(HttpBinResponse.self, from: mockData)
                    context("success") {
                        var result: Result<HttpBinResponse>?
                        beforeEach {
                            sut.mockResponse(.success(mockObject), mockData: mockData, resultStatusCode: 200, resultHttpHeaders: ["a":"b"], validateRequest: { (url_: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?) in
                                expect { try! url_.asURL() } == url
                                expect(method.rawValue) == HTTPMethod.post.rawValue
                            })

                            _ = sut
                                .request(url, method: .post)
                                .validate(validation: { (request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult in
                                    expect(request).toNot(beNil())
                                    expect(request?.url) == url
                                    expect(response.statusCode) == 200
                                    expect(response.allHeaderFields["a"] as? String) == "b"
                                    expect(data) == mockData
                                    return .success
                                })
                                .responseObject(completionHandler: { (dataResponse: DataResponse<HttpBinResponse>) in
                                    result = dataResponse.result
                                })
                        }
                        it("success") {
                            expect(result).to(beSuccess())
                            expect(result?.value) == mockObject
                        }
                    } // context("success")
                    context("validation error") {
                        var result: Result<HttpBinResponse>?
                        beforeEach {
                            sut.mockResponse(.success(mockObject))

                            _ = sut
                                .request(url, method: .post)
                                .validate(validation: { (request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult in
                                    return .failure(SampleError())
                                })
                                .responseObject(completionHandler: { (dataResponse: DataResponse<HttpBinResponse>) in
                                    result = dataResponse.result
                                })
                        }
                        it("failure") {
                            expect(result).to(beFailure())
                        }
                    } // context("validation error")
                    context("result error") {
                        var result: Result<HttpBinResponse>?
                        beforeEach {
                            sut.mockResponse(Result<HttpBinResponse>.failure(SampleError()))

                            _ = sut
                                .request(url, method: .post)
                                .responseObject(completionHandler: { (dataResponse: DataResponse<HttpBinResponse>) in
                                    result = dataResponse.result
                                })
                        }
                        it("failure") {
                            expect(result).to(beFailure())
                        }
                    } // context("result error")
                } // describe("mockResponse<T: Decodable>()")

                describe("mockResponse<T>()") {
                    context("success") {
                        var result: Result<Void>?
                        beforeEach {
                            sut.mockResponse(.success(Void()), mockData: mockData, resultStatusCode: 200, resultHttpHeaders: ["a":"b"], validateRequest: { (url_: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?) in
                                expect { try! url_.asURL() } == url
                                expect(method.rawValue) == HTTPMethod.post.rawValue
                            })

                            _ = sut
                                .request(url, method: .post)
                                .validate(validation: { (request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult in
                                    expect(request).toNot(beNil())
                                    expect(request?.url) == url
                                    expect(response.statusCode) == 200
                                    expect(response.allHeaderFields["a"] as? String) == "b"
                                    expect(data) == mockData
                                    return .success
                                })
                                .response(completionHandler: { (dataResponse: DataResponse<Void>) in
                                    result = dataResponse.result
                                })
                        }
                        it("success") {
                            expect(result).to(beSuccess())
                        }
                    } // context("success")
                    context("validation error") {
                        var result: Result<Void>?
                        beforeEach {
                            sut.mockResponse(.success(Void()))

                            _ = sut
                                .request(url, method: .post)
                                .validate(validation: { (request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult in
                                    return .failure(SampleError())
                                })
                                .response(completionHandler: { (dataResponse: DataResponse<Void>) in
                                    result = dataResponse.result
                                })
                        }
                        it("failure") {
                            expect(result).to(beFailure())
                        }
                    } // context("validation error")
                    context("result error") {
                        var result: Result<Void>?
                        beforeEach {
                            sut.mockResponse(Result<Void>.failure(SampleError()))

                            _ = sut
                                .request(url, method: .post)
                                .response(completionHandler: { (dataResponse: DataResponse<Void>) in
                                    result = dataResponse.result
                                })
                        }
                        it("failure") {
                            expect(result).to(beFailure())
                        }
                    } // context("result error")
                } // describe("mockResponse<T>()")

                describe("mockUpload<T>()") {
                    context("success") {
                        var result: Result<Void>?
                        beforeEach {
                            sut.mockUpload(.success(Void()), mockData: mockData, resultStatusCode: 200, resultHttpHeaders: ["a":"b"], validateRequest: { (data: Data, url_: URLConvertible, method: HTTPMethod, headers: HTTPHeaders?) in
                                expect(data) == mockData
                                expect { try! url_.asURL() } == url
                                expect(method.rawValue) == HTTPMethod.put.rawValue
                            })

                            _ = sut
                                .upload(mockData, to: url, method: .put)
                                .validate(validation: { (request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult in
                                    expect(request).toNot(beNil())
                                    expect(request?.url) == url
                                    expect(response.statusCode) == 200
                                    expect(response.allHeaderFields["a"] as? String) == "b"
                                    expect(data) == mockData
                                    return .success
                                })
                                .response(completionHandler: { (dataResponse: DataResponse<Void>) in
                                    result = dataResponse.result
                                })
                        }
                        it("success") {
                            expect(result).to(beSuccess())
                        }
                    } // context("success")
                    context("validation error") {
                        var result: Result<Void>?
                        beforeEach {
                            sut.mockUpload(.success(Void()))

                            _ = sut
                                .upload(mockData, to: url, method: .put)
                                .validate(validation: { (request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult in
                                    return .failure(SampleError())
                                })
                                .response(completionHandler: { (dataResponse: DataResponse<Void>) in
                                    result = dataResponse.result
                                })
                        }
                        it("failure") {
                            expect(result).to(beFailure())
                        }
                    } // context("validation error")
                    context("result error") {
                        var result: Result<Void>?
                        beforeEach {
                            sut.mockUpload(Result<Void>.failure(SampleError()))

                            _ = sut
                                .upload(mockData, to: url, method: .put)
                                .response(completionHandler: { (dataResponse: DataResponse<Void>) in
                                    result = dataResponse.result
                                })
                        }
                        it("failure") {
                            expect(result).to(beFailure())
                        }
                    } // context("result error")
                } // describe("mockUpload<T>()")
            } // describe("response mocking")
        } // describe("Networking (extensions)")
    }
}
