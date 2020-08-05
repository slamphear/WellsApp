//
//  ContentView.swift
//  WellsApp
//
//  Created by Steven Lamphear on 7/9/19.
//  Copyright © 2019 Steven Lamphear. All rights reserved.
//

import Combine
import MapKit
import MessageUI
import SwiftUI


struct ContentView: View {
    @State var selection = 0
 
    var body: some View {
        VStack {
            LogoHeaderView()
            TabView(selection: $selection){
                HomeView()
                ProductsView(selection: $selection)
//                ServicesView()
                EstimateView().environmentObject(EstimateModel())
//                AboutUsView()
                ContactUsView()
            }
        }
    }
}

struct EmailButton: View {
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    
    var body: some View {
        Button(action: {
            self.isShowingMailView.toggle()
        }, label: {
            Text(Constants.emailAddress)
        })
        .sheet(isPresented: $isShowingMailView, content: {
            self.mailView()
            .transition(.move(edge: .bottom))
            .animation(.default)
        })
    }
    
    private func mailView() -> some View {
        MFMailComposeViewController.canSendMail() ?
            AnyView(MailView(isPresented: $isShowingMailView, result: $result)) :
            AnyView(Text("Unable to send emails from this device"))
    }
}

struct MailView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(isShowing: Binding<Bool>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            self._isShowing = isShowing
            self._result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer { self.isShowing = false }
            
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: self.$isPresented, result: self.$result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = context.coordinator
        mailViewController.setToRecipients([Constants.emailAddress])
        return mailViewController
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) { }
}

struct PhoneNumberButton: View {
    let font: Font
    
    var body: some View {
        Button(action: {
            self.dialPhoneNumber()
        }, label: {
            Text(LocalizedStrings.wellsPhoneNumber()).font(self.font)
        })
    }
    
    private func dialPhoneNumber() {
        guard let url = URL(string: "tel://+16082747474") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
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
            PhoneNumberButton(font: .footnote).padding()
        }
    }
}

struct HomeView: View {
    var body: some View {
        ScrollView(.vertical) {
            Image("WideBuilding").resizable().scaledToFit()
            Text(LocalizedStrings.homeTitle()).padding().font(.title)
            Text(LocalizedStrings.homeBody()).padding().font(.body)
            MapView().frame(height: 300).padding()
        }.tabItem({
            Image(systemName: "house")
            Text(LocalizedStrings.homeLabel())
        }).tag(ContentSection.Home.rawValue)
    }
}

struct ProductsView: View {
    @Binding var selection: Int
    
    var body: some View {
        ScrollView {
            Text(LocalizedStrings.products()).font(.title).padding()
            Text(LocalizedStrings.productsDescription()).padding().font(.body)
            Text(LocalizedStrings.getInTouch()).font(.title)
            Text(LocalizedStrings.getInTouchDescription()).padding().font(.body)
            Button(action: {
                self.selection = ContentSection.Estimate.rawValue
            }, label: {
                Text(LocalizedStrings.getAnEstimate())
            })
            Spacer(minLength: 1.0)
        }
        .tabItem {
            Image(systemName: "paperclip")
            Text(LocalizedStrings.products())
        }
        .tag(ContentSection.Products.rawValue)
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
            Text(LocalizedStrings.projectDetailsDescription()).font(.caption)
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
            Image(systemName: "info.circle")
            Text("About Us")
        }).tag(ContentSection.AboutUs.rawValue)
    }
}

struct ContactUsView: View {
    var body: some View {
        ScrollView(.vertical) {
            Group {
                Text(LocalizedStrings.contactUs()).font(.title).padding()
                Text(LocalizedStrings.officeHours()).bold().padding()
                Text(LocalizedStrings.officeHoursFirstLine())
                Text(LocalizedStrings.officeHoursSecondLine())
            }
            Group {
                Text(LocalizedStrings.location()).bold().padding()
                Text(LocalizedStrings.addressFirstLine())
                Text(LocalizedStrings.addressSecondLine())
            }
            Group {
                Text(LocalizedStrings.contact()).bold().padding()
                EmailButton()
                PhoneNumberButton(font: .body).padding()
            }
        }
        .tabItem({
            Image(systemName: "envelope")
            Text(LocalizedStrings.contactUs())
        })
        .tag(ContentSection.ContactUs.rawValue)
    }
}

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

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
