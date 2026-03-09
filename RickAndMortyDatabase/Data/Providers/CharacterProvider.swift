//
//  CharacterProvider.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// An object that provides Characters.
protocol CharacterProvider {
	/// Sends request to get Characters.
	/// - Parameters:
	/// - page: The page of the API request.
	/// - name: An optional name to filter characters by.
	/// - status: An optional status to filter characters by.
	/// - Returns: A `CharacterResponse` containing characters and pagination info.
	/// - Throws: A `NetworkError` if unable to build request or encountered during processing of request.
	func fetchCharacters(page: Int, name: String?, status: String?) async throws -> CharacterResponse
}
