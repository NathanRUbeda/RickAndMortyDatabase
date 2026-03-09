//
//  CharacterDetailProvider.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// An object that provides Character detail data.
protocol CharacterDetailProvider {
	/// Sends request to get a single Character based on its id.
	/// - Parameters:
	/// - id: The id of the Character.
	/// - Returns: A `Character` object.
	/// - Throws: A `NetworkError` if unable to build request or encountered during processing of request.
	func fetchSingleCharacter(id: String) async throws -> Character
}
