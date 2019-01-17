/*
 * User+LDAP.swift
 * OfficeKit
 *
 * Created by François Lamboley on 10/09/2018.
 */

import Foundation

import SemiSingleton
import Vapor



extension User {
	
	public init?(ldapInetOrgPerson: LDAPInetOrgPerson) {
		guard let dn = try? LDAPDistinguishedName(string: ldapInetOrgPerson.dn), let f = ldapInetOrgPerson.givenName?.first, let l = ldapInetOrgPerson.sn.first else {return nil}
		id = .distinguishedName(dn)
		
		distinguishedName = dn
		googleUserId = nil
		gitHubId = nil
		email = ldapInetOrgPerson.mail?.first
		
		firstName = f
		lastName = l
		
		sshKey = nil
		password = ldapInetOrgPerson.userPassword
	}
	
	public func distinguishedNameIdVariant() -> User? {
		guard let dn = distinguishedName else {return nil}
		
		var ret = self
		ret.id = .distinguishedName(dn)
		return ret
	}
	
	public func checkLDAPPassword(container: Container, checkedPassword: String) throws -> Future<Void> {
		guard !checkedPassword.isEmpty else {throw Error.passwordIsEmpty}
		
		let dn = try nil2throw(distinguishedName, "dn")
		let asyncConfig = try container.make(AsyncConfig.self)
		var ldapConnectorConfig = try container.make(OfficeKitConfig.self).ldapConfigOrThrow().connectorSettings
		ldapConnectorConfig.authMode = .userPass(username: dn.stringValue, password: checkedPassword)
		let connector = try LDAPConnector(key: ldapConnectorConfig)
		return connector.connect(scope: (), forceIfAlreadyConnected: true, asyncConfig: asyncConfig)
	}
	
	public func existingLDAPUser(container: Container, attributesToFetch: [String] = ["objectClass", "sn", "cn"]) throws -> Future<LDAPInetOrgPerson> {
		let asyncConfig = try container.make(AsyncConfig.self)
		let semiSingletonStore = try container.make(SemiSingletonStore.self)
		let ldapConnectorConfig = try container.make(OfficeKitConfig.self).ldapConfigOrThrow().connectorSettings
		let ldapConnector: LDAPConnector = try semiSingletonStore.semiSingleton(forKey: ldapConnectorConfig)
		
		let searchedDN = try nil2throw(distinguishedName, "dn")
		let uids = searchedDN.relativeDistinguishedNameValues(for: "uid")
		guard let uid = uids.first, uids.count == 1 else {throw Error.userNotFound}
		
		let searchBase = searchedDN.relativeDistinguishedName(for: "dc")
		let searchQuery = LDAPSearchQuery.simple(attribute: LDAPAttributeDescription(stringOid: "uid")!, filtertype: .equal, value: Data(uid.utf8))
		
		let future = ldapConnector.connect(scope: (), asyncConfig: asyncConfig)
		.then{ _ -> EventLoopFuture<[LDAPObject]> in
			let op = SearchLDAPOperation(ldapConnector: ldapConnector, request: LDAPSearchRequest(scope: .children, base: searchBase, searchQuery: searchQuery, attributesToFetch: attributesToFetch))
			return asyncConfig.eventLoop.future(from: op, queue: asyncConfig.operationQueue, resultRetriever: { op in
				try print(op.results.successValueOrThrow().results)
				return try op.results.successValueOrThrow().results
			})
		}
		.thenThrowing{ objects -> LDAPInetOrgPerson in
			guard objects.count <= 1 else {
				throw Error.tooManyUsersFound
			}
			guard let inetOrgPerson = objects.first?.inetOrgPerson else {
				throw Error.userNotFound
			}
			return inetOrgPerson
		}
		return future
	}
	
	/**
	Creates an LDAP Inet Org Person from the happn User.
	
	The following properties are migrated:
	- username
	- email
	- firstName
	- lastName
	
	The cn of the returned object is inferred from the first and last name of the
	User. If the first or last name is nil in the User, it will be set to
	"<Unknown>".
	
	No password will be set in the returned object.
	
	- parameter baseDN: The base DN in which the returned user will be. Example:
	`ou=people,dc=example,dc=org`
	
	- throws: If there are no emails in the `User`. */
	public func ldapInetOrgPerson(baseDN: LDAPDistinguishedName) throws -> LDAPInetOrgPerson {
		let e = try nil2throw(email, "email")
		let lastNameNonOptional = (lastName ?? "<Unknown>")
		let firstNameNonOptional = (firstName ?? "<Unknown>")
		let dn = LDAPDistinguishedName(uid: e.username, baseDN: baseDN)
		let ret = LDAPInetOrgPerson(dn: dn.stringValue, sn: [lastNameNonOptional], cn: [firstNameNonOptional + " " + lastNameNonOptional])
		ret.givenName = [firstNameNonOptional]
		ret.uid = e.username
		ret.mail = [e]
		return ret
	}
	
}