//
//  RickAndMortyDatabaseApp.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import SwiftUI

@main
struct RickAndMortyDatabaseApp: App {
	/// The view model to display and manage characters.
	let viewModel: CharacterViewModel
	
	init() {
		WebServiceFactory.shared.dispatcher = CoreWebServiceDispatcher()
		let webService = WebServiceFactory.shared.characterProvider()
		self.viewModel = .init(webService: webService)
	}
	
    var body: some Scene {
        WindowGroup {
			NavigationStack {
				if self.viewModel.isLoaded {
					ContentView(viewModel: self.viewModel)
				} else {
					SplashScreenView()
				}
			}
			.task {
				if !self.viewModel.isLoaded {
					await self.viewModel.fetchInitialCharacters()
				}
			}
        }
    }
}
