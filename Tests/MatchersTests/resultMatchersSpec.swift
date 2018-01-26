//
//  resultMatchersSpec.swift
//  EnvelopeNetwork-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire
import Quick
@testable import Nimble // for `internal SourceLocation.init()`
import EnvelopeTest

class resultMatchersSpec: TestSpec {
    override func spec() {
        describe("Alamofire.Result matchers") {

            let failure: Result<String>? = .failure(SampleError())
            let success: Result<String>? = .success("Success")
            let `nil`: Result<String>? = nil

            describe("beFailure()") {
                it("true for failure") {
                    expect(failure).to(beFailure())
                }
                it("false for success") {
                    expect(success).toNot(beFailure())
                }
                it("both to() and toNot() would fail for `nil` value") {
                    let expression = Expression<Result<String>>(expression: ({ `nil` }), location: SourceLocation(file: #file, line: #line))
                    let result = try! beFailure().satisfies(expression)
                    expect(result.toBoolean(expectation: .toMatch)) == false
                    expect(result.toBoolean(expectation: .toNotMatch)) == false
                }
            }
            describe("beSuccess()") {
                it("true for success") {
                    expect(success).to(beSuccess())
                }
                it("false for failure") {
                    expect(failure).toNot(beSuccess())
                }
                it("both to() and toNot() would fail for `nil` value") {
                    let expression = Expression<Result<String>>(expression: ({ `nil` }), location: SourceLocation(file: #file, line: #line))
                    let result = try! beSuccess().satisfies(expression)
                    expect(result.toBoolean(expectation: .toMatch)) == false
                    expect(result.toBoolean(expectation: .toNotMatch)) == false
                }
            }
        }
    }
}
