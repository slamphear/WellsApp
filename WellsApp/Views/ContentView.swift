//
//  ContentView.swift
//  WellsApp
//
//  Created by Steven Lamphear on 7/9/19.
//  Copyright © 2019 Steven Lamphear. All rights reserved.
//

import Combine
import SwiftUI


struct ContentView: View {
    @State private var selection = 0
 
    var body: some View {
        VStack {
            LogoHeaderView()
            TabbedView(selection: $selection){
                HomeView()
                ProductsView()
                ServicesView()
                EstimateView().environmentObject(EstimateModel())
                AboutUsView()
                ContactUsView()
            }
        }
    }
}

struct LogoHeaderView: View {
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack {
                Spacer()
                Image("WellsLogo").resizable().scaledToFit().padding()
                Spacer()
            }
            Button(action: { self.dialPhoneNumber() }, label: { Text(LocalizedStrings.phoneNumber()).font(.footnote) }).padding()
        }
    }
    
    private func dialPhoneNumber() {
        guard let url = URL(string: "tel://+16082747474") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct HomeView: View {
    var body: some View {
        ScrollView(.vertical) {
            Image("WideBuilding").resizable().scaledToFit()
            Text(LocalizedStrings.homeTitle()).padding().font(.title).lineLimit(nil)
            Text(LocalizedStrings.homeBody()).padding().font(.body).lineLimit(nil)
            Spacer()
        }.tabItem({
            Image(systemName: "house")
            Text(LocalizedStrings.homeLabel())
        }).tag(ContentSection.Home.rawValue)
    }
}

struct ProductsView: View {
    var body: some View {
        ScrollView(.vertical) {
            Text(LocalizedStrings.products()).font(.title).padding()
            Text(LocalizedStrings.productsDescription()).padding().font(.body).lineLimit(nil)
            Spacer()
            Text(LocalizedStrings.getInTouch()).font(.title)
            Text(LocalizedStrings.getInTouchDescription()).padding().font(.body).lineLimit(nil)
            Button(action: {
                self.getAnEstimate()
            }, label: {
                Text(LocalizedStrings.getAnEstimate())
            })
        }.tabItem {
            Image(systemName: "printer")
            Text(LocalizedStrings.products())
        }.tag(ContentSection.Products.rawValue)
    }
    
    private func getAnEstimate() {
        print("Getting an estimate")
    }
}

struct ServicesView: View {
    var body: some View {
        ScrollView(.vertical) {
            Text(LocalizedStrings.services()).font(.title).padding()
            Spacer()
        }.tabItem {
            Image(systemName: "cloud")
            Text(LocalizedStrings.services())
        }.tag(ContentSection.Services.rawValue)
    }
}

struct EstimateView: View {
    @EnvironmentObject var estimateModel: EstimateModel
    
    var body: some View {
        ScrollView(.vertical) {
            Text(LocalizedStrings.estimateLabel()).font(.title).padding()
            NameView().padding()
            EmailAddressView().padding()
            ProjectDetailsView().padding()
            Button(action: { self.submitEstimateRequest() }, label: { Text(LocalizedStrings.submit()) })
            Spacer()
        }.tabItem({
            Image(systemName: "dollarsign.circle")
            Text(LocalizedStrings.estimateLabel())
        }).tag(ContentSection.Estimate.rawValue)
    }
    
    private func submitEstimateRequest() {
        print("Submitting estimate...")
    }
}

struct NameView: View {
    @EnvironmentObject var estimateModel: EstimateModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStrings.name() + " *").bold()
            
            HStack {
                TextField(LocalizedStrings.firstName(), text: $estimateModel.firstName)
                TextField(LocalizedStrings.lastName(), text: $estimateModel.lastName)
            }
        }
    }
}

struct EmailAddressView: View {
    @EnvironmentObject var estimateModel: EstimateModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStrings.emailAddress() + " *").bold()
            TextField(LocalizedStrings.emailAddress(), text: $estimateModel.emailAddress)
        }
    }
}

struct ProjectDetailsView: View {
    @EnvironmentObject var estimateModel: EstimateModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStrings.projectDetails() + " *").bold()
            Text(LocalizedStrings.projectDetailsDescription()).font(.caption).lineLimit(nil)
            TextField(LocalizedStrings.projectDetails(), text: $estimateModel.projectDetails)
        }
    }
}

struct AboutUsView: View {
    var body: some View {
        ScrollView(.vertical) {
            Text("About Us").font(.title).padding()
            Spacer()
        }.tabItem({
            Image(systemName: "person.and.person")
            Text("About Us")
        }).tag(ContentSection.AboutUs.rawValue)
    }
}

struct ContactUsView: View {
    var body: some View {
        ScrollView(.vertical) {
            Text(LocalizedStrings.contactUs()).font(.title).padding()
            //            Text(LocalizedStrings.officeHours()).bold().padding()
            //            Text(LocalizedStrings.officeHoursFirstLine())
            //            Text(LocalizedStrings.officeHoursSecondLine())
            Spacer()
            Text(LocalizedStrings.location()).bold().padding()
            Text(LocalizedStrings.addressFirstLine())
            Text(LocalizedStrings.addressSecondLine())
            Spacer()
            Text(LocalizedStrings.contact()).bold().padding()
            Text("info@printanddigital.com")
            Text(LocalizedStrings.phoneNumber())
            Spacer()
        }.tabItem({
            Image(systemName: "envelope")
            Text(LocalizedStrings.contactUs())
        }).tag(ContentSection.ContactUs.rawValue)
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
