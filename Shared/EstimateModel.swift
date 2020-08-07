//
//  EstimateModel.swift
//  WellsPrintAndDigital
//
//  Created by Steven Lamphear on 7/9/19.
//  Copyright © 2019 Steven Lamphear. All rights reserved.
//

import Combine
import SwiftUI

final class EstimateModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var emailAddress = "" {
        didSet {
            self.validEmailAddressEntered = self.emailAddress.isValidEmailAddress
        }
    }
    @Published var phoneNumber = "" {
        didSet {
            self.validPhoneNumberEntered = self.phoneNumber.isValidPhoneNumber
        }
    }
    @Published var projectDetails = ""
    @Published var validEmailAddressEntered = false
    @Published var validPhoneNumberEntered = false
}


//-------------------------
// MARK: Validation Helpers
//-------------------------

extension String {
    var isValidEmailAddress: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
    
    var isValidPhoneNumber: Bool {
        NSPredicate(format: "SELF MATCHES %@", "\\d{3}-\\d{3}-\\d{4}$").evaluate(with: self)
    }
}


//------------------------
// MARK: Utility Functions
//------------------------

extension EstimateModel {
    func reset() {
        self.firstName = ""
        self.lastName = ""
        self.emailAddress = ""
        self.phoneNumber = ""
        self.projectDetails = ""
    }
}
