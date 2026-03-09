//
//  CharacterImageView.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import SwiftUI

/// Displays an AsyncImage to show the character's image or a default icon when missing a photo.
struct CharacterImageView: View {
	// MARK: Injected properties
	/// The image url for the character.
	let characterImageURL: String?
	
	// MARK: Local properties
	/// If the image is done loading or not.
	@State private var isLoading = true
	
	/// The image loading error.
	@State private var error: Error?
	
	/// The character view to display.
	@State private var image: Image?
	
	var body: some View {
		self.contentView
			.task {
				defer {
					self.isLoading = false
				}

				if let characterImageURL, let url = URL(string: characterImageURL) {
					await self.loadImage(from: url)
				}
			}
	}

	/// Loads the image from the given URL, silently retrying on 429 (Too Many Requests).
	private func loadImage(from url: URL) async {
		do {
			let (data, response) = try await URLSession.shared.data(from: url)
			if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429 {
				try? await Task.sleep(for: .milliseconds(500))
				await self.loadImage(from: url)
				return
			}
			if let uiImage = UIImage(data: data) {
				self.image = Image(uiImage: uiImage)
			}
		} catch {
			self.error = error
		}
	}
	
	/// Displays content depending on the result of the image fetching.
	@ViewBuilder
	private var contentView: some View {
		if let image {
			image
				.resizable()
				.scaledToFill()
		} else if self.isLoading {
			self.loadingView
		} else {
			self.errorView
		}
	}
	
	/// Displays a atom icon with a rectangular stroke around it.
	private var errorView: some View {
		Image(systemName: "atom")
			.resizable()
			.padding()
			.foregroundStyle(.secondary)
	}
	
	/// Displays a ProgressView with a rectangular stroke around it.
	private var loadingView: some View {
		ProgressView()
			.controlSize(.large)
	}
}

