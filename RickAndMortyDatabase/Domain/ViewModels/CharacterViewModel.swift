//
//  CharacterViewModel.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation
import SwiftUI

/// An object that is used to model data with a view.
@Observable
class CharacterViewModel {
	/// Checks if viewModel is done fetching or not.
	var isFetching = false
	
	/// Array of Characters.
	var characters = [Character]()
	
	/// An object that interacts with a cloud service to get Characters.
	var webService: CharacterProvider?
	
	/// The current page of the API's request.
	var currentPage: Int = 1

	/// The total number of pages available from the API.
	var totalPages: Int?

	/// The current search query for filtering by name.
	var searchText: String = "" {
		didSet {
			self.debounceSearchTask?.cancel()
			if self.characters.isEmpty {
				self.isFetching = true
			}
			self.debounceSearchTask = Task { @MainActor in
				try? await Task.sleep(for: .milliseconds(300))
				guard !Task.isCancelled else { return }
				await self.performFilteredSearch()
			}
		}
	}

	/// The currently selected status filter.
	var selectedStatus: StatusFilter = .all {
		didSet {
			guard oldValue != selectedStatus else { return }
			Task { @MainActor in
				await self.performFilteredSearch()
			}
		}
	}

	/// The debounce task for search input.
	private var debounceSearchTask: Task<Void, Never>?

	/// Whether or not the view model has been fully loaded.
	var isLoaded = false
	
	/// Whether or not to display an alert to the user.
	var displayErrorAlert = false
	
	/// The title for the alert.
	var alertTitle: LocalizedStringKey?
	
	/// The message for the alert to present to the user.
	var alertMessage: String?
	
	init(
		webService: CharacterProvider,
	) {
		self.webService = webService
	}
	
	/// Refresh the view model by resetting the characters from the web service.
	/// - Throws: A `NetworkError` if unable to build request or encountered during processing of request.
	@MainActor func refresh() async {
		self.currentPage = 1
		let page = self.currentPage
		do {
			let characters = try await self.fetchCharacters(for: page)
			self.characters = characters
		} catch {
			self.alertTitle = "Unable to get characters"
			self.alertMessage = error.localizedDescription
			self.displayErrorAlert = true
		}
	}
	
	/// Fetches the next batch of Characters according to the given page.
	/// - Parameters:
	/// - page: The current page for the API request.
	/// - Throws: A `NetworkError` if unable to build request or encountered during processing of request.
	@MainActor func fetchNextCharacters(for page: Int? = nil) async throws {
		guard !self.isFetching else { return }
		self.isFetching = true
		let page = page ?? self.currentPage
		if let totalPages, page > totalPages {
			self.isFetching = false
			return
		}

		while true {
			do {
				let characters = try await fetchCharacters(for: page)
				self.currentPage = page
				self.characters.appendContentsNotAlreadyContained(contentsOf: characters)
				return
			} catch NetworkError.badStatusCode(429) {
				self.isFetching = true
				try? await Task.sleep(for: .milliseconds(500))
				continue
			}
		}
	}
	
	/// Resets pagination to page 1 and fetches characters matching the current search text and status filter.
	@MainActor func performFilteredSearch() async {
		self.currentPage = 1
		self.totalPages = nil

		while true {
			do {
				let characters = try await self.fetchCharacters(for: 1)
				self.characters = characters
				return
			} catch NetworkError.badStatusCode(429) {
				try? await Task.sleep(for: .milliseconds(500))
				continue
			} catch {
				// API returns 404 when no characters match — treat as empty results, not an error.
				self.characters = []
				return
			}
		}
	}

	/// Fetches Characters for the given page.
	/// - Parameters:
	/// - page: The current page for the API request.
	/// - Returns: An array of `Character` objects.
	/// - Throws: A `NetworkError` if unable to build request or encountered during processing of request.
	private func fetchCharacters(for page: Int) async throws -> [Character] {
		defer {
			self.isFetching = false
		}

		self.isFetching = true

		guard let webService else {
			throw NetworkError.unableToDispatch()
		}

		let nameParam = self.searchText.isEmpty ? nil : self.searchText
		let statusParam = self.selectedStatus.queryValue

		let response = try await webService.fetchCharacters(
			page: page,
			name: nameParam,
			status: statusParam
		)
		self.totalPages = response.info.pages
		return response.results
	}
	
	/// Fetches Characters for initial list.
	func fetchInitialCharacters() async {
		await self.refresh()
		self.isLoaded = true
	}
}
