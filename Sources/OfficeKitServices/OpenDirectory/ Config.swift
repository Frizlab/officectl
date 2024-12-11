/*
 *  Config.swift
 * OpenDirectoryOffice
 *
 * Created by François Lamboley on 2023/01/02.
 */

import Foundation

import Logging



public enum OpenDirectoryOfficeConfig : Sendable {
	
	static public var logger: Logger? = Logger(label: "me.frizlab.officekit-services.open-directory")
	
}

typealias Conf = OpenDirectoryOfficeConfig
