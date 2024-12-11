/*
 *  Config.swift
 * LDAPOffice
 *
 * Created by François Lamboley on 2023/01/06.
 */

import Foundation

import Logging



public enum LDAPOfficeConfig : Sendable {
	
	static public var logger: Logger? = Logger(label: "me.frizlab.officekit-services.ldap")
	
}

typealias Conf = LDAPOfficeConfig
