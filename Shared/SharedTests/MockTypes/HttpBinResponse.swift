//
//  HttpBinResponse.swift
//  Envelope
//
//  Created by Ivan Misuno on 26-01-2018.
//

import Foundation

struct HttpBinResponse: Decodable {
    let args: [String: String]
    let headers: [String: String]
    let origin: String
    let url: String

    static let rawHttpBinGetResponse: Data = "{\"args\": {}, \"headers\": {\"Accept\": \"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8\", \"Accept-Encoding\": \"gzip, deflate\", \"Accept-Language\": \"en-US,en;q=0.9,ru;q=0.8,uk;q=0.7\", \"Connection\": \"close\", \"Cookie\": \"_gauges_unique_month=1; _gauges_unique_year=1; _gauges_unique=1; _gauges_unique_hour=1; _gauges_unique_day=1\", \"Host\": \"httpbin.org\", \"Referer\": \"http://httpbin.org/\", \"Upgrade-Insecure-Requests\": \"1\", \"User-Agent\": \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36\"}, \"origin\": \"77.60.83.148\", \"url\": \"http://httpbin.org/get\"}".data(using: .utf8)!
}

extension HttpBinResponse: Equatable {}
func ==(lhs: HttpBinResponse, rhs: HttpBinResponse) -> Bool {
    return lhs.args == rhs.args
        && lhs.headers == rhs.headers
        && lhs.origin == rhs.origin
        && lhs.url == rhs.url
}
