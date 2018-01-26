//
//  TestSpec+exampleDisposable.swift
//  EnvelopeNetworkRx-ios-tests
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Quick
import RxSwift

/// Enable following constructs from within unit tests:
/// override func spec() {
///    it("") {
///       anyObservable
///          .subscribe { _ in }
///          .disposed(afterEach: self)
///    }
/// }
///
/// NOTE: This works in assumption that tests are executed sequentially in the main thread!
///
private var __exampleDisposable: CompositeDisposable?

class TestConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        configuration.afterEach {
            __exampleDisposable?.dispose()
            __exampleDisposable = nil
        }
    }
}

public protocol ExampleDisposableBinding {
    var exampleDisposable: CompositeDisposable { get }
}

extension TestSpec: ExampleDisposableBinding {
    public var exampleDisposable: CompositeDisposable {
        guard let exampleDisposable = __exampleDisposable else {
            let exampleDisposable = CompositeDisposable()
            __exampleDisposable = exampleDisposable
            return exampleDisposable
        }
        return exampleDisposable
    }
}

public extension Disposable {

    @discardableResult
    public func disposed(afterEach example: ExampleDisposableBinding) -> CompositeDisposable.DisposeKey? {
        return example.exampleDisposable.insert(self)
    }
}
