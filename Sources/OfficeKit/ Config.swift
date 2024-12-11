/*
 *  Config.swift
 * OfficeKit
 *
 * Created by François Lamboley on 2022/10/03.
 */

import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	struct OfficeKit {}
	var officeKit: OfficeKit {OfficeKit()}
}


extension ConfKeys.OfficeKit {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "me.frizlab.officekit"))
	
}


extension Conf {
	
	#declareConfAccessor(\.officeKit.logger, Logging.Logger?.self)
	
}
