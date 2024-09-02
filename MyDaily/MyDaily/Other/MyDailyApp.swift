//
//  MyDailyApp.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 2.06.2024.
//

import SwiftUI
import FirebaseCore

@main
struct MyDailyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainView() // ContentView yerine MainView kullanıyoruz.
        }
    }
}
