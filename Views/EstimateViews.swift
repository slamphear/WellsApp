//
//  EstimateViews.swift
//  WellsPrintAndDigital
//
//  Created by Steven Lamphear on 6/3/22.
//

import AudioToolbox
import Foundation
import SwiftUI

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

            Button(action: { submitEstimateRequest() }, label: { Text(TokenizedStrings.submit()) })
                .buttonStyle(.bordered)
                .disabled(submitButtonDisabled)
            Spacer()
        }
        .onChange(of: estimateModel.firstName, perform: { newValue in
            updateSubmitButtonState()
        })
        .onChange(of: estimateModel.lastName, perform: { newValue in
            updateSubmitButtonState()
        })
        .onChange(of: estimateModel.validEmailAddressEntered, perform: { newValue in
            updateSubmitButtonState()
        })
        .onChange(of: estimateModel.validPhoneNumberEntered, perform: { newValue in
            updateSubmitButtonState()
        })
        .onChange(of: estimateModel.projectDetails, perform: { newValue in
            updateSubmitButtonState()
        })
        .tabItem({
            Image(systemName: "dollarsign.circle")
            Text(TokenizedStrings.estimateLabel())
        }).tag(Tab.estimate)
        .alert(isPresented: $showSubmitDialog, content: {
            Alert(title: Text(TokenizedStrings.estimateRequestSubmittedTitle()),
                  message: Text(TokenizedStrings.estimateRequestSubmittedMessage()),
                  dismissButton: .default(Text(TokenizedStrings.ok()), action: {
                    showSubmitDialog = false
                    estimateModel.reset()
                    navigationModel.selectedTab = .home
            }))
        })
    }

    private func updateSubmitButtonState() {
        submitButtonDisabled = estimateModel.firstName.isEmpty
            || estimateModel.lastName.isEmpty
            || !estimateModel.validEmailAddressEntered
            || !estimateModel.validPhoneNumberEntered
            || estimateModel.projectDetails.isEmpty
    }

    private func submitEstimateRequest() {
        showSubmitDialog = true
    }
}

private struct NameInputView: View {
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

private struct EmailAddressInputView: View {
    @EnvironmentObject var estimateModel: EstimateModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(TokenizedStrings.emailAddress() + " *").bold()
            TextField(TokenizedStrings.emailAddress(), text: $estimateModel.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                #if os(iOS)
                .keyboardType(.emailAddress)
                #endif
        }
    }
}

private struct PhoneNumberInputView: View {
    @EnvironmentObject var estimateModel: EstimateModel
    @State private var validatedPhoneNumber = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text(TokenizedStrings.phoneNumber() + " *").bold()
            TextField("###-###-####", text: $estimateModel.phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
                .onChange(of: estimateModel.phoneNumber, perform: { newValue in
                    validateInput(newValue)
                })
        }
    }

    private func validateInput(_ newValue: String) {
        if newValue.isEmpty {
            // Valid case: new value is empty
            validatedPhoneNumber = newValue
            return
        }

        if !CharacterSet(charactersIn: "0123456789-").isSuperset(of: CharacterSet(charactersIn: newValue)) {
            // Invalid case: new value contains non-numeric characters
            revertToLastValidValue()
            return
        }

        if newValue.count > 12 {
            // Invalid case: more than 12 characters
            revertToLastValidValue()
            return
        }

        if newValue.count > validatedPhoneNumber.count && (newValue.count == 3 || newValue.count == 7) {
            // If the user is adding characters, automatically append hyphens.
            // (But not if the user is deleting characters!)
            validatedPhoneNumber = "\(newValue)-"
            estimateModel.phoneNumber = validatedPhoneNumber
            return
        }

        // Valid case: new value passed all checks
        validatedPhoneNumber = newValue
    }

    private func revertToLastValidValue() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        estimateModel.phoneNumber = validatedPhoneNumber
    }
}

private struct ProjectDetailsInputView: View {
    @EnvironmentObject var estimateModel: EstimateModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(TokenizedStrings.projectDetails() + " *").bold()
            Text(TokenizedStrings.projectDetailsDescription()).allowsTightening(true)
            TextEditor(text: $estimateModel.projectDetails)
                .frame(height: 120)
                .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                #if os(iOS)
                .overlay(
                    RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemFill), lineWidth: 0.75)
                )
                #endif
        }
    }
}

struct EstimateFormView_Previews: PreviewProvider {
    static let estimateModel = EstimateModel()
    static let navigationModel = NavigationModel()

    static var previews: some View {
        EstimateFormView()
            .environmentObject(estimateModel)
            .environmentObject(navigationModel)
    }
}
