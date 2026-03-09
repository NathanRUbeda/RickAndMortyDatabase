//
//  DisplayableCharacter.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// A protocol to represent a character that can be generically displayed.
protocol DisplayableCharacter {
	/// The ID of the character.
	var id: Int { get }
	
	/// The name of the character.
	var name: String { get }
	
	/// The status of the character.
	var status: String { get }
	
	/// The species of the character.
	var species: String { get }
	
	/// The gender of the character.
	var gender: String { get }
	
	/// The origin of the character.
	var origin: Location { get }
	
	/// The current location of the character.
	var location: Location { get }
	
	/// The amount of episodes the character is in.
	var episode: [String] { get }
	
	/// The image URL of the character.
	var image: String { get }
}
