//
//  EstimateModel.swift
//  WellsApp
//
//  Created by Steven Lamphear on 7/9/19.
//  Copyright © 2019 Steven Lamphear. All rights reserved.
//

import Combine
import SwiftUI

final class EstimateModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var emailAddress = ""
    @Published var projectDetails = ""
}
