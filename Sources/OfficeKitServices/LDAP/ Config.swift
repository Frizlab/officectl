/*
 *  Config.swift
 * LDAPOffice
 *
 * Created by François Lamboley on 2023/01/06.
 */

import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	struct LDAPOffice {}
	var ldapOffice: LDAPOffice {LDAPOffice()}
}


extension ConfKeys.LDAPOffice {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "me.frizlab.officekit-services.ldap"))
	
}


extension Conf {
	
	#declareConfAccessor(\.ldapOffice.logger, Logging.Logger?.self)
	
}
