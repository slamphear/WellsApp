//
//  ProductViews.swift
//  WellsPrintAndDigital
//
//  Created by Steven Lamphear on 6/3/22.
//

import Foundation
import SwiftUI

struct ProductsView: View {
    @EnvironmentObject var navigationModel: NavigationModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16.0) {
                Text(TokenizedStrings.products()).font(.title)
                Text(TokenizedStrings.productsDescription()).font(.body)
                Text(TokenizedStrings.getInTouch()).font(.title)
                Text(TokenizedStrings.getInTouchDescription()).font(.body)
                Button(action: {
                    navigationModel.selectedTab = .estimate
                }, label: {
                    Text(TokenizedStrings.getAnEstimate())
                })
                Spacer(minLength: 1.0)
            }.padding()
        }
        .tabItem {
            Image(systemName: "paperclip")
            Text(TokenizedStrings.products())
        }
        .tag(Tab.products)
    }

    private func getAnEstimate() {
        print("Getting an estimate")
    }
}

struct ProductsView_Previews: PreviewProvider {
    static let navigationModel = NavigationModel()

    static var previews: some View {
        ProductsView()
            .environmentObject(navigationModel)
    }
}
