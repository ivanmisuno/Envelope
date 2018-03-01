//: Playground - noun: a place where people can play

import Foundation
import Alamofire
import EnvelopeNetwork

// MARK: - Client API

struct TweetsResponse: Decodable {
    // ...
}

protocol TwitterAPIServicing {
    func searchTweets(q: String, responseCallback: @escaping (Result<TweetsResponse>) -> ())
}

class TwitterAPIServiceBase {
    struct Configuration {
        let endpointUrl: URL
        static func defaultConfiguration() -> Configuration {
            return Configuration(
                endpointUrl: URL(string: "https://api.twitter.com/1.1/search/tweets.json")!
            )
        }
    }

    fileprivate let network: Networking
    fileprivate let configuration: Configuration

    init(network: Networking,
         configuration: Configuration = Configuration.defaultConfiguration()) {
        self.network = network
        self.configuration = configuration
    }
}

// MARK: - DataSerializer

class TwitterAPIServiceDataSerializer: TwitterAPIServiceBase, TwitterAPIServicing {

    // MARK: - TwitterAPIServicing

    /// This version of the function uses `DataRequest.dataResponseSerializer()` to get raw response data for illustration purposes only. See the other variant instead.
    func searchTweets(q: String, responseCallback: @escaping (Result<TweetsResponse>) -> ()) {
        network
            .request(configuration.endpointUrl, method: .get, parameters: ["q": q], encoding: URLEncoding.queryString, headers: nil)
            .response(queue: DispatchQueue.main, responseSerializer: DataRequest.dataResponseSerializer(), completionHandler: { (dataResponse: DataResponse<Data>) in
                switch dataResponse.result {
                case .success(let responseData):
                    do {
                        // read json from network response
                        let tweetsResponse: TweetsResponse = try JSONDecoder().decode(TweetsResponse.self, from: responseData)
                        // deserialize typed object from json
                        responseCallback(.success(tweetsResponse))
                    } catch {
                        responseCallback(.failure(error))
                    }
                case .failure(let error):
                    responseCallback(.failure(error))
                }
            })
    }
}

// MARK: - CodableSerializer

class TwitterAPIServiceCodableSerializer: TwitterAPIServiceBase, TwitterAPIServicing {

    func searchTweets(q: String, responseCallback: @escaping (Result<TweetsResponse>) -> ()) {
        network
            .get(configuration.endpointUrl, parameters: ["q": q])
            .responseObject { (response: DataResponse<TweetsResponse>) in
                responseCallback(response.result)
        }
    }
}

import Quick
import Nimble
import EnvelopeTest

class TwitterAPIServiceCodableSerializerSpec: TestSpec {
    override func spec() {
        describe("TwitterAPIServiceCodableSerializer") {
            var network: NetworkingMock!
            var sut: TwitterAPIServiceCodableSerializer!

            let mockEndpointUrl = URL(string: "https://search.twitter.com/1")!
            let mockConfiguration = TwitterAPIServiceCodableSerializer.Configuration(endpointUrl: mockEndpointUrl)

            beforeEach {
                network = NetworkingMock()
                sut = TwitterAPIServiceCodableSerializer(
                    network: network,
                    configuration: mockConfiguration)
            }

            describe("searchTweets()") {
                let mockQuery = "#awesome_testing"
                let mockResult = Result.success(TweetsResponse())
                var actualUrl: URL?
                var actualQuery: String?
                var observedResult: Result<TweetsResponse>?
                beforeEach {
                    network.mockResponse(mockResult, validateRequest: { (url: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?) in
                        actualUrl = try? url.asURL()
                        actualQuery = parameters?["q"] as? String
                    })

                    _ = sut.searchTweets(q: mockQuery, responseCallback: { (result: Result<TweetsResponse>) in
                        observedResult = result
                    })
                }
                it("network.request() is called") {
                    expect(network.requestCallCount) == 1
                }
                it("correct URL was used") {
                    expect(actualUrl) == mockEndpointUrl
                }
                it("cotrrect parameter was used") {
                    expect(actualQuery) == mockQuery
                }
                it("observed result as expected") {
                    expect(observedResult).to(beSuccess())
                    expect(observedResult?.value) == mockResult.value
                }
            } // describe("searchTweets()")
        } // describe("TwitterAPIServiceCodableSerializer")
    }
}

// MARK: - Rx client

import EnvelopeNetworkRx
import RxSwift
import RxTest

protocol TwitterAPIServicingRx {
    func searchTweets(q: String) -> Single<TweetsResponse>
}

class TwitterAPIServiceRx: TwitterAPIServiceBase, TwitterAPIServicingRx {
    // MARK: - TwitterAPIServicingRx
    func searchTweets(q: String) -> Single<TweetsResponse> {
        return network
            .rx.get(configuration.endpointUrl, parameters: ["q": q])
            .object()
    }
}

class TwitterAPIServiceRxSpec: TestSpec {
    override func spec() {
        describe("TwitterAPIServiceRx") {
            var network: NetworkingMock!
            var sut: TwitterAPIServiceRx!

            let mockEndpointUrl = URL(string: "https://search.twitter.com/1")!
            let mockConfiguration = TwitterAPIServiceRx.Configuration(endpointUrl: mockEndpointUrl)

            beforeEach {
                network = NetworkingMock()
                sut = TwitterAPIServiceRx(
                    network: network,
                    configuration: mockConfiguration)
            }

            describe("searchTweets()") {
                let mockQuery = "#awesome_testing"
                let mockResult = Result.success(TweetsResponse())
                var actualUrl: URL?
                var actualQuery: String?
                var observedResult: SingleEvent<TweetsResponse>?
                beforeEach {
                    network.mockResponse(mockResult, validateRequest: { (url: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?) in
                        actualUrl = try? url.asURL()
                        actualQuery = parameters?["q"] as? String
                    })

                    sut
                        .searchTweets(q: mockQuery)
                        .subscribe { (result: SingleEvent<TweetsResponse>) in
                            observedResult = result
                        }
                        .disposed(afterEach: self)
                }
                it("network.request() is called") {
                    expect(network.requestCallCount) == 1
                }
                it("correct URL was used") {
                    expect(actualUrl) == mockEndpointUrl
                }
                it("cotrrect parameter was used") {
                    expect(actualQuery) == mockQuery
                }
                it("observed result as expected") {
                    expect(observedResult).to(beSuccess())
                    expect(observedResult?.value) == mockResult.value
                }
            } // describe("searchTweets()")
        } // describe("TwitterAPIServiceRx")
    }
}

// MARK: - Extensions

extension TweetsResponse: Equatable {
}

func ==(lhs: TweetsResponse, rhs: TweetsResponse) -> Bool {
    return true // TODO
}
