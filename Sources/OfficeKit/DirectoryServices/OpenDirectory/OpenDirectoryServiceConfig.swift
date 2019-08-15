/*
 * OpenDirectoryServiceConfig.swift
 * OfficeKit
 *
 * Created by François Lamboley on 20/06/2019.
 */

#if !canImport(DirectoryService) || !canImport(OpenDirectory)

public typealias OpenDirectoryServiceConfig = DummyServiceConfig

#else

import Foundation
import OpenDirectory

import GenericStorage



public struct OpenDirectoryServiceConfig : OfficeKitServiceConfig {
	
	public var global: GlobalConfig
	
	public var providerId: String
	
	public var serviceId: String
	public var serviceName: String
	
	public var mergePriority: Int?
	
	public var connectorSettings: OpenDirectoryConnector.Settings
	public var baseDNPerDomain: [String: LDAPDistinguishedName]
	public var peopleBaseDNPerDomain: [String: LDAPDistinguishedName]?
	
	public var allBaseDNs: Set<LDAPDistinguishedName> {
		return Set(baseDNPerDomain.values)
	}
	
	public var allDomains: Set<String> {
		return Set(baseDNPerDomain.keys)
	}
	
	public init(globalConfig: GlobalConfig, providerId pId: String, serviceId id: String, serviceName name: String, mergePriority p: Int?, connectorSettings c: OpenDirectoryConnector.Settings, baseDNPerDomainString: [String: String], peopleDNString: String?) throws {
		global = globalConfig
		
		let bdn = try baseDNPerDomainString.mapValues{ try LDAPDistinguishedName(string: $0) }
		baseDNPerDomain = bdn
		peopleBaseDNPerDomain = try peopleDNString.flatMap{ peopleDNString -> [String: LDAPDistinguishedName] in
			guard !peopleDNString.isEmpty else {return bdn}
			let pdnc = try LDAPDistinguishedName(string: peopleDNString)
			return bdn.mapValues{ pdnc + $0 }
		}
		
		precondition(id != "invalid" && id != "email" && !id.contains(":"))
		providerId = pId
		serviceId = id
		serviceName = name
		mergePriority = p
		
		connectorSettings = c
	}
	
	public init(globalConfig: GlobalConfig, providerId pId: String, serviceId id: String, serviceName name: String, genericConfig: GenericStorage, pathsRelativeTo baseURL: URL?) throws {
		let domain = [id]
		
		let proxySettings = try genericConfig.optionalNonNullStorage(forKey: "proxy", currentKeyPath: domain).flatMap{ proxyGenericConfig -> OpenDirectoryConnector.ProxySettings in
			let keyPath = domain + ["proxy"]
			return (
				hostname: try proxyGenericConfig.string(forKey: "hostname", currentKeyPath: keyPath),
				username: try proxyGenericConfig.string(forKey: "username", currentKeyPath: keyPath),
				password: try proxyGenericConfig.string(forKey: "password", currentKeyPath: keyPath)
			)
		}
		
		let nodeName = try genericConfig.string(forKey: "node_name", currentKeyPath: domain)
		let username = try genericConfig.string(forKey: "admin_username", currentKeyPath: domain)
		let password = try genericConfig.string(forKey: "admin_password", currentKeyPath: domain)
		
		let bdnDic    = try genericConfig.dictionaryOfStrings(forKey: "base_dn_per_domains", currentKeyPath: domain)
		let pdnString = try genericConfig.optionalString(forKey: "people_dn", currentKeyPath: domain)
		
		let mp = try genericConfig.optionalInt(forKey: "mergePriority", currentKeyPath: domain)
		
		let connectorSettings = OpenDirectoryConnector.Settings(proxySettings: proxySettings, nodeName: nodeName, nodeCredentials: (recordType: kODRecordTypeUsers, username: username, password: password))
		try self.init(globalConfig: globalConfig, providerId: pId, serviceId: id, serviceName: name, mergePriority: mp, connectorSettings: connectorSettings, baseDNPerDomainString: bdnDic, peopleDNString: pdnString)
	}
	
}

#endif
