//
//  CharacterDetailViewModel.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// An object that is used to model data with a Character detail view.
@Observable
final class CharacterDetailViewModel {
	/// ID of the character.
	var id: String
	
	/// Name of the character
	var name: String?
	
	/// The status of the character.
	var status: String?
	
	/// The species of the character.
	var species: String?
	
	/// The gender of the character.
	var gender: String?
	
	/// The origin of the character.
	var origin: Location?
	
	/// The current location of the character.
	var location: Location?
	
	/// The URL of the character's image.
	var image: String?
	
	/// The amount of episodes the character is in.
	var episodeCount: Int?
	
	/// An object that is used to build the view model.
	private(set) var serviceObject: Character?
	
	/// An object that interacts with a cloud service.
	var webService: CharacterDetailProvider?
	
	/// Whether or not the detail view model has been fully loaded.
	var isLoaded = false
	
	/// Whether or not to display an alert to the user.
	var displayErrorAlert = false
	
	/// The message for the alert to present to the user.
	var alertMessage: String?
	
	/// Designated initializer.
	/// - Parameters:
	/// - id: The id of the Character.
	/// - webService: The Character detail provider to use for fetching detail data.
	init(
		for id: String,
		using webService: CharacterDetailProvider? = WebServiceFactory.shared.characterDetailProvider()
	) {
		self.id = id
		self.webService = webService
	}
	
	/// Instantiate a new view model from the given response object. If the reponse is `nil`, the initializer fails.
	init?(from response: Character?) {
		guard let response else {
			return nil
		}
		
		self.serviceObject = response
		self.id = String(response.id)
		self.webService = WebServiceFactory.shared.characterDetailProvider()
		if let serviceObject {
			self._update(from: serviceObject)
			self.isLoaded = true
		}
	}
	
	/// Instantiate a new view model from the given character.
	init(from character: Character) {
		self.id = String(character.id)
		self.name = character.name
		self.status = character.status
		self.species = character.species
		self.gender = character.gender
		self.origin = character.origin
		self.location = character.location
		self.image = character.image
		self.episodeCount = character.episode.count
	}
	
	/// Refreshes data by calling the network again.
	@MainActor func refresh() async {
		await self.fetchCharacter(id: self.id)
	}
	
	/// Fetches a Character based on its id, silently retrying on 429 (Too Many Requests).
	private func fetchCharacter(id: String) async {
		do {
			let response = try await self.webService?.fetchSingleCharacter(id: id)
			self.serviceObject = response
			if let serviceObject {
				self._update(from: serviceObject)
				self.isLoaded = true
			}
		} catch NetworkError.badStatusCode(429) {
			try? await Task.sleep(for: .milliseconds(500))
			await self.fetchCharacter(id: id)
		} catch {
			self.alertMessage = error.localizedDescription
			self.displayErrorAlert = true
		}
	}
	
	/// Updates the values of the object.
	/// - Parameters:
	/// - serviceObject: An object that is used to build the view model.
	private func _update(from serviceObject: Character) {
		self.id = String(serviceObject.id)
		self.name = serviceObject.name
		self.status = serviceObject.status
		self.species = serviceObject.species
		self.origin = serviceObject.origin
		self.gender = serviceObject.gender
		self.location = serviceObject.location
		self.image = serviceObject.image
		self.episodeCount = serviceObject.episode.count
	}
}
