/*
 *  Config.swift
 * OfficeKitOffice
 *
 * Created by François Lamboley on 2023/01/09.
 */

import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	struct OfficeKitOffice {}
	var officeKitOffice: OfficeKitOffice {OfficeKitOffice()}
}


extension ConfKeys.OfficeKitOffice {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "me.frizlab.officekit-services.officekit"))
	
}


extension Conf {
	
	#declareConfAccessor(\.officeKitOffice.logger, Logging.Logger?.self)
	
}
