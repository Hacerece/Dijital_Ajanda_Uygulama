//
//  AddFriendView.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 2.07.2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddFriendView: View {
    @State private var email: String = ""
    @Environment(\.dismiss) var dismiss
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @ObservedObject var viewModel: ProfileViewViewModel

    var body: some View {
        VStack {
            TextField("Arkadaşının Emailini Gir", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Arkadaş Ekle") {
                addFriend()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Arkadaş Ekle")
    }

    private func addFriend() {
        viewModel.addFriend(email: email) { success, message in
            if success {
                successMessage = message
                // Arkadaş eklenince geri dön
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            } else {
                errorMessage = message
            }
        }
    }
}
