//
//  StatusFilter.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// Represents the available status filter options for the Rick and Morty API.
enum StatusFilter: String, CaseIterable, Identifiable {
	case all
	case alive
	case dead
	case unknown

	var id: String { self.rawValue }

	/// The display name shown in the UI filter buttons.
	var displayName: String {
		switch self {
		case .all: return "ALL"
		case .alive: return "ALIVE"
		case .dead: return "DEAD"
		case .unknown: return "UNKNOWN"
		}
	}

	/// The query parameter value to send to the API.
	/// Returns `nil` for `.all` since the API should not receive a status param when no filter is active.
	var queryValue: String? {
		switch self {
		case .all: return nil
		case .alive: return "alive"
		case .dead: return "dead"
		case .unknown: return "unknown"
		}
	}
}
