//
//  MainViewViewModel.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 3.06.2024.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class MainViewViewModel: ObservableObject {
    @Published var currentUserId: String = ""
    @Published var currentUserEmail: String = ""

    private var handler: AuthStateDidChangeListenerHandle?

    init() {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.currentUserId = user.uid
                    self?.currentUserEmail = user.email ?? ""
                    self?.createUserProfile(user: user)
                } else {
                    self?.currentUserId = ""
                    self?.currentUserEmail = ""
                }
            }
        }
    }

    var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }

    func createUserProfile(user: FirebaseAuth.User) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("Kullanıcı profili zaten mevcut")
            } else {
                userRef.setData([
                    "id": user.uid,
                    "email": user.email ?? "",
                    "name": user.displayName ?? "Unknown",
                    "joined": Date().timeIntervalSince1970
                ]) { error in
                    if error != nil {
                        print("Kullanıcı profili oluşturulurken hata oluştu: (error.localizedDescription)")
                    } else {
                        print("Kullanıcı profili başarıyla oluşturuldu.")
                    }
                }
            }
        }
    }
}
