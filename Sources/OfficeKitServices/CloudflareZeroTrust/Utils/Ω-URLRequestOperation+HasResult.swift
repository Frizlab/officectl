/*
 * URLRequestOperation+HasResult.swift
 * Office365Office
 *
 * Created by François Lamboley on 2023/07/31.
 */

import Foundation

import HasResult
import OperationAwaiting
import URLRequestOperation



extension URLRequestDataOperation     : @retroactive HasResult, @retroactive SendableOperation {}
extension URLRequestDownloadOperation : @retroactive HasResult, @retroactive SendableOperation {}
