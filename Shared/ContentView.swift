//
//  ContentView.swift
//  WellsPrintAndDigital
//
//  Created by Steven Lamphear on 7/9/19.
//  Copyright © 2019 Steven Lamphear. All rights reserved.
//

import Combine
import MapKit
import MessageUI
import SwiftUI
import AudioToolbox


struct ContentView: View {
    @State var navigationModel = NavigationModel()
    @State var selection = 0
 
    var body: some View {
        VStack {
            LogoHeaderView()
            TabView(selection: self.$navigationModel.selectedTab){
                HomeView()
                ProductsView()
                EstimateFormView().environmentObject(EstimateModel())
                ContactUsView()
            }
        }
        .environmentObject(self.navigationModel)
    }
}

struct EmailButton: View {
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    
    var body: some View {
        Button(action: {
            self.isShowingMailView.toggle()
        }, label: {
            Text(Constants.wellsEmailAddress)
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
        mailViewController.setToRecipients([Constants.wellsEmailAddress])
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
            Text(TokenizedStrings.wellsPhoneNumber()).font(self.font)
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
        HStack {
            Image("WellsLogo").resizable().scaledToFit().padding()
            Spacer()
            PhoneNumberButton(font: .footnote).padding()
        }.frame(maxHeight: 75)
    }
}

struct HomeView: View {
    var body: some View {
        ScrollView(.vertical) {
            Image("WideBuilding").resizable().scaledToFit()
            VStack(alignment: .leading, spacing: 16.0) {
                Text(TokenizedStrings.homeTitle()).font(.title2)
                Text(TokenizedStrings.homeBody()).font(.body)
                MapView().frame(height: 300)
            }.padding()
        }.tabItem({
            Image(systemName: "house")
            Text(TokenizedStrings.homeLabel())
        }).tag(Tab.home)
    }
}

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
                    self.navigationModel.selectedTab = .estimate
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

struct EstimateFormView: View {
    @EnvironmentObject var estimateModel: EstimateModel
    @EnvironmentObject var navigationModel: NavigationModel
    @State var submitButtonDisabled = true
    @State var showSubmitDialog = false
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16.0) {
                Text(TokenizedStrings.estimateLabel()).font(.title)
                NameInputView()
                EmailAddressInputView()
                PhoneNumberInputView()
                ProjectDetailsInputView()
            }.padding()
            
            Button(action: { self.submitEstimateRequest() }, label: { Text(TokenizedStrings.submit()) })
                .disabled(self.submitButtonDisabled)
            Spacer()
        }
        .onChange(of: self.estimateModel.firstName, perform: { newValue in
            self.updateSubmitButtonState()
        })
        .onChange(of: self.estimateModel.lastName, perform: { newValue in
            self.updateSubmitButtonState()
        })
        .onChange(of: self.estimateModel.validEmailAddressEntered, perform: { newValue in
            self.updateSubmitButtonState()
        })
        .onChange(of: self.estimateModel.validPhoneNumberEntered, perform: { newValue in
            self.updateSubmitButtonState()
        })
        .onChange(of: self.estimateModel.projectDetails, perform: { newValue in
            self.updateSubmitButtonState()
        })
        .tabItem({
            Image(systemName: "dollarsign.circle")
            Text(TokenizedStrings.estimateLabel())
        }).tag(Tab.estimate)
        .alert(isPresented: self.$showSubmitDialog, content: {
            Alert(title: Text(TokenizedStrings.estimateRequestSubmittedTitle()),
                  message: Text(TokenizedStrings.estimateRequestSubmittedMessage()),
                  dismissButton: .default(Text(TokenizedStrings.ok()), action: {
                    self.showSubmitDialog = false
                    self.estimateModel.reset()
                    self.navigationModel.selectedTab = .home
            }))
        })
    }
    
    private func updateSubmitButtonState() {
        self.submitButtonDisabled = self.estimateModel.firstName.isEmpty
            || self.estimateModel.lastName.isEmpty
            || !self.estimateModel.validEmailAddressEntered
            || !self.estimateModel.validPhoneNumberEntered
            || self.estimateModel.projectDetails.isEmpty
    }
    
    private func submitEstimateRequest() {
        self.showSubmitDialog = true
    }
}

struct NameInputView: View {
    @EnvironmentObject var estimateModel: EstimateModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(TokenizedStrings.name() + " *").bold()
            
            HStack {
                TextField(TokenizedStrings.firstName(), text: $estimateModel.firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField(TokenizedStrings.lastName(), text: $estimateModel.lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

struct EmailAddressInputView: View {
    @EnvironmentObject var estimateModel: EstimateModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(TokenizedStrings.emailAddress() + " *").bold()
            TextField(TokenizedStrings.emailAddress(), text: $estimateModel.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct PhoneNumberInputView: View {
    @EnvironmentObject var estimateModel: EstimateModel
    @State private var validatedPhoneNumber = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(TokenizedStrings.phoneNumber() + " *").bold()
            TextField("###-###-####", text: $estimateModel.phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: estimateModel.phoneNumber, perform: { newValue in
                    self.validateInput(newValue)
                })
        }
    }
    
    private func validateInput(_ newValue: String) {
        if newValue.isEmpty {
            // Valid case: new value is empty
            self.validatedPhoneNumber = newValue
            return
        }
        
        if !CharacterSet(charactersIn: "0123456789-").isSuperset(of: CharacterSet(charactersIn: newValue)) {
            // Invalid case: new value contains non-numeric characters
            self.revertToLastValidValue()
            return
        }
        
        if newValue.count > 12 {
            // Invalid case: more than 12 characters
            self.revertToLastValidValue()
            return
        }
        
        if newValue.count > self.validatedPhoneNumber.count && (newValue.count == 3 || newValue.count == 7) {
            // If the user is adding characters, automatically append hyphens.
            // (But not if the user is deleting characters!)
            self.validatedPhoneNumber = "\(newValue)-"
            self.estimateModel.phoneNumber = self.validatedPhoneNumber
            return
        }
        
        // Valid case: new value passed all checks
        self.validatedPhoneNumber = newValue
    }
    
    private func revertToLastValidValue() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        self.estimateModel.phoneNumber = self.validatedPhoneNumber
    }
}

struct ProjectDetailsInputView: View {
    @EnvironmentObject var estimateModel: EstimateModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(TokenizedStrings.projectDetails() + " *").bold()
            Text(TokenizedStrings.projectDetailsDescription()).allowsTightening(true)
            TextEditor(text: $estimateModel.projectDetails)
                .frame(height: 120)
                .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemFill), lineWidth: 0.75)
                )
        }
    }
}

struct ContactUsView: View {
    var body: some View {
        ScrollView(.vertical) {
            Group {
                Text(TokenizedStrings.contactUs()).font(.title).padding()
                Text(TokenizedStrings.officeHours()).bold().padding()
                Text(TokenizedStrings.officeHoursFirstLine())
                Text(TokenizedStrings.officeHoursSecondLine())
            }
            Group {
                Text(TokenizedStrings.location()).bold().padding()
                Text(Constants.wellsAddressFirstLine)
                Text(Constants.wellsAddressSecondLine)
            }
            Group {
                Text(TokenizedStrings.contact()).bold().padding()
                EmailButton()
                PhoneNumberButton(font: .body).padding()
            }
        }
        .tabItem({
            Image(systemName: "envelope")
            Text(TokenizedStrings.contactUs())
        })
        .tag(Tab.contactUs)
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

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
