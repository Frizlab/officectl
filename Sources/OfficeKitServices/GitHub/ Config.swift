/*
 *  Config.swift
 * GitHubOffice
 *
 * Created by François Lamboley on 2022/12/28.
 */

import Foundation

import Logging



public enum GitHubOfficeConfig : Sendable {
	
	static public var logger: Logger? = Logger(label: "me.frizlab.officekit-services.github")
	
}

typealias Conf = GitHubOfficeConfig
