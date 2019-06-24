/*
 * backup.swift
 * officectl
 *
 * Created by François Lamboley on 6/26/18.
 */

import Foundation

import Guaka
import Vapor

import OfficeKit



func backup(flags f: Flags, arguments args: [String], context: CommandContext) throws -> Future<Void> {
	throw NSError(domain: "com.happn.officectl", code: 1, userInfo: [NSLocalizedDescriptionKey: "Please choose what to backup"])
}
