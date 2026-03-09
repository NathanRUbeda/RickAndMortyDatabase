//
//  WebServiceFactory.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// An object to vend web services.
class WebServiceFactory {
	/// The dispatcher to use for networking.
	var dispatcher: WebServiceDispatcher!
	
	/// A shared instance of the factory to vend web services.
	static let shared = WebServiceFactory()
	
	/// A method that returns a CharacterProvider.
	/// - Returns: A `CharacterProvider` object.
	func characterProvider() -> CharacterProvider {
		CharacterWebService(dispatcher: self.dispatcher)
	}
	
	/// A method that returns a CharacterDetailProvider.
	/// - Returns: A `CharacterDetailProvider` object.
	func characterDetailProvider() -> CharacterDetailProvider {
		CharacterDetailWebService(dispatcher: self.dispatcher)
	}
}
