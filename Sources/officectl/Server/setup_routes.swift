/*
 * setup_routes.swift
 * officectl
 *
 * Created by François Lamboley on 06/08/2018.
 */

import Foundation

import Vapor



func setup_routes(_ router: Router) throws {
	/* Basic "Hello, world!" example */
	router.get("hello") { req in
		return "Hello, world!"
	}
	
	let resetPasswordController = PasswordResetController()
	router.get("password-reset", use: resetPasswordController.index)
}
