//
//  NavigationModel.swift
//  WellsPrintAndDigital
//
//  Created by Steven Lamphear on 8/7/20.
//

import Combine
import SwiftUI

final class NavigationModel: ObservableObject {
    @Published var selectedTab = Tab.home
}

enum Tab {
    case home
    case products
    case estimate
    case contactUs
}
