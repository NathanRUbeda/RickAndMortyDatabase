//
//  StatusFilterView.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import SwiftUI

/// Displays a horizontal row of status filter buttons.
struct StatusFilterView: View {
	/// The currently selected status filter.
	@Binding var selectedStatus: StatusFilter

	var body: some View {
		HStack(spacing: 8) {
			ForEach(StatusFilter.allCases) { status in
				Button {
					self.selectedStatus = status
				} label: {
					Text(status.displayName)
						.font(.custom("OCR-B", size: 12, relativeTo: .caption))
						.fontWeight(self.selectedStatus == status ? .bold : .regular)
						.foregroundStyle(self.selectedStatus == status ? .black : .green)
						.padding(.horizontal, 12)
						.padding(.vertical, 6)
						.background(
							self.selectedStatus == status ? Color.green : Color.clear,
							in: RoundedRectangle(cornerRadius: 4)
						)
						.overlay(
							RoundedRectangle(cornerRadius: 4)
								.stroke(.green, lineWidth: 2)
						)
				}
			}
		}
		.padding(.vertical, 8)
	}
}
