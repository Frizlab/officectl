/*
 *  Config.swift
 * GoogleOffice
 *
 * Created by François Lamboley on 2022/11/15.
 */

import Foundation

import GlobalConfModule
import Logging
import UnwrapOrThrow



public extension ConfKeys {
	struct GoogleOffice {}
	var googleOffice: GoogleOffice {GoogleOffice()}
}


extension ConfKeys.GoogleOffice {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "me.frizlab.officekit-services.google"))
	#declareConfKey("dateDecodingStrategy", JSONDecoder.DateDecodingStrategy.self, defaultValue: {
		return .custom{ decoder in
			let container = try decoder.singleValueContainer()
			let str = try container.decode(String.self)
			let formatter = ISO8601DateFormatter()
			formatter.formatOptions = formatter.formatOptions.union(.withFractionalSeconds)
			return try formatter.date(from: str) ?! DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(str)")
		}
	}())
	
}


extension Conf {
	
	#declareConfAccessor(\.googleOffice.logger,               Logging.Logger?                 .self)
	#declareConfAccessor(\.googleOffice.dateDecodingStrategy, JSONDecoder.DateDecodingStrategy.self)
	
}
