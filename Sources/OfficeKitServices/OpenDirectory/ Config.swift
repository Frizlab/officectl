/*
 *  Config.swift
 * OpenDirectoryOffice
 *
 * Created by François Lamboley on 2023/01/02.
 */

import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	struct OpenDirectoryOffice {}
	var openDirectoryOffice: OpenDirectoryOffice {OpenDirectoryOffice()}
}


extension ConfKeys.OpenDirectoryOffice {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "me.frizlab.officekit-services.open-directory"))
	
}


extension Conf {
	
	#declareConfAccessor(\.openDirectoryOffice.logger, Logging.Logger?.self)
	
}
