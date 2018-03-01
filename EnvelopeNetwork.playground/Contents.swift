//: Playground - noun: a place where people can play

import Foundation
import Alamofire
import EnvelopeNetwork

struct TweetsResponse: Decodable {
    // ...
}

protocol TwitterAPIServicing {
    func searchTweets(q: String, responseCallback: @escaping (Result<TweetsResponse>) -> ())
}

class TwitterAPIService: TwitterAPIServicing {
    struct Configuration {
        let endpointUrl: URL
        static func defaultConfiguration() -> Configuration {
            return Configuration(
                endpointUrl: URL(string: "https://api.twitter.com/1.1/search/tweets.json")!
            )
        }
    }

    private let network: Networking
    private let configuration: Configuration

    init(network: Networking,
         configuration: Configuration = Configuration.defaultConfiguration()) {
        self.network = network
        self.configuration = configuration
    }

    // MARK: - TwitterAPIServicing

    /*
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
 */

    func searchTweets(q: String, responseCallback: @escaping (Result<TweetsResponse>) -> ()) {
        network
            .get(configuration.endpointUrl, parameters: ["q": q])
            .responseObject { (response: DataResponse<TweetsResponse>) in
                responseCallback(response.result)
        }
    }
}

// MARK: - Test spec

import Quick
import Nimble
import EnvelopeTest

class TwitterAPIServiceSpec: TestSpec {
    override func spec() {
        describe("TwitterAPIService") {
            var network: NetworkingMock!
            var sut: TwitterAPIService!

            let mockEndpointUrl = URL(string: "https://search.twitter.com/1")!
            let mockConfiguration = TwitterAPIService.Configuration(endpointUrl: mockEndpointUrl)

            beforeEach {
                network = NetworkingMock()
                sut = TwitterAPIService(
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
                    expect(observedResult?.value) == mockResult.value
                }
            } // describe("searchTweets()")
        } // describe("TwitterAPIService")
    }
}

extension TweetsResponse: Equatable {
}

func ==(lhs: TweetsResponse, rhs: TweetsResponse) -> Bool {
    return true // TODO
}
