/*
 * guaka_config.swift
 * officectl
 *
 * Created by François Lamboley on 07/08/2018.
 */

import Foundation

import Guaka
import OfficeKit
import Vapor



struct GuakaCommandParseResult {
	
	let officectlConfig: OfficectlConfig
	let wrapperCommand: VaporWrapperForGuakaCommand
	
}


func parse_cli() -> GuakaCommandParseResult {
	var result: GuakaCommandParseResult?
	let createSetWrapperCommandHandler = { (run: @escaping VaporWrapperForGuakaCommand.Run) -> (_ cmd: Guaka.Command, _ flags: Guaka.Flags, _ args: [String]) -> Void in
		return { (_ cmd: Guaka.Command, _ flags: Guaka.Flags, _ args: [String]) -> Void in
			let officectlConfig: OfficectlConfig
			do    {officectlConfig = try OfficectlConfig(flags: flags)}
			catch {cmd.fail(statusCode: (error as NSError).code, errorMessage: error.legibleLocalizedDescription)}
			
			result = GuakaCommandParseResult(
				officectlConfig: officectlConfig,
				wrapperCommand: VaporWrapperForGuakaCommand(guakaCommand: cmd, guakaFlags: flags, guakaArgs: args, run: run)
			)
		}
	}
	
	/* ******************
	   MARK: root command
	   ****************** */
	
	let rootFlags = [
		Flag(shortName: "v", longName: "verbose", value: false,      description: "Asks to be more verbose.", inheritable: true),
		
		Flag(longName: "config-file", type: String.self, description: "The path to an officectl config file. Defaults to ~/.config/officectl/officectl.yaml and then /etc/officectl/officectl.yaml.", inheritable: true),
		
		Flag(longName: "static-data-dir", type: String.self, description: "The path to the data dir (containing the static resources for officectl).", inheritable: true),
		Flag(longName: "jwt-secret",      type: String.self, description: "The secret to use for generating the JWT tokens.",                          inheritable: true),
	]
	
	let rootCommand = Command(usage: "officectl", flags: rootFlags, run: createSetWrapperCommandHandler(root))
	
	
	/* ***********************
	   MARK: root sub-commands
	   *********************** */
	
	let getTokenFlags = [
		Flag(longName: "scopes",     type: String.self, description: "A comma-separated list of scopes.",                       required: false),
		Flag(longName: "service-id", type: String.self, description: "The id of the service from which to retrieve the token.", required: true)
	]
	
	let backupFlags = [
		Flag(longName: "destination", type: String.self, description: "The enclosing folder destination for the backup.", required: true, inheritable: true)
	]
	
	let syncFlags = [
		Flag(longName: "from", type: String.self, description: "The source service from which to sync the directories from.", required: true),
		Flag(longName: "to",   type: String.self, description: "The services to which the directory will be synchronized to. This is a comma-separated list.", required: true)
	]
	
	let devtestCommand = Command(usage: "devtest",    flags: [],            parent: rootCommand, run: createSetWrapperCommandHandler(devTest))
	let _              = Command(usage: "get-token",  flags: getTokenFlags, parent: rootCommand, run: createSetWrapperCommandHandler(getToken))
	let _              = Command(usage: "list-users", flags: [],            parent: rootCommand, run: createSetWrapperCommandHandler(listUsers))
	let backupCommand  = Command(usage: "backup",     flags: backupFlags,   parent: rootCommand, run: createSetWrapperCommandHandler(backup))
	let _              = Command(usage: "sync",       flags: syncFlags,     parent: rootCommand, run: createSetWrapperCommandHandler(sync))
	let serverCommand  = Command(usage: "server",     flags: [],            parent: rootCommand, run: createSetWrapperCommandHandler(server))
	
	
	/* *************************
	   MARK: backup sub-commands
	   ************************* */
	
	let backupMailsFlags = [
		Flag(longName: "emails-to-backup",            type: String.self, description: "A comma-separated list of emails to backup. If an email is not in the directory, it is skipped. If not specified, all emails are backed up.", required: false),
		Flag(longName: "offlineimap-config-file",     type: String.self, description: "The path to the config file to use (WILL BE OVERWRITTEN) for offlineimap.", required: true),
		Flag(longName: "max-concurrent-account-sync", type: Int.self,    description: "The maximum number of concurrent sync that will be done by offlineimap.", required: false),
		Flag(longName: "offlineimap-output",          type: String.self, description: "A path to a file in which the offlineimap output will be written.", required: false),
		Flag(longName: "linkify",                     value: false,      description: "Whether to “linkify” the backups. Linkifying consists in scanning the backup for duplicate files and de-duplicating the files by replacing the duplicate with a hard link."),
		Flag(longName: "archive",                     value: false,      description: "Whether to archive the backup (create a tar bz2 file and remove the directory).")
	]
	
	let backupGitHubFlags = [
		Flag(longName: "orgname",    type: String.self, description: "The organisation name from which to backup the repositories from.", required: true),
		Flag(longName: "service-id", type: String.self, description: "The id of the GitHub service to use to do the backup. Required if there are more than one GitHub service in officectl conf, otherwise the only GitHub service is used.", required: false)
	]
	
	let _ = Command(usage: "mails",  flags: backupMailsFlags,  parent: backupCommand, run: createSetWrapperCommandHandler(backupMails))
	let _ = Command(usage: "github", flags: backupGitHubFlags, parent: backupCommand, run: createSetWrapperCommandHandler(backupGitHub))
	
	
	/* *************************
	   MARK: server sub-commands
	   ************************* */
	
	let serverServeFlags = [
		Flag(shortName: "H", longName: "hostname", type: String.self, description: "Set the hostname the server will run on. Defaults to localhost."),
		Flag(shortName: "p", longName: "port",     type: Int.self,    description: "Set the port the server will run on. Defaults to 8080.")
//		Flag(shortName: "b", longName: "bind",     type: String.self, description: "Convenience for setting hostname and port together. The hostname and port options have precedence over this option.", required: false)
	]
	
	let _ = Command(usage: "serve",  flags: serverServeFlags, parent: serverCommand, run: createSetWrapperCommandHandler(serverServe))
	let _ = Command(usage: "routes", flags: [],               parent: serverCommand, run: createSetWrapperCommandHandler(serverRoutes))
	
	
	/* **************************
	   MARK: devtest sub-commands
	   ************************** */
	
	let _ = Command(usage: "curtest", flags: [], parent: devtestCommand, run: createSetWrapperCommandHandler(curTest))
	
	
	
	rootCommand.execute()
	guard let resultNonOptional = result else {rootCommand.fail(statusCode: 1)}
	return resultNonOptional
}
