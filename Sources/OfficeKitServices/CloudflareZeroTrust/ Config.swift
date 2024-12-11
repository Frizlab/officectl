/*
 *  Config.swift
 * CloudflareZeroTrustOffice
 *
 * Created by François Lamboley on 2023/07/27.
 */

import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	struct CloudflareZeroTrustOffice {}
	var cloudflareZeroTrustOffice: CloudflareZeroTrustOffice {CloudflareZeroTrustOffice()}
}


extension ConfKeys.CloudflareZeroTrustOffice {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "me.frizlab.officekit-services.cloudflare-zerotrust"))
	
}


extension Conf {
	
	#declareConfAccessor(\.cloudflareZeroTrustOffice.logger, Logging.Logger?.self)
	
}
