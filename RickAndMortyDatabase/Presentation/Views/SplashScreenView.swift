//
//  SplashScreenView.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import SwiftUI

/// Displays a splash screen or a ContentView, if active.
struct SplashScreenView: View {
	var body: some View {
		self.splashScreen
			.background(.darkGreen, ignoresSafeAreaEdges: .all)
	}
	
	/// Displays the logo and name of the app, and a ProgressView in a vertical stack.
	private var splashScreen: some View {
		VStack {
			Image.rickAndMortyLogo
				.resizable()
				.scaledToFit()
				.frame(width: 300)

			ProgressView()
				.frame(height: 140)
				.scaleEffect(3)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}


#Preview {
    SplashScreenView()
}
