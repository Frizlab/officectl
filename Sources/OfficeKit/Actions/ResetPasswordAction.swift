/*
 * ResetPasswordAction.swift
 * OfficeKit
 *
 * Created by François Lamboley on 27/08/2018.
 */

import Foundation

import SemiSingleton
import Vapor



public class ResetPasswordAction : SemiSingleton {
	
	public enum Error : Swift.Error {
		
		case actionIsAlreadyExecuting
		
	}
	
	public typealias SemiSingletonKey = HappnUser
	public typealias SemiSingletonAdditionalInitInfo = Void
	
	public let user: HappnUser
	public private(set) var newPassword: String?
	
	public var isExecuting: Bool {
		return syncQueue.sync{ executingWitness != nil }
	}
	
	/* Sub-actions */
	public var modifyLDAPPasswordAction: ResetLDAPPasswordAction
	public var modifyGooglePasswordAction: ResetGooglePasswordAction
	
	public required init(key u: HappnUser, additionalInfo: Void, store: SemiSingletonStore) {
		user = u
		newPassword = nil
		
		operationQueue = OperationQueue() /* Concurrent */
		operationQueue.name = "Reset Password Operation Queue for \(user.email.stringValue)"
		syncQueue = DispatchQueue(label: "Reset Password Sync Queue for \(user.email.stringValue)", attributes: [/*serial*/])
		
		modifyLDAPPasswordAction = store.semiSingleton(forKey: u)
		modifyGooglePasswordAction = store.semiSingleton(forKey: u)
	}
	
	public func start(oldPassword: String, newPassword: String, container: Container) throws -> EventLoopFuture<Void> {
		try syncQueue.sync{
			guard self.executingWitness == nil else {throw Error.actionIsAlreadyExecuting}
			self.executingWitness = self
		}
		
		/* Let’s check the given old password */
		return try user.checkLDAPPassword(container: container, checkedPassword: oldPassword)
		.thenIfErrorThrowing{ error in
			self.syncQueue.sync{ self.executingWitness = nil }
			throw error
		}
		.map{
			/* The password of the user is verified. Let’s launch the resets! */
			return ()
		}
	}
	
	private let syncQueue: DispatchQueue
	private let operationQueue: OperationQueue
	
	private var executingWitness: ResetPasswordAction?
	
}
