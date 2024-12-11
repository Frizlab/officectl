/*
 * experimental.swift
 * officectl
 *
 * Created by François Lamboley on 2023/08/17.
 */

import Foundation

import ArgumentParser



struct Experimental : AsyncParsableCommand {
	
	static let configuration = CommandConfiguration(
		abstract: "Experimental commands; use with care.",
		shouldDisplay: false,
		subcommands: [
			Experimental_ConsolePerm.self
		]
	)
	
	@OptionGroup()
	var officectlOptions: Officectl.Options
	
}
