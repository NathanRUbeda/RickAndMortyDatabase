//
//  RickAndMortyDatabaseTests.swift
//  RickAndMortyDatabaseTests
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import XCTest
@testable import RickAndMortyDatabase

// MARK: - Mock CharacterProvider

/// A mock implementation of `CharacterProvider` that returns pre-configured responses
/// or throws pre-configured errors, without hitting the real network.
final class MockCharacterProvider: CharacterProvider {
	var fetchResult: Result<CharacterResponse, Error> = .success(
		CharacterResponse(
			info: Info(count: 0, pages: 1, next: nil, prev: nil),
			results: []
		)
	)

	/// Tracks the parameters of each call to `fetchCharacters`.
	var fetchCallHistory: [(page: Int, name: String?, status: String?)] = []

	func fetchCharacters(page: Int, name: String?, status: String?) async throws -> CharacterResponse {
		self.fetchCallHistory.append((page: page, name: name, status: status))
		return try self.fetchResult.get()
	}
}

// MARK: - Test Helpers

extension RickAndMortyDatabaseTests {
	/// Creates a sample `Character` with the given id and name.
	static func makeCharacter(id: Int = 1, name: String = "Rick Sanchez", status: String = "Alive") -> Character {
		Character(
			id: id,
			name: name,
			status: status,
			species: "Human",
			type: "",
			gender: "Male",
			origin: Location(name: "Earth (C-137)", url: ""),
			location: Location(name: "Citadel of Ricks", url: ""),
			image: "https://rickandmortyapi.com/api/character/avatar/\(id).jpeg",
			episode: ["https://rickandmortyapi.com/api/episode/1"],
			url: "",
			created: ""
		)
	}

	/// Creates a `CharacterResponse` with the given characters and page info.
	static func makeResponse(
		characters: [Character],
		pages: Int = 1,
		next: String? = nil
	) -> CharacterResponse {
		CharacterResponse(
			info: Info(count: characters.count, pages: pages, next: next, prev: nil),
			results: characters
		)
	}
}

// MARK: - ViewModel Behavior Tests

final class RickAndMortyDatabaseTests: XCTestCase {
	private var mockProvider: MockCharacterProvider!
	private var viewModel: CharacterViewModel!

	@MainActor
	override func setUp() {
		super.setUp()
		self.mockProvider = MockCharacterProvider()
		self.viewModel = CharacterViewModel(webService: self.mockProvider)
	}

	override func tearDown() {
		self.mockProvider = nil
		self.viewModel = nil
		super.tearDown()
	}

	// MARK: - Refresh & Initial Load

	/// Tests that `refresh()` fetches page 1 and populates the characters array.
	@MainActor
	func testRefreshFetchesPageOneAndPopulatesCharacters() async {
		let characters = [
			Self.makeCharacter(id: 1, name: "Rick Sanchez"),
			Self.makeCharacter(id: 2, name: "Morty Smith")
		]
		self.mockProvider.fetchResult = .success(Self.makeResponse(characters: characters, pages: 3))

		await self.viewModel.refresh()

		XCTAssertEqual(self.viewModel.characters.count, 2)
		XCTAssertEqual(self.viewModel.characters[0].name, "Rick Sanchez")
		XCTAssertEqual(self.viewModel.characters[1].name, "Morty Smith")
		XCTAssertEqual(self.viewModel.currentPage, 1)
		XCTAssertEqual(self.viewModel.totalPages, 3)
		XCTAssertFalse(self.viewModel.isFetching)
	}

	/// Tests that `refresh()` sets error alert state when the network call fails.
	@MainActor
	func testRefreshSetsErrorAlertOnFailure() async {
		self.mockProvider.fetchResult = .failure(NetworkError.badStatusCode(500))

		await self.viewModel.refresh()

		XCTAssertTrue(self.viewModel.displayErrorAlert)
		XCTAssertNotNil(self.viewModel.alertMessage)
		XCTAssertTrue(self.viewModel.characters.isEmpty)
	}

	// MARK: - Pagination

	/// Tests that `fetchNextCharacters` appends new characters without duplicates.
	@MainActor
	func testFetchNextCharactersAppendsPaginatedResults() async throws {
		// Load page 1
		let page1 = [Self.makeCharacter(id: 1), Self.makeCharacter(id: 2)]
		self.mockProvider.fetchResult = .success(Self.makeResponse(characters: page1, pages: 2))
		await self.viewModel.refresh()

		// Load page 2
		let page2 = [Self.makeCharacter(id: 3), Self.makeCharacter(id: 4)]
		self.mockProvider.fetchResult = .success(Self.makeResponse(characters: page2, pages: 2))
		try await self.viewModel.fetchNextCharacters(for: 2)

		XCTAssertEqual(self.viewModel.characters.count, 4)
		XCTAssertEqual(self.viewModel.currentPage, 2)
	}

	/// Tests that `fetchNextCharacters` does not fetch beyond the last page.
	@MainActor
	func testFetchNextCharactersStopsAtLastPage() async throws {
		let page1 = [Self.makeCharacter(id: 1)]
		self.mockProvider.fetchResult = .success(Self.makeResponse(characters: page1, pages: 1))
		await self.viewModel.refresh()

		self.mockProvider.fetchCallHistory.removeAll()

		try await self.viewModel.fetchNextCharacters(for: 2)

		// Should not have called the API since page 2 > totalPages (1)
		XCTAssertTrue(self.mockProvider.fetchCallHistory.isEmpty)
		XCTAssertEqual(self.viewModel.characters.count, 1)
	}

	// MARK: - Filter & Search

