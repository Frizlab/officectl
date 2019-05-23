/*
 * OfficeKitConfig+CLIUtils.swift
 * OfficeKit
 *
 * Created by François Lamboley on 11/01/2019.
 */

import Foundation

import Guaka
import Vapor
import Yaml

import OfficeKit



extension OfficeKitConfig : Service {
	
	init(flags f: Flags, yamlConfig: Yaml) throws {
		let domainAliases = (try? OfficectlConfig.stringStringDicFrom(yamlConfig: yamlConfig, yamlName: "domain_aliases")) ?? [:]
		
		#if canImport(DirectoryService) && canImport(OpenDirectory)
		self.init(
			domainAliases: domainAliases,
			ldapConfig: try LDAPConfig(flags: f, yamlConfig: yamlConfig),
			googleConfig: try GoogleConfig(flags: f, yamlConfig: yamlConfig),
			gitHubConfig: try GitHubConfig(flags: f, yamlConfig: yamlConfig),
			openDirectoryConfig: try OpenDirectoryConfig(flags: f, yamlConfig: yamlConfig)
		)
		#else
		self.init(
			domainAliases: domainAliases,
			ldapConfig: try LDAPConfig(flags: f, yamlConfig: yamlConfig),
			googleConfig: try GoogleConfig(flags: f, yamlConfig: yamlConfig),
			gitHubConfig: try GitHubConfig(flags: f, yamlConfig: yamlConfig)
		)
		#endif
	}
	
}