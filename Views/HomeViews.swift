//
//  HomeViews.swift
//  WellsPrintAndDigital
//
//  Created by Steven Lamphear on 6/3/22.
//

import Foundation
import MapKit
import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView(.vertical) {
            Image("WideBuilding").resizable().scaledToFit()
            VStack(alignment: .leading, spacing: 16.0) {
                Text(TokenizedStrings.homeTitle()).font(.title2)
                Text(TokenizedStrings.homeBody()).font(.body)
                #if os(iOS)
                MapView().frame(height: 300)
                #endif
            }.padding()
        }.tabItem({
            Image(systemName: "house")
            Text(TokenizedStrings.homeLabel())
        }).tag(Tab.home)
    }
}

#if os(iOS)

struct MapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(latitude: 43.028690, longitude: -89.399430)
        let span = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        view.addAnnotation(annotation)
        view.setRegion(region, animated: true)
    }
}

#endif

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
