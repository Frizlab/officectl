/*
 * GetGoogleUserOperation.swift
 * OfficeKit
 *
 * Created by François Lamboley on 13/09/2018.
 */

import Foundation

import RetryingOperation



/* https://developers.google.com/admin-sdk/directory/v1/reference/users/get */
public final class GetGoogleUserOperation : RetryingOperation, HasResult {
	
	public typealias ResultType = GoogleUser
	
	public static let scopes = Set(arrayLiteral: "https://www.googleapis.com/auth/admin.directory.user")
	
	public let connector: GoogleJWTConnector
	
	public let userKey: String
	
	public private(set) var result = Result<GoogleUser, Error>.failure(OperationIsNotFinishedError())
	public func resultOrThrow() throws -> GoogleUser {
		return try result.get()
	}
	
	/** Init the operation with the given user key. A user key is either the
	Google id of the user or the email of the user. */
	public init(userKey k: String, connector c: GoogleJWTConnector) {
		userKey = k
		connector = c
	}
	
	public override func startBaseOperation(isRetry: Bool) {
		let urlComponents = URLComponents(url: URL(string: userKey, relativeTo: URL(string: "https://www.googleapis.com/admin/directory/v1/users/")!)!, resolvingAgainstBaseURL: true)!
		
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .customISO8601
		decoder.keyDecodingStrategy = .useDefaultKeys
		let op = AuthenticatedJSONOperation<GoogleUser>(url: urlComponents.url!, authenticator: connector.authenticate, decoder: decoder)
		op.completionBlock = {
			guard let o = op.result else {
				self.result = .failure(op.finalError ?? NSError(domain: "com.happn.officectl", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unknown error while fetching the user"]))
				self.baseOperationEnded()
				return
			}
			
			self.result = .success(o)
			self.baseOperationEnded()
		}
		op.start()
	}
	
	public override var isAsynchronous: Bool {
		return true
	}
	
}
