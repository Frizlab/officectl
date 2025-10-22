/*
 * configure.swift
 * officectl-odproxy
 *
 * Created by François Lamboley on 2019/07/10.
 */

import Foundation

import GlobalConfModule
import RetryingOperation
import SemiSingleton
import TOMLDecoder
import UnwrapOrThrow
import URLRequestOperation
import Vapor
import XDG

import OfficeKit
import OpenDirectoryOffice



func configure(_ app: Application, forcedConfigPath: String?, verbose: Bool) throws {
	Conf[rootValueFor: \.semiSingleton.oslog] = nil
	Conf[rootValueFor: \.semiSingleton.logger] = app.logger
	Conf[rootValueFor: \.retryingOperation.oslog] = nil
	Conf[rootValueFor: \.retryingOperation.logger] = app.logger
	Conf[rootValueFor: \.urlRequestOperation.oslog] = nil
	Conf[rootValueFor: \.urlRequestOperation.logger] = app.logger
	
	let dirs = try BaseDirectories(prefixAll: "officectl-odproxy", runtimeDirHandling: .skipSetup)
	let configPath = try forcedConfigPath ?? dirs.findConfigFile("config.toml")?.string ?! MessageError(message: "Cannot find file config file path.")
	let config = try TOMLDecoder().decode(AppConfig.self, from: Data(contentsOf: URL(fileURLWithPath: configPath)))
	
	/* Set hostname and port from server conf. */
	switch (config.serverConfig.hostname, config.serverConfig.port) {
		case (let hostname?, let port?): app.http.server.configuration.hostname = hostname; app.http.server.configuration.port = port
		case (let hostname?, nil):       app.http.server.configuration.hostname = hostname
		case (nil,           let port?): app.http.server.configuration.port = port
		case (nil,           nil):       (/*nop*/)
	}
	
	/* Setup the controllers and routes. */
	let odService = OpenDirectoryService(
		id: "_internal_od_",
		name: "Open Directory for officectl-odproxy",
		openDirectoryServiceConfig: OpenDirectoryServiceConfig(
			connectorSettings: config.openDirectoryConfig,
			userIDBuilders: nil
		)
	)
	try configureRoutes(app, config.serverConfig, odService)
}
