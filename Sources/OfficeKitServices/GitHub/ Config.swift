/*
 *  Config.swift
 * GitHubOffice
 *
 * Created by François Lamboley on 2022/12/28.
 */

import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	struct GitHubOffice {}
	var gitHubOffice: GitHubOffice {GitHubOffice()}
}


extension ConfKeys.GitHubOffice {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "me.frizlab.officekit-services.github"))
	
}


extension Conf {
	
	#declareConfAccessor(\.gitHubOffice.logger, Logging.Logger?.self)
	
}
