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
    
    let willChange = PassthroughSubject<EstimateModel, Never>()
    
    var firstName = "" {
        willSet {
            willChange.send(self)
        }
    }
    
    var lastName = "" {
        willSet {
            willChange.send(self)
        }
    }
    
    var emailAddress = "" {
        willSet {
            willChange.send(self)
        }
    }
    
    var projectDetails = "" {
        willSet {
            willChange.send(self)
        }
    }
}
