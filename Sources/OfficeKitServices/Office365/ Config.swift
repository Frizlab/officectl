/*
 *  Config.swift
 * Office365Office
 *
 * Created by François Lamboley on 2023/01/25.
 */

import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	struct Office365Office {}
	var office365Office: Office365Office {Office365Office()}
}


extension ConfKeys.Office365Office {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "me.frizlab.officekit-services.office365"))
	
}


extension Conf {
	
	#declareConfAccessor(\.office365Office.logger, Logging.Logger?.self)
	
}
