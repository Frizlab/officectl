/*
 * ErasureUtils.swift
 * OfficeKit
 *
 * Created by François Lamboley on 11/07/2019.
 */

import Foundation



func serviceUserPair<SourceServiceType : DirectoryService, DestinationServiceType : DirectoryService>(from service: SourceServiceType, user: SourceServiceType.UserType) throws -> (DestinationServiceType, DestinationServiceType.UserType)? {
	if let service: DestinationServiceType = service.unboxed() {
		guard let user: DestinationServiceType.UserType = user.unboxed() else {
			/* In theory we can fatalError here. However, because we’re a server
			 * and must not crash, let’s play it safe. */
//			fatalError("Got impossible situation where service is unboxed to \(DestinationServiceType.self), but the user is not unboxed to this directory user type!")
			throw InternalError(message: "Got impossible situation where service is unboxed to \(DestinationServiceType.self), but the user is not unboxed to this directory user type!")
		}
		return (service, user)
	}
	return nil
}
