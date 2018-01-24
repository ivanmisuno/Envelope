//
//  resultMatchers.swift
//  EnvelopeNetwork-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Nimble
import Alamofire

func beFailure<T>() -> Predicate<Result<T>> {
    return Predicate.define("be .failure") { actualExpression, msg in
        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(status: .fail, message: msg)
        }

        return PredicateResult(status: PredicateStatus(bool: actualValue.isFailure), message: msg)
    }
}

func beSuccess<T>() -> Predicate<Result<T>> {
    return Predicate.define("be .success") { actualExpression, msg in
        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(status: .fail, message: msg)
        }

        return PredicateResult(status: PredicateStatus(bool: actualValue.isSuccess), message: msg)
    }
}
