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



final class PasswordResetController {
	
	func showUserSelection(_ req: Request) throws -> Future<View> {
		return try req.view().render("PasswordResetPage")
	}
	
	func showResetPage(_ req: Request) throws -> Future<View> {
		let email = try req.parameters.next(Email.self)
		let semiSingletonStore = try req.make(SemiSingletonStore.self)
		#warning("TODO: We must provide the base DN in a config or via the command line")
		let resetPasswordAction = semiSingletonStore.semiSingleton(forKey: User(email: email, baseDN: LDAPDistinguishedName(values: [(key: "dc", value: "happn"), (key: "dc", value: "test")]))) as ResetPasswordAction
		
		return try renderResetPasswordAction(resetPasswordAction, view: req.view())
	}
	
	func resetPassword(_ req: Request) throws -> Future<View> {
		let view = try req.view()
		let email = try req.parameters.next(Email.self)
		let semiSingletonStore = try req.make(SemiSingletonStore.self)
		let resetPasswordData = try req.content.syncDecode(ResetPasswordData.self)
		#warning("TODO: We must provide the base DN in a config or via the command line")
		let user = User(email: email, baseDN: LDAPDistinguishedName(values: [(key: "dc", value: "happn"), (key: "dc", value: "test")]))
		
		return try user
		.checkLDAPPassword(container: req, checkedPassword: resetPasswordData.oldPass)
		.then{ _ in
			/* The password of the user is verified. Let’s launch the reset! */
			let resetPasswordAction = semiSingletonStore.semiSingleton(forKey: user) as ResetPasswordAction
			resetPasswordAction.start(config: (newPassword: resetPasswordData.newPass, container: req), weakeningDelay: 3, handler: nil)
			return self.renderResetPasswordAction(resetPasswordAction, view: view)
		}
	}
	
	private struct ResetPasswordData : Decodable {
		
		var oldPass: String
		var newPass: String
		
	}
	
	private func renderResetPasswordAction(_ resetPasswordAction: ResetPasswordAction, view: ViewRenderer) -> EventLoopFuture<View> {
		let emailStr = resetPasswordAction.user.email?.stringValue ?? "<unknown>"
		if !resetPasswordAction.isExecuting {
			return view.render("PasswordResetPage", ["user_email": emailStr])
		} else {
			return view.render("PasswordResetInProgressPage", ["user_email": emailStr])
		}
	}
	
}
