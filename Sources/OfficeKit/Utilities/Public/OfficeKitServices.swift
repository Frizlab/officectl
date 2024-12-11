/*
 * OfficeKitServices.swift
 * officectl
 *
 * Created by François Lamboley on 2023/01/17.
 */

import Foundation

import SafeGlobal

import OfficeModelCore



public struct OfficeKitServices : Sendable {
	
	/* Maybe this should be in the config, using GlobalConfModule. */
	@SafeGlobal public static var providers = [String: OfficeService.Type]()
	
	public var authService: (any AuthenticatorService)?
	public var allServices = [Tag: any OfficeService]()
	
	public init(authService: (any AuthenticatorService)? = nil, allServices: [Tag: any OfficeService] = [:]) {
		self.authService = authService
		self.allServices = allServices
	}
	
	public var userServices: [any UserService] {
		return allServices.compactMap{ $0.value as? any UserService }
	}
	
	public func hashableUserServices(matching serviceIDs: String?) -> Set<HashableUserService> {
		let serviceIDs = serviceIDs.flatMap{ Set($0.split(separator: ",").map(Tag.init)) }
		return Set(userServices.filter{ service in serviceIDs?.contains(service.id) ?? true }.map(HashableUserService.init))
	}
	
}
