//
//  NetworkUploadRequesting.swift
//  Envelope-ios
//
//  Created by Ivan Misuno on 24-01-2018.
//  Copyright © 2018. All rights reserved.
//

import Alamofire

protocol NetworkUploadRequesting: NetworkRequesting {

    @discardableResult
    func uploadProgress(
        queue: DispatchQueue,
        closure: @escaping Request.ProgressHandler)
        -> Self
}

extension NetworkUploadRequesting {

    @discardableResult
    func uploadProgress(
        closure: @escaping Request.ProgressHandler)
        -> Self {
            return uploadProgress(queue: DispatchQueue.main, closure: closure)
    }
}
