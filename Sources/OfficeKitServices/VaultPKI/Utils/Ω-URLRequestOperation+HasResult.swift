/*
 * URLRequestOperation+HasResult.swift
 * VaultPKIOffice
 *
 * Created by François Lamboley on 2022/11/17.
 */

import Foundation

import HasResult
import OperationAwaiting
import URLRequestOperation



extension URLRequestDataOperation     : @retroactive HasResult, @retroactive SendableOperation {}
extension URLRequestDownloadOperation : @retroactive HasResult, @retroactive SendableOperation {}
