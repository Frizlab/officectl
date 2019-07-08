/*
 * PasswordResetController.swift
 * officectl
 *
 * Created by François Lamboley on 09/08/2018.
 */

import Foundation

import SemiSingleton
import Vapor

import OfficeKit



final class WebPasswordResetController {
	
	func showUserSelection(_ req: Request) throws -> Future<View> {
		return try req.view().render("NewPasswordResetPage")
	}
	
	func showResetPage(_ req: Request) throws -> Future<View> {
		let email = try req.parameters.next(Email.self)
		let actions = try resetPasswordActions(for: email, container: req)
		return try renderResetPasswordActions(actions, for: email, view: req.view())
	}
	
	func resetPassword(_ req: Request) throws -> Future<View> {
		let view = try req.view()
		let email = try req.parameters.next(Email.self)
		let resetPasswordData = try req.content.syncDecode(ResetPasswordData.self)
		
		let officeKitServiceProvider = try req.make(OfficeKitServiceProvider.self)
		let authService = try officeKitServiceProvider.getDirectoryAuthenticatorService(container: req)
		
		guard let user = try authService.logicalUser(fromEmail: email) else {
			throw BasicValidationError("Cannot user this email to login (cannot convert to auth service user).")
		}
		return try authService.authenticate(userId: user.userId, challenge: resetPasswordData.oldPass, on: req)
		.map{ authSuccess -> Void in
			guard authSuccess else {throw BasicValidationError("Cannot login with these credentials.")}
			return ()
		}
		.flatMap{
			let actions = try self.resetPasswordActions(for: email, container: req)
			actions.forEach{ $0.resetAction.successValue?.start(parameters: resetPasswordData.newPass, weakeningMode: .always(successDelay: 180, errorDelay: 180), handler: nil) }
			return self.renderResetPasswordActions(actions, for: email, view: view)
		}
	}
	
	private struct ResetPasswordData : Decodable {
		
		var oldPass: String
		var newPass: String
		
	}
	
	private struct ResetPasswordActionAndService {
		
		var service: AnyDirectoryService
		var resetAction: Result<ResetPasswordAction, Error>
		
		init?(service s: AnyDirectoryService, email: Email, container: Container) throws {
			service = s
			guard let user = try s.logicalUser(fromEmail: email) else {return nil}
			resetAction = Result(catching: { try s.changePasswordAction(for: user, on: container) })
		}
		
	}
	
	private func resetPasswordActions(for email: Email, container: Container) throws -> [ResetPasswordActionAndService] {
		let officeKitServiceProvider = try container.make(OfficeKitServiceProvider.self)
		return try officeKitServiceProvider
			.getAllServices(container: container)
			.sorted{ $0.config.serviceName < $1.config.serviceName }
			.filter{ $0.supportsPasswordChange }
			.compactMap{ try ResetPasswordActionAndService(service: $0, email: email, container: container) }
	}
	
	private func renderResetPasswordActions(_ resetPasswordActions: [ResetPasswordActionAndService], for email: Email, view: ViewRenderer) -> Future<View> {
		struct ResetPasswordStatusContext : Encodable {
			struct ServicePasswordResetStatus : Encodable {
				var serviceName: String
				var isExecuting: Bool
				var hasRun: Bool
				var errorStr: String?
			}
			
			var userEmail: String
			var isExecuting: Bool
			
			var servicesResetStatus: [ServicePasswordResetStatus]
		}
		
		let context = ResetPasswordStatusContext(
			userEmail: email.stringValue,
			isExecuting: resetPasswordActions.reduce(false, { $0 || $1.resetAction.successValue?.isExecuting ?? false }),
			servicesResetStatus: resetPasswordActions.map{
				ResetPasswordStatusContext.ServicePasswordResetStatus(
					serviceName: $0.service.config.serviceName,
					isExecuting: $0.resetAction.successValue?.isExecuting ?? false,
					hasRun: !($0.resetAction.successValue?.isWeak ?? false),
					errorStr: ($0.resetAction.failureValue ?? $0.resetAction.successValue?.result?.failureValue)?.legibleLocalizedDescription
				)
			}
		)
		return view.render("PasswordResetStatusPage", context)
	}
	
}
