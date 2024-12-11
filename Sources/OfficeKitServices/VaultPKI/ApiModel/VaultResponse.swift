/*
 * VaultResponse.swift
 * VaultPKIOffice
 *
 * Created by François Lamboley on 2022/09/28.
 */

import Foundation



struct VaultResponse<ObjectType : Decodable & Sendable> : Decodable, Sendable {
	
	var data: ObjectType
	
}
