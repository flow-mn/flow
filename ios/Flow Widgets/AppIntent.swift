//
//  AppIntent.swift
//  Flow Widgets
//
//  Created by Batmend Ganbaatar on 2025.10.24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Flow widget for entering transactions swiftly." }

    // An example configurable parameter.
//    @Parameter(title: "Favorite Emoji", default: "😃")
//    var favoriteEmoji: String
}
