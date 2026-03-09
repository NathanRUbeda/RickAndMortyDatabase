//
//  Info.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// Pagination metadata returned by the API.
struct Info: Codable {
	/// The total number of characters matching the query.
	let count: Int

	/// The total number of pages available.
	let pages: Int

	/// The URL of the next page, or `nil` if on the last page.
	let next: String?

	/// The URL of the previous page, or `nil` if on the first page.
	let prev: String?
}
