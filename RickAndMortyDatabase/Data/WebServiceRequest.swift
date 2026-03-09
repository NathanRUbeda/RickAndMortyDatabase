//
//  WebServiceRequest.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// An object that represents a web service request.
struct WebServiceRequest {
	/// The HTTP method to use for the request (e.g. "GET", "POST").
	let httpMethod: String

	/// The endpoint path appended to the base URL.
	let endpoint: String

	/// Optional HTTP headers to include in the request.
	let headers: [String: Any]?

	/// Optional URL query items to append to the request URL.
	let queries: [URLQueryItem]?
}
