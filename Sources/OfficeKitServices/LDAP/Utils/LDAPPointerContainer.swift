/*
 * LDAPPointerContainer.swift
 * LDAPOffice
 *
 * Created by François Lamboley on 2024/12/17.
 */

import Foundation

import COpenLDAP
import GlobalConfModule



internal final class LDAPPointerContainer {
	
	/* Type of this variable in C: “LDAP*”.
	 * We cannot use the LDAP type as it is not exported to Swift,
	 *  because it is opaque in C headers… */
	internal let value: OpaquePointer
	private var hasBeenUnbound: Bool = false
	
	internal init(_ value: OpaquePointer) {
		self.value = value
	}
	
	internal func unbind() throws {
		let r = ldap_unbind_ext_s(value, nil, nil)
		guard r == LDAP_SUCCESS else {
			throw OpenLDAPError(code: r)
		}
		hasBeenUnbound = true
	}
	
	deinit {
		guard !hasBeenUnbound else {return}
		if ldap_unbind_ext_s(value, nil, nil) != LDAP_SUCCESS {
			Conf.logger?.warning("LEAKING ldap struct: ldap_unbind failed in LDAPPointerContainer deinit.")
		}
	}
	
}
