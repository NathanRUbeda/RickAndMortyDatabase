//
//  WebServiceDecodable.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// An object that decodes data for the web service.
protocol WebServiceDecodable {
	/// Decodes data received from request.
	func decode<T: Decodable>(_ data: Data) throws -> T
}

extension WebServiceDecodable {
	func decode<T: Decodable>(_ data: Data) throws -> T {
		let decoder = JSONDecoder()
		return try decoder.decode(T.self, from: data)
	}
}
