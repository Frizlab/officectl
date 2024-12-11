/*
 * WeakeningMode.swift
 * OfficeServer
 *
 * Created by François Lamboley on 2023/01/19.
 */

import Foundation

import SafeGlobal



/**
 The weakening mode for an Action.
 
 When the `TimeInterval` is `nil`, the action is weakened before the handler is called,
  otherwise whatever the time interval value, the weakening is done asynchronously after the handler is called, on an internal queue. */
public enum WeakeningMode : Sendable {
	
	case never
	case onError(delay: TimeInterval?)
	case onSuccess(delay: TimeInterval?)
	case always(successDelay: TimeInterval?, errorDelay: TimeInterval?)
	
	public static let alwaysInstantly = WeakeningMode.always(successDelay: nil, errorDelay: nil)
	
	/** Customizable default, used by Action, when running it. */
	@SafeGlobal public static var defaultMode = WeakeningMode.alwaysInstantly
	
}
