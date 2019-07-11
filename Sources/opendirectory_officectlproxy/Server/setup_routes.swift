/*
 * setup_routes.swift
 * opendirectory_officectlproxy
 *
 * Created by François Lamboley on 10/07/2019.
 */

import Foundation

import Vapor



func setup_routes(_ router: Router) throws {
	let userSearchController = UserSearchController()
	router.post("existing-user-from", "persistent-id", use: userSearchController.fromPersistentId)
	router.post("existing-user-from", "user-id",       use: userSearchController.fromUserId)
	router.post("existing-user-from", "email",         use: userSearchController.fromEmail)
	router.post("existing-user-from", "external-user", use: userSearchController.fromExternalUser)
	router.get("list-all-users",                       use: userSearchController.listAllUsers)
	
	let userController = UserController()
	router.post("create-user",     use: userController.createUser)
	router.post("update-user",     use: userController.updateUser)
	router.post("delete-user",     use: userController.deleteUser)
	router.post("change-password", use: userController.changePassword)
}
