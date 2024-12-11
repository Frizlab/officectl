/*
 * FilePath+Decodable.swift
 * officectl
 *
 * Created by François Lamboley on 2023/01/16.
 */

import Foundation
#if canImport(System)
import System
#else
import SystemPackage
#endif

import ArgumentParser



extension FilePath : @retroactive ExpressibleByArgument {
	
	public init?(argument: String) {
		self.init(stringLiteral: argument)
	}
	
}
