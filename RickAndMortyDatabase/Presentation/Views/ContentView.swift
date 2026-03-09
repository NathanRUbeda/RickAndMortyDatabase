//
//  ContentView.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import SwiftUI

struct ContentView: View {
	// MARK: Injected properties
	/// The view model to handle displaying and refreshing characters.
	@Bindable var viewModel: CharacterViewModel

	// MARK: Local properties
	/// The character visible based on the scroll position.
	@State private var visibleCharacterID: Character.ID?

	/// Whether or not to display a no internet alert.
	@State private var displayNoInternetAlert = false

	/// Whether or not the search field is focused.
	@FocusState private var isSearchFocused: Bool

    var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				VStack {
					self.searchBar

					StatusFilterView(selectedStatus: self.$viewModel.selectedStatus)
						.padding(.bottom)

					if self.viewModel.characters.isEmpty && !self.viewModel.isFetching {
						Text("NO RESULTS FOUND")
							.font(.custom("OCR-B", size: 16, relativeTo: .body))
							.foregroundStyle(.green)
							.frame(maxWidth: .infinity)
							.padding(.top, 40)
					} else {
						self.charactersForEach

						if self.viewModel.isFetching {
							ProgressView()
								.tint(.green)
								.frame(maxWidth: .infinity)
								.padding(.vertical, 20)
						}
					}
				}
				.scrollTargetLayout()
			}
			.background(.darkGreen, ignoresSafeAreaEdges: .all)
			.toolbarBackground(.darkGreen, for: .navigationBar)
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbar {
				ToolbarItem(placement: .principal) {
					Image.rickAndMortyLogo
						.resizable()
						.scaledToFit()
						.frame(height: 120)
				}
			}
			.scrollPosition(
				id: self.$visibleCharacterID,
				anchor: .bottom
			)
			.onChange(of: self.visibleCharacterID) { _, newValue in
				fetchNewPages(newValue: newValue)
			}
			.alert("Unable to refresh without internet", isPresented: self.$displayNoInternetAlert) {
				Button("OK") {
					self.displayNoInternetAlert = false
				}
			}
			.alert(
				self.viewModel.alertTitle ?? "Error occurred",
				isPresented: self.$viewModel.displayErrorAlert,
				actions: {
					Button("Retry") {
						self.viewModel.displayErrorAlert = false
						self.viewModel.alertTitle = nil
						self.viewModel.alertMessage = nil
						Task {
							await self.viewModel.refresh()
						}
					}
				},
				message: {
					if let message = self.viewModel.alertMessage {
						Text(message)
					}
				}
			)
		}
    }

	/// A custom search bar that scrolls with the list content.
	private var searchBar: some View {
		HStack {
			Image(systemName: "magnifyingglass")
				.foregroundStyle(.green)

			TextField(
				"",
				text: self.$viewModel.searchText,
				prompt: Text("Search by character name")
					.foregroundStyle(.green.opacity(0.5))
			)
				.font(.custom("OCR-B", size: 14, relativeTo: .body))
				.foregroundStyle(.green)
				.focused(self.$isSearchFocused)

			if !self.viewModel.searchText.isEmpty {
				Button {
					self.viewModel.searchText = ""
				} label: {
					Image(systemName: "xmark.circle.fill")
						.foregroundStyle(.green.opacity(0.7))
				}
			}
		}
		.padding(10)
		.background(.darkGreen, in: RoundedRectangle(cornerRadius: 8))
		.overlay(RoundedRectangle(cornerRadius: 8).stroke(.green.opacity(0.5), lineWidth: 1))
		.padding(.horizontal)
		.padding(.vertical, 8)
		.background(.darkGreen)
	}

	/// A `ForEach` view that displays a navigation link for each character in the view model's list.
	private var charactersForEach: some View {
		ForEach(self.viewModel.characters) { character in
			let imageView = CharacterImageView(characterImageURL: character.image)

			NavigationLink {
				CharacterDetailView(
					viewModel: CharacterDetailViewModel(
						for: String(character.id)
					),
					imageView: imageView
				)
			} label: {
				CharacterLabel(
					character: character,
					imageView: imageView
				)
				.padding(.bottom, 12)
			}
		}
		.padding(.horizontal)
	}

	/// Fetches new data pages from the API when the user gets close to the bottom of the list.
	/// - Parameters:
	/// -  newValue: The new Character's ID.
	func fetchNewPages(newValue: Character.ID?) {
		guard let currentIndex = self.viewModel.characters.firstIndex(where: { $0.id == newValue }) else {
			return
		}
		let lastIndex = self.viewModel.characters.endIndex

		let endingRemainder = lastIndex - currentIndex
		if endingRemainder <= 2 {
			Task {
				let currentPage = self.viewModel.currentPage + 1
				try? await self.viewModel.fetchNextCharacters(for: currentPage)
			}
		}
	}
}
