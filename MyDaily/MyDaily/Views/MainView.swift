//
//  MainView.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 2.06.2024.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()

    var body: some View {
        if viewModel.isSignedIn && !viewModel.currentUserId.isEmpty {
            accountView
        } else {
            LoginView()
        }
    }

    @ViewBuilder
    var accountView: some View {
        TabView {
            MyDailyView(userId: viewModel.currentUserId, initialPlanType: .daily)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            SharedPlansView(userId: viewModel.currentUserId)
                .tabItem {
                    Label("Planlar", systemImage: "list.bullet")
                }
            ProfileView(userId: viewModel.currentUserId, userEmail: viewModel.currentUserEmail)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
