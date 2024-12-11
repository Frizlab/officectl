/*
 *  Config.swift
 * SynologyOffice
 *
 * Created by François Lamboley on 2023/06/06.
 */

import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	struct SynologyOffice {}
	var synologyOffice: SynologyOffice {SynologyOffice()}
}


extension ConfKeys.SynologyOffice {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "me.frizlab.officekit-services.synology"))
	
}


extension Conf {
	
	#declareConfAccessor(\.synologyOffice.logger, Logging.Logger?.self)
	
}
