//
//  CharacterDetailWebService.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// A web service for handling detail networking operations.
class CharacterDetailWebService: WebService, CharacterDetailProvider {
	/// Sends request to get Character based on its id.
	/// - Parameters:
	/// - id: The id of the Character.
	/// - Returns: A `Character` object.
	/// - Throws: A `NetworkError` if unable to build request or encountered during processing of request.
	func fetchSingleCharacter(id: String) async throws -> Character {
		try await self.dispatch(
			using: WebServiceRequest(
				httpMethod: "GET",
				endpoint: "character/\(id)",
				headers: nil,
				queries: nil
			)
		)
	}
}
