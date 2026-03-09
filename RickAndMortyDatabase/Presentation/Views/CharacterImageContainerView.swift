//
//  CharacterImageContainerView.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import SwiftUI

/// Displays a customizable character image.
struct CharacterImageContainerView<ImageView: View>: View {
	// MARK: Injected properties
	/// The width of the image.
	let width: CGFloat
	
	/// The height of the image.
	let height: CGFloat
	
	/// The corner radius of the image.
	let cornerRadius: CGFloat
	
	/// The character image view to display.
	let imageView: ImageView
	
	var body: some View {
		self.imageView
			.frame(width: self.width, height: self.height)
			.clipped()
			.clipShape(.rect(cornerRadius: self.cornerRadius))
			.overlay(
				RoundedRectangle(cornerRadius: self.cornerRadius)
					.stroke(.green, lineWidth: 1)
			)
	}
}

