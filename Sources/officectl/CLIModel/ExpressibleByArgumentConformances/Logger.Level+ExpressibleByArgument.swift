/*
 * Logger.Level+ExpressibleByArgument.swift
 * officectl
 *
 * Created by François Lamboley on 2023/01/12.
 */

import Foundation

import ArgumentParser
import Logging



extension Logger.Level : @retroactive ExpressibleByArgument {
	
	public init?(argument: String) {
		self.init(rawValue: argument)
	}
	
}