	/// Tests that `performFilteredSearch()` resets pagination to page 1 and replaces characters.
	@MainActor
	func testPerformFilteredSearchResetsPaginationAndReplacesCharacters() async {
		// Initial load
		let initialCharacters = [Self.makeCharacter(id: 1), Self.makeCharacter(id: 2)]
		self.mockProvider.fetchResult = .success(Self.makeResponse(characters: initialCharacters, pages: 3))
		await self.viewModel.refresh()

		XCTAssertEqual(self.viewModel.characters.count, 2)

		// Simulate filter change
		let filteredCharacters = [Self.makeCharacter(id: 5, name: "Beth Smith")]
		self.mockProvider.fetchResult = .success(Self.makeResponse(characters: filteredCharacters, pages: 1))

		self.viewModel.searchText = "Beth"
		await self.viewModel.performFilteredSearch()

		XCTAssertEqual(self.viewModel.characters.count, 1)
		XCTAssertEqual(self.viewModel.characters[0].name, "Beth Smith")
		XCTAssertEqual(self.viewModel.currentPage, 1)
		XCTAssertEqual(self.viewModel.totalPages, 1)
	}

	/// Tests that `performFilteredSearch()` passes the correct name and status parameters to the provider.
	@MainActor
	func testFilteredSearchPassesCorrectParameters() async {
		self.mockProvider.fetchResult = .success(Self.makeResponse(characters: []))
		self.mockProvider.fetchCallHistory.removeAll()

		self.viewModel.searchText = "rick"
		self.viewModel.selectedStatus = .alive

		await self.viewModel.performFilteredSearch()

		let lastCall = self.mockProvider.fetchCallHistory.last
		XCTAssertEqual(lastCall?.page, 1)
		XCTAssertEqual(lastCall?.name, "rick")
		XCTAssertEqual(lastCall?.status, "alive")
	}

	/// Tests that `performFilteredSearch()` clears characters when no results match (API returns 404).
	@MainActor
	func testFilteredSearchClearsCharactersOn404() async {
		// Initial load
		let initialCharacters = [Self.makeCharacter(id: 1)]
		self.mockProvider.fetchResult = .success(Self.makeResponse(characters: initialCharacters))
		await self.viewModel.refresh()

		XCTAssertEqual(self.viewModel.characters.count, 1)

		// API returns 404 for no results
		self.mockProvider.fetchResult = .failure(NetworkError.badStatusCode(404))
		await self.viewModel.performFilteredSearch()

		XCTAssertTrue(self.viewModel.characters.isEmpty)
		XCTAssertFalse(self.viewModel.displayErrorAlert)
	}
}

// MARK: - Service / API Layer Tests

final class CharacterDecodingTests: XCTestCase {
	/// Tests successful decoding of a valid `CharacterResponse` JSON.
	func testDecodeCharacterResponseSuccess() throws {
		let json = """
		{
			"info": {
				"count": 826,
				"pages": 42,
				"next": "https://rickandmortyapi.com/api/character?page=2",
				"prev": null
			},
			"results": [
				{
					"id": 1,
					"name": "Rick Sanchez",
					"status": "Alive",
					"species": "Human",
					"type": "",
					"gender": "Male",
					"origin": { "name": "Earth (C-137)", "url": "https://rickandmortyapi.com/api/location/1" },
					"location": { "name": "Citadel of Ricks", "url": "https://rickandmortyapi.com/api/location/3" },
					"image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
					"episode": [
						"https://rickandmortyapi.com/api/episode/1",
						"https://rickandmortyapi.com/api/episode/2"
					],
					"url": "https://rickandmortyapi.com/api/character/1",
					"created": "2017-11-04T18:48:46.250Z"
				}
			]
		}
		""".data(using: .utf8)!

		let response = try JSONDecoder().decode(CharacterResponse.self, from: json)

		XCTAssertEqual(response.info.count, 826)
		XCTAssertEqual(response.info.pages, 42)
		XCTAssertEqual(response.info.next, "https://rickandmortyapi.com/api/character?page=2")
		XCTAssertNil(response.info.prev)
		XCTAssertEqual(response.results.count, 1)

		let character = response.results[0]
		XCTAssertEqual(character.id, 1)
		XCTAssertEqual(character.name, "Rick Sanchez")
		XCTAssertEqual(character.status, "Alive")
		XCTAssertEqual(character.species, "Human")
		XCTAssertEqual(character.gender, "Male")
		XCTAssertEqual(character.origin.name, "Earth (C-137)")
		XCTAssertEqual(character.location.name, "Citadel of Ricks")
		XCTAssertEqual(character.episode.count, 2)
	}

	/// Tests that decoding fails gracefully with malformed JSON.
	func testDecodeCharacterResponseFailsWithMalformedJSON() {
		let malformedJSON = """
		{ "info": { "count": 1 }, "results": "not_an_array" }
		""".data(using: .utf8)!

		XCTAssertThrowsError(try JSONDecoder().decode(CharacterResponse.self, from: malformedJSON))
	}

	/// Tests that decoding fails when required fields are missing.
	func testDecodeCharacterFailsWithMissingFields() {
		let incompleteJSON = """
		{
			"info": { "count": 1, "pages": 1, "next": null, "prev": null },
			"results": [
				{
					"id": 1,
					"name": "Rick"
				}
			]
		}
		""".data(using: .utf8)!

		XCTAssertThrowsError(try JSONDecoder().decode(CharacterResponse.self, from: incompleteJSON))
	}

	/// Tests decoding of the error response the API returns for invalid requests (404).
	func testDecodeErrorResponseDoesNotDecodeAsCharacterResponse() {
		let errorJSON = """
		{ "error": "There is nothing here" }
		""".data(using: .utf8)!

		XCTAssertThrowsError(try JSONDecoder().decode(CharacterResponse.self, from: errorJSON))
	}
}
