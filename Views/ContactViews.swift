//
//  ContactViews.swift
//  WellsPrintAndDigital
//
//  Created by Steven Lamphear on 6/3/22.
//

import Foundation
import SwiftUI

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
                #if os(iOS)
                PhoneNumberButton(font: .body).padding()
                #else
                PhoneNumberLabel(font: .body).padding()
                #endif
            }
        }
        .tabItem({
            Image(systemName: "envelope")
            Text(TokenizedStrings.contactUs())
        })
        .tag(Tab.contactUs)
    }
}

// MARK: - iOS-Specific implementation of email button

#if os(iOS)

import MessageUI

private struct EmailButton: View {
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false

    var body: some View {
        Button(action: {
            isShowingMailView.toggle()
        }, label: {
            Text(Constants.wellsEmailAddress)
        })
        .sheet(isPresented: $isShowingMailView, content: {
            mailView()
            .transition(.move(edge: .bottom))
            .animation(.default, value: isShowingMailView)
        })
    }

    private func mailView() -> some View {
        MFMailComposeViewController.canSendMail() ?
            AnyView(ComposeMailView(isPresented: $isShowingMailView, result: $result)) :
            AnyView(Text("Unable to send emails from this device"))
    }
}

private struct ComposeMailView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(isShowing: Binding<Bool>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer { isShowing = false }

            guard error == nil else {
                self.result = .failure(error!)
                return
            }

            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isPresented, result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ComposeMailView>) -> MFMailComposeViewController {
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = context.coordinator
        mailViewController.setToRecipients([Constants.wellsEmailAddress])
        return mailViewController
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<ComposeMailView>) { }
}

#endif

// MARK: - macOS-Specific implementation of email button

#if os(macOS)

private struct EmailButton: View {
    var body: some View {
        Button(action: {
            let service = NSSharingService(named: NSSharingService.Name.composeEmail)
            service?.recipients = [Constants.wellsEmailAddress]
            service?.perform(withItems: [])
        }, label: {
            Text(Constants.wellsEmailAddress)
        })
    }
}

#endif

struct ContactUsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactUsView()
    }
}
