//
//  CharacterDetailView.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import SwiftUI

struct CharacterDetailView<ImageView: View>: View {
	// MARK: Injected properties
	/// The view model for the detail view.
	@State var viewModel: CharacterDetailViewModel
	
	/// The character image view to display.
	let imageView: ImageView

	/// Used to dismiss the view and go back to the list.
	@Environment(\.dismiss) private var dismiss

    var body: some View {
		ScrollView {
			VStack(alignment: .center) {
				self.nameText

				CharacterImageContainerView(
					width: 150,
					height: 150,
					cornerRadius: 4,
					imageView: self.imageView
				)
				.padding(10)
				.background(.white)
				.overlay(Rectangle().stroke(.black, lineWidth: 1))
				.padding(.bottom)

				self.dataPanel
			}
			.padding(.horizontal, 24)
		}
		.scrollBounceBehavior(.basedOnSize)
		.background(.gray, ignoresSafeAreaEdges: .all)
		.task {
			if !self.viewModel.isLoaded {
				await self.viewModel.refresh()
			}
		}
		.alert(
			"Unable to load character",
			isPresented: self.$viewModel.displayErrorAlert,
			actions: {
				Button("Retry") {
					self.viewModel.displayErrorAlert = false
					self.viewModel.alertMessage = nil
					Task {
						await self.viewModel.refresh()
					}
				}
				Button("OK", role: .cancel) {
					self.dismiss()
				}
			},
			message: {
				if let message = self.viewModel.alertMessage {
					Text(message)
				}
			}
		)
    }
	
	/// Displays a text with the name of the character, or a ProgressView while loading.
	private var nameText: some View {
		Group {
			if self.viewModel.isLoaded {
				Text((self.viewModel.name ?? "-").uppercased())
					.font(.custom("OCR-B", size: 18, relativeTo: .title2))
					.fontWeight(.bold)
					.foregroundStyle(.green)
					.multilineTextAlignment(.center)
			} else {
				ProgressView()
					.tint(.green)
			}
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 6)
		.background(.darkGreen, in: RoundedRectangle(cornerRadius: 4))
		.overlay(RoundedRectangle(cornerRadius: 4).stroke(.green, lineWidth: 2))
		.padding(.bottom, 6)
	}
	
	/// The data panel with character info, framed by a simple border.
	private var dataPanel: some View {
		Group {
			if self.viewModel.isLoaded {
				ScrollView {
					VStack(spacing: 16) {
						self.dataRow(label: "STATUS", value: (self.viewModel.status ?? "-").uppercased())
						self.dataRow(label: "SPECIES", value: (self.viewModel.species ?? "-").uppercased())
						self.dataRow(label: "GENDER", value: (self.viewModel.gender ?? "-").uppercased())
						self.dataRow(label: "ORIGIN", value: (self.viewModel.origin?.name ?? "-").uppercased())
						self.dataRow(label: "LOCATION", value: (self.viewModel.location?.name ?? "-").uppercased())
						self.dataRow(label: "EPISODE COUNT", value: "\(self.viewModel.episodeCount ?? 0)")
					}
					.frame(maxWidth: .infinity)
					.padding(.vertical, 24)
					.padding(.horizontal, 32)
				}
			} else {
				ProgressView()
					.tint(.green)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.background(.black, in: RoundedRectangle(cornerRadius: 4))
		.overlay(
			RoundedRectangle(cornerRadius: 4)
				.stroke(Color(white: 0.3), lineWidth: 14)
		)
		.frame(maxWidth: .infinity, minHeight: 420, maxHeight: 420)
	}
	
	/// A single row in the data panel.
	private func dataRow(label: String, value: String) -> some View {
		VStack(spacing: 4) {
			Text(label)
				.font(.custom("OCR-B", size: 12, relativeTo: .caption))
				.foregroundStyle(.gray)
			
			Text(value)
				.font(.custom("OCR-B", size: 20, relativeTo: .title3))
				.fontWeight(.bold)
				.foregroundStyle(.green)
				.multilineTextAlignment(.center)
		}
	}
}
