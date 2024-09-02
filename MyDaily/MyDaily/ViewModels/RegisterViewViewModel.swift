//
//  RegisterViewViewModel.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 3.06.2024.
//


import FirebaseFirestore
import FirebaseAuth
import Foundation

class RegisterViewViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?

    init() {}

    func register() {
        guard validate() else {
            errorMessage = "Lütfen tüm alanları doğru doldurduğunuzdan emin olun."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if error != nil {
                self?.errorMessage = "Hesap oluşturulamadı: (error.localizedDescription)"
                return
            }

            guard let userId = result?.user.uid else {
                self?.errorMessage = "Kullanıcı kimliği alınamadı."
                return
            }

            self?.insertUserRecord(id: userId)
        }
    }
    private func insertUserRecord(id: String) {

        let newUser = User(
            id: id,
            email: email.lowercased(),
            name: name,
            joined: Date().timeIntervalSince1970
        )
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(id)
            .setData(newUser.asDictionary()) { [weak self] error in
                if error != nil {
                    self?.errorMessage = "Kullanıcı verileri kaydedilemedi: (error.localizedDescription)"
                }
            }
    }
    private func validate() -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            return false
        }
        
        guard password.count >= 6 else {
            return false
        }
        
        return true
    }
}
