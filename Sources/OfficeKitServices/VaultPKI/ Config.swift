/*
 *  Config.swift
 * VaultPKIOffice
 *
 * Created by François Lamboley on 2023/01/25.
 */

import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	struct VaultPKIOffice {}
	var vaultPKIOffice: VaultPKIOffice {VaultPKIOffice()}
}


extension ConfKeys.VaultPKIOffice {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "me.frizlab.officekit-services.vault-pki"))
	
}


extension Conf {
	
	#declareConfAccessor(\.vaultPKIOffice.logger, Logging.Logger?.self)
	
}
