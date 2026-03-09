//
//  CharacterWebService.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// A web service for handling networking for the Character object.
class CharacterWebService: WebService, CharacterProvider {
	/// Sends request to get Characters.
	/// - Parameters:
	/// - page: The page of the API request.
	/// - name: An optional name to filter characters by.
	/// - status: An optional status to filter characters by.
	/// - Returns: A `CharacterResponse` containing characters and pagination info.
	/// - Throws: A `NetworkError` if unable to build request or encountered during processing of request.
	func fetchCharacters(page: Int, name: String?, status: String?) async throws -> CharacterResponse {
		var queries = [URLQueryItem(name: "page", value: String(page))]

		if let name, !name.isEmpty {
			queries.append(URLQueryItem(name: "name", value: name))
		}

		if let status {
			queries.append(URLQueryItem(name: "status", value: status))
		}

		return try await self.dispatch(
			using: WebServiceRequest(
				httpMethod: "GET",
				endpoint: "character",
				headers: nil,
				queries: queries
			)
		)
	}
}
