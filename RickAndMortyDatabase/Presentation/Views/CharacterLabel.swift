//
//  CharacterLabel.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import SwiftUI

struct CharacterLabel<Character: DisplayableCharacter, ImageView: View>: View {
	// MARK: Injected properties
	/// The character to display.
	let character: Character
	
	/// The character image view to display.
	let imageView: ImageView
	
    var body: some View {
		VStack {
			HStack(alignment: .top) {
				VStack(alignment: .leading) {
					self.nameText
					self.speciesText
					self.statusText
				}
				
				Spacer()
				
				CharacterImageContainerView(
					width: 120,
					height: 120,
					cornerRadius: 4,
					imageView: self.imageView
				)
			}
		}
		.padding(8)
		.background(.green.opacity(0.5), in: RoundedRectangle(cornerRadius: 4))
		.overlay(RoundedRectangle(cornerRadius: 4).stroke(.green, lineWidth: 3))
    }
	
	/// Displays a text with the name of the character.
	private var nameText: some View {
		Text(self.character.name.uppercased())
			.font(.custom("OCR-B", size: 18, relativeTo: .title2))
			.fontWeight(.bold)
			.foregroundStyle(.green)
			.multilineTextAlignment(.leading)
			.padding(.horizontal, 12)
			.padding(.vertical, 6)
			.background(.darkGreen, in: RoundedRectangle(cornerRadius: 4))
			.overlay(RoundedRectangle(cornerRadius: 4).stroke(.green, lineWidth: 2))
			.padding(.bottom, 6)
	}
	
	/// Displays a text with the species of the character.
	private var speciesText: some View {
		Text("//SPECIES: \(self.character.species.uppercased())")
			.font(.custom("OCR-B", size: 12, relativeTo: .body))
			.fontWeight(.medium)
			.foregroundStyle(.white)
			.multilineTextAlignment(.leading)
	}
	
	/// Displays a text with the status of the character.
	private var statusText: some View {
		Text("//STATUS: \(self.character.status.uppercased())")
			.font(.custom("OCR-B", size: 12, relativeTo: .body))
			.fontWeight(.medium)
			.foregroundStyle(.white)
			.multilineTextAlignment(.leading)
	}
}
