/*
 * ODObjectWrapper.swift
 * OpenDirectoryOffice
 *
 * Created by François Lamboley on 2023/01/04.
 */

import Foundation
import OpenDirectory



@ODActor
@propertyWrapper
internal final class ODObjectWrapper<ODObject> {
	
	var wrappedValue: ODObject?
	
	nonisolated init() {
		/* The init can only be done with the default wrapped value, otherwise it’d have to be an isolated init. */
	}
	
	func perform<T : Sendable>(_ block: @ODActor @Sendable (inout ODObject?) throws -> T) rethrows -> T {
		return try block(&wrappedValue)
	}
	
}
