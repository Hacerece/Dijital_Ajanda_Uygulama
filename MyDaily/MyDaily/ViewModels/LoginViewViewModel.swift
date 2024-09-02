//
//  LoginViewViewModel.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 3.06.2024.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class LoginViewViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""

    init() {}

    func login() {
        guard validate() else {
            return
        }

        Auth.auth().signIn(withEmail: email.lowercased(), password: password) { [weak self] authResult, error in
            if error != nil {
                self?.errorMessage = "Giriş yapılamadı: \(error?.localizedDescription ?? "Kullanıcı adınızı ve şifrenizi kontrol ediniz.")"
                return
            }

            // Başarılı giriş yaptıktan sonra kullanıcı bilgilerini alıyoruz
            guard let userId = authResult?.user.uid else {
                self?.errorMessage = "Kullanıcı kimliği alınamadı."
                return
            }

            self?.fetchUserRecord(userId: userId)
        }
    }
    private func fetchUserRecord(userId: String) {
            let db = Firestore.firestore()

            db.collection("users")
                .document(userId)
                .getDocument { [weak self] document, error in
                    if error != nil {
                        self?.errorMessage = "Kullanıcı verileri alınamadı: (error.localizedDescription)"
                        return
                    }

                    guard let data = document?.data() else {
                        self?.errorMessage = "Kullanıcı verisi bulunamadı."
                        return
                    }

                    // Kullanıcı verilerini işle
                    let name = data["name"] as? String ?? "Bilinmiyor"
                    print("Kullanıcı adı: (name)")

                }
        }
private func validate() -> Bool {
        errorMessage = ""
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Lütfen bütün boşlukları doldurun."
            return false
        }

        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Lütfen geçerli bir e-posta girin."
            return false
        }

        return true
    }
}
