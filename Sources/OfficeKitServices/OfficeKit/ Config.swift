/*
 *  Config.swift
 * OfficeKitOffice
 *
 * Created by François Lamboley on 2023/01/09.
 */

import Foundation

import Logging



public enum OfficeKitOfficeConfig : Sendable {
	
	static public var logger: Logger? = Logger(label: "me.frizlab.officekit-services.officekit")
	
}

typealias Conf = OfficeKitOfficeConfig
