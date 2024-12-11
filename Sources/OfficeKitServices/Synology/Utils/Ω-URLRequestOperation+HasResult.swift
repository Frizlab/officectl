/*
 * URLRequestOperation+HasResult.swift
 * SynologyOffice
 *
 * Created by François Lamboley on 2023/06/06.
 */

import Foundation

import HasResult
import OperationAwaiting
import URLRequestOperation



extension URLRequestDataOperation     : @retroactive HasResult, @retroactive SendableOperation {}
extension URLRequestDownloadOperation : @retroactive HasResult, @retroactive SendableOperation {}
