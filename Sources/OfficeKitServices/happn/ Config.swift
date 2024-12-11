/*
 *  Config.swift
 * HappnOffice
 *
 * Created by François Lamboley on 2022/11/15.
 */

import Foundation

import Logging



public enum HappnOfficeConfig : Sendable {
	
	static public var logger: Logger? = Logger(label: "me.frizlab.officekit-services.happn")
	
}

typealias Conf = HappnOfficeConfig
