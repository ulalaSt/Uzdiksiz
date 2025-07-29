//
//  APICall.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 29.07.2025.
//

import Foundation
import SwiftUI

protocol APICall {
    var path: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    func body() throws -> Data?
}

enum APIError: Swift.Error, Equatable {
    case invalidURL
    case cancelled
    case invalidToken
    case pageNotFound
    case tokenNotFound
    case httpCode(HTTPCode)
    case clientError(String)
    case unexpectedResponse
    case imageDeserialization
    case noNetworkConnection
    case unexpectedError(String)
}

extension APIError: Identifiable, Hashable {
    var id: Int { hashValue }
}
extension APIError {
    var errorDescription: LocalizedStringKey {
        switch self {
        case .invalidURL: return "default_error"
        case .httpCode: return "default_error"
        case .unexpectedResponse: return "default_error"
        case .imageDeserialization: return "default_error"
        case let .clientError(message):
            let userNotFoundError = "user with phone=(.*?) not found"
            let otpNotFoundError = "OTP for specified phone not found."
            let wrongOTPError = "Wrong OTP."
            let fillNicknameError = "\"nickname\" can not be blank"
            let otpTimeOutPrefix = "OTP timeout: You have to wait "
            let otpTimeOutSuffix = " seconds"

            if let _ = message.range(of: userNotFoundError, options: .regularExpression) {
                return "number_not_registered"
            } else if message == otpNotFoundError {
                return "otp_not_found"
            } else if let start = message.range(of: otpTimeOutPrefix)?.upperBound,
                      let end = message.range(of: otpTimeOutSuffix)?.lowerBound,
                      let seconds = Int(message[start..<end]) {
                return "OTP timeout: You have to wait \(seconds) seconds"
            } else if message == fillNicknameError {
                return "fill_nickname"
            } else if message == wrongOTPError {
                return "wrong_otp"
            } else if message == "invalid family member phone" {
                return LocalizedStringKey(stringLiteral: message)
            }
            return LocalizedStringKey(stringLiteral: message)
        case .tokenNotFound: return "not_authorized"
        case .invalidToken: return "invalid_token"
        case .unexpectedError(let error): return "\(error)"
        case .noNetworkConnection: return "no_connection"
        case .cancelled: return "default_error"
        case .pageNotFound: return "page_not_found_error"
        }
    }
}

extension APICall {
    func urlRequest(baseURL: String, token: String? = nil) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = getHeader(with: token)
        request.httpBody = try body()
        return request
    }
    private func getHeader(with token: String?) -> [String: String]? {
        if let token = token {
            if var headers = headers {
                headers["X-Auth-Token"] = token
                return headers
            } else {
                let headers = ["X-Auth-Token": token]
                return headers
            }
        } else {
            return headers
        }
    }
}

typealias HTTPCode = Int
typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
    static let success = 200 ..< 300
    static let clientError = 400 ..< 500
}
