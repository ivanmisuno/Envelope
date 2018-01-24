//
//  eventMatchers.swift
//  EnvelopeNetworkRx-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Nimble
import RxSwift
import RxTest


// MARK: - Event
extension Event {
    var isFailure: Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }
}

func beFailure<T>() -> Predicate<Event<T>> {
    return Predicate.define("be .failure") { actualExpression, msg in
        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(status: .fail, message: msg)
        }

        return PredicateResult(status: PredicateStatus(bool: actualValue.isFailure), message: msg)
    }
}


// MARK: - SingleEvent
extension SingleEvent {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .error:
            return false
        }
    }

    var isFailure: Bool {
        switch self {
        case .success:
            return false
        case .error:
            return true
        }
    }
}

func beSuccess<T>() -> Predicate<SingleEvent<T>> {
    return Predicate.define("be .success") { actualExpression, msg in
        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(status: .fail, message: msg)
        }

        return PredicateResult(status: PredicateStatus(bool: actualValue.isSuccess), message: msg)
    }
}

func beFailure<T>() -> Predicate<SingleEvent<T>> {
    return Predicate.define("be .failure") { actualExpression, msg in
        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(status: .fail, message: msg)
        }

        return PredicateResult(status: PredicateStatus(bool: actualValue.isFailure), message: msg)
    }
}
