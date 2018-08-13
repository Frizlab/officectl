/*
 * CloneGitHubRepoOperation.swift
 * officectl
 *
 * Created by François Lamboley on 27/06/2018.
 */

import Foundation

import RetryingOperation



public class CloneGitHubRepoOperation : RetryingOperation {
	
	public let repoName: String
	public let repoCloneURL: String
	public let destinationURL: URL
	
	/** Clone error. Only makes sense when the operation is finished. */
	public private(set) var cloneError: Error?
	
	public convenience init(in containerURL: URL, repoFullName name: String, accessToken: String) {
		let url = URL(fileURLWithPath: name.trimmingCharacters(in: CharacterSet(charactersIn: "/")), isDirectory: true, relativeTo: containerURL).appendingPathExtension("git")
		self.init(destinationURL: url, repoFullName: name, accessToken: accessToken)
	}
	
	public init(destinationURL u: URL, repoFullName: String, accessToken: String) {
		repoName = repoFullName
		repoCloneURL = "https://x-access-token:\(accessToken)@github.com/\(repoFullName).git"
		destinationURL = u
	}
	
	public override var isAsynchronous: Bool {
		return false
	}
	
	public override func startBaseOperation(isRetry: Bool) {
		defer {baseOperationEnded()}
		
		var isDir = ObjCBool(booleanLiteral: false)
		let destinationExists = FileManager.default.fileExists(atPath: destinationURL.path, isDirectory: &isDir)
		guard !destinationExists || isDir.boolValue else {
			cloneError = NSError(domain: "com.happn.officectl", code: 1, userInfo: [NSLocalizedDescriptionKey: "Destination \(destinationURL.path) exists and is a file. Cannot use for cloning repository \(repoName)."])
			baseOperationEnded()
			return
		}
		
		let process = Process()
		#if !os(Linux)
			process.standardInput = FileHandle.nullDevice
			process.standardError = FileHandle.nullDevice /* TODO: Retrieve stderr to have more context when git fails... */
			process.standardOutput = FileHandle.nullDevice
		#endif
		
		process.launchPath = "/usr/bin/git"
		if !destinationExists {
			process.arguments = ["clone", "--quiet", "--mirror", repoCloneURL, destinationURL.path]
		} else {
			/* The repository already exists. We must modify the config to update
			 * the remote for the URL. We could modify the config file directly,
			 * but let's do things properly and call git for that. */
			let updateRemoteProcess = Process()
			#if !os(Linux)
				updateRemoteProcess.standardInput = FileHandle.nullDevice
				updateRemoteProcess.standardError = FileHandle.nullDevice /* TODO: Retrieve stderr to have more context when git fails... */
				updateRemoteProcess.standardOutput = FileHandle.nullDevice
			#endif
			updateRemoteProcess.launchPath = process.launchPath
			updateRemoteProcess.arguments = ["-C", destinationURL.path, "remote", "set-url", "origin", repoCloneURL]
			updateRemoteProcess.launch()
			updateRemoteProcess.waitUntilExit()
			guard updateRemoteProcess.terminationStatus == 0 else {
				cloneError = NSError(domain: "com.happn.officectl", code: 1, userInfo: [NSLocalizedDescriptionKey: "git exited with code \(updateRemoteProcess.terminationStatus) when updating the remote for repository \(repoName)"])
				return
			}
			
			process.arguments = ["-C", destinationURL.path, "remote", "update", "--prune"]
		}
		
		process.launch()
		process.waitUntilExit()
		
		guard process.terminationStatus == 0 else {
			cloneError = NSError(domain: "com.happn.officectl", code: 1, userInfo: [NSLocalizedDescriptionKey: "git exited with code \(process.terminationStatus) for repository \(repoName)"])
			return
		}
	}
	
}
