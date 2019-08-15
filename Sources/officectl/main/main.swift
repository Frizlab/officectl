/*
 * main.swift
 * officectl
 *
 * Created by François Lamboley on 6/26/18.
 */

import Foundation

import LegibleError
import OfficeKit
import Vapor



do {try app().run()}
catch {
	print("Error creating or running the App.", to: &stderrStream)
	print("   error \(error.legibleLocalizedDescription)", to: &stderrStream)
	exit(Int32((error as NSError).code))
}
