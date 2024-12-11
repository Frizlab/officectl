/*
 * ApiContentConformance.swift
 * OfficeServer
 *
 * Created by François Lamboley on 2023/01/19.
 */

import Foundation

import Vapor

import OfficeModel



extension ApiService              : @retroactive Content {}
extension ApiMultiServicesResults : @retroactive Content {}
