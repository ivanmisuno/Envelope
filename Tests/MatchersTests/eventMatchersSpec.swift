//
//  eventMatchersSpec.swift
//  EnvelopeNetworkRx-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Quick
@testable import Nimble // for `internal SourceLocation.init()`
import RxSwift
import RxTest
import EnvelopeTest

class eventMatchersSpec: TestSpec {
    override func spec() {
        describe("event matchers") {
            context("Event") {
                let error: Event<String>? = .error(SampleError())
                let next: Event<String>? = .next("Next")
                let completed: Event<String>? = .completed
                let `nil`: Event<String>? = nil

                describe("beFailure()") {
                    it("true for .error") {
                        expect(error).to(beFailure())
                    }
                    it("false for .next") {
                        expect(next).toNot(beFailure())
                    }
                    it("false for .completed") {
                        expect(completed).toNot(beFailure())
                    }
                    it("both to() and toNot() would fail for `nil` value") {
                        let expression = Expression<Event<String>>(expression: ({ `nil` }), location: SourceLocation(file: #file, line: #line))
                        let result = try! beFailure().satisfies(expression)
                        expect(result.toBoolean(expectation: .toMatch)) == false
                        expect(result.toBoolean(expectation: .toNotMatch)) == false
                    }
                }
            } // context("Event")
            context("SingleEvent") {
                let error: SingleEvent<String>? = .error(SampleError())
                let success: SingleEvent<String>? = .success("Next")
                let `nil`: SingleEvent<String>? = nil

                describe("beFailure()") {
                    it("true for .error") {
                        expect(error).to(beFailure())
                    }
                    it("false for .success") {
                        expect(success).toNot(beFailure())
                    }
                    it("both to() and toNot() would fail for `nil` value") {
                        let expression = Expression<SingleEvent<String>>(expression: ({ `nil` }), location: SourceLocation(file: #file, line: #line))
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
                        expect(error).toNot(beSuccess())
                    }
                    it("both to() and toNot() would fail for `nil` value") {
                        let expression = Expression<SingleEvent<String>>(expression: ({ `nil` }), location: SourceLocation(file: #file, line: #line))
                        let result = try! beSuccess().satisfies(expression)
                        expect(result.toBoolean(expectation: .toMatch)) == false
                        expect(result.toBoolean(expectation: .toNotMatch)) == false
                    }
                }

            } // context("SingleEvent")
        }
    }
}
