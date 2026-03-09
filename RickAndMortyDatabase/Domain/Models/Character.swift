//
//  Character.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// A character from the Rick and Morty universe.
struct Character: Codable, Identifiable, DisplayableCharacter {
	/// The unique identifier of the character.
	let id: Int

	/// The name of the character.
	let name: String

	/// The status of the character (e.g. Alive, Dead, unknown).
	let status: String

	/// The species of the character.
	let species: String

	/// The type or subspecies of the character.
	let type: String

	/// The gender of the character.
	let gender: String

	/// The origin location of the character.
	let origin: Location

	/// The last known location of the character.
	let location: Location

	/// The URL of the character's image.
	let image: String

	/// A list of episode URLs the character appeared in.
	let episode: [String]

	/// The URL of the character's own endpoint.
	let url: String

	/// The date the character was created in the database.
	let created: String
}
