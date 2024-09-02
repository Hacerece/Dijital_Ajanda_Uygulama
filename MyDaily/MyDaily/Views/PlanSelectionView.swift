//
//  PlanSelectionView.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 21.08.2024.
//

import SwiftUI

struct PlanSelectionView: View {
    @ObservedObject var profileViewModel = ProfileViewViewModel()  // ViewModel bağlantısı sağlandı

    var body: some View {
        List(profileViewModel.friends, id: \.self) { friend in
            Text(friend)  // Arkadaşlar listeleniyor
        }
        .onAppear {
            profileViewModel.fetchFriends()  // Ekran açıldığında arkadaşlar yükleniyor
        }
    }
}
