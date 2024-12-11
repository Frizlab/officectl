/*
 *  Config.swift
 * HappnOffice
 *
 * Created by François Lamboley on 2022/11/15.
 */

import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	struct HappnOffice {}
	var happnOffice: HappnOffice {HappnOffice()}
}


extension ConfKeys.HappnOffice {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "me.frizlab.officekit-services.happn"))
	
}


extension Conf {
	
	#declareConfAccessor(\.happnOffice.logger, Logging.Logger?.self)
	
}
