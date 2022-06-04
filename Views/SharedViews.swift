//
//  SharedViews.swift
//  WellsPrintAndDigital
//
//  Created by Steven Lamphear on 7/9/19.
//  Copyright © 2019 Steven Lamphear. All rights reserved.
//

import Combine
import SwiftUI

struct ContentView: View {
    @State var navigationModel = NavigationModel()
    @State var selection = 0
 
    var body: some View {
        VStack {
            LogoHeaderView()
            TabView(selection: $navigationModel.selectedTab){
                HomeView()
                ProductsView()
                EstimateFormView().environmentObject(EstimateModel())
                ContactUsView()
            }
        }
        .environmentObject(navigationModel)
    }
}

struct LogoHeaderView: View {
    var body: some View {
        HStack {
            Image("WellsLogo").resizable().scaledToFit().padding()
            Spacer()
            #if os(iOS)
            PhoneNumberButton(font: .footnote).padding()
            #else
            PhoneNumberLabel(font: .footnote).padding()
            #endif
        }.frame(maxHeight: 75)
    }
}

#if os(iOS)

struct PhoneNumberButton: View {
    let font: Font

    var body: some View {
        Button(action: {
            dialPhoneNumber()
        }, label: {
            Text(TokenizedStrings.wellsPhoneNumber()).font(font)
        })
    }

    private func dialPhoneNumber() {
        guard let url = URL(string: "tel://+16082747474") else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

#endif

struct PhoneNumberLabel: View {
    let font: Font

    var body: some View {
        Text(TokenizedStrings.wellsPhoneNumber()).font(font)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
