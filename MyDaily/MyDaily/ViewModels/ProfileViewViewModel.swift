//
//  ProfileViewViewModel.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 3.06.2024.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation

class ProfileViewViewModel: ObservableObject {
    @Published var user: User?
    @Published var friends: [String] = []
    private var db = Firestore.firestore()
    private var userId: String = Auth.auth().currentUser?.uid ?? ""

    func fetchFriends() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("friendships")
            .whereField("user1Id", isEqualTo: currentUserId)
            .getDocuments { documents, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let documents = documents, !documents.isEmpty else {
                    print("Kullanıcı bulunamadı.")
                    self.friends = []
                    return
                }
                
                var friends = [String]()
                for document in documents.documents {
                    if let usersEmail = document.data()["usersEmail"] as? [String] {
                        let friendEmail = usersEmail.filter { $0 != Auth.auth().currentUser?.email }.first
                        if let friendEmail = friendEmail {
                            friends.append(friendEmail)
                        }
                    }
                }
                self.friends = friends
            }
    }


    func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let userData = try document.data(as: User.self)
                    DispatchQueue.main.async {
                        self.user = userData
                    }
                } catch {
                    print("Kullanıcı verisi alınırken hata oluştu: (error)")
                }
            } else {
                print("Kullanıcı bulunamadı")
            }
        }
    }

    func addFriend(email: String, completion: @escaping (Bool, String) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        if email.isEmpty {
            completion(false, "Lütfen bir kullanıcı giriniz.")
            return
        }
        
        if email == Auth.auth().currentUser?.email {
            completion(false, "Kendinizi arkadaş olarak ekleyemezsiniz.")
            return
        }
        
        // Mevcut arkadaşların listesini kontrol et
        if friends.contains(email) {
            completion(false, "Bu kullanıcı zaten arkadaş listenizde.")
            return
        }
        
        // Kullanıcıyı Firestore'da ara
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                completion(false, "Bir hata oluştu: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty, let userDoc = documents.first else {
                completion(false, "Kullanıcı bulunamadı.")
                return
            }
            
            let userId = userDoc.documentID
            
    
            let newFriendship = self.db.collection("friendships").document()
            newFriendship.setData([
                "user1Id": currentUserId,
                "user2Id": userId,
                "usersEmail": [Auth.auth().currentUser?.email ?? "", email],
                "createdAt": Timestamp()
            ]) { error in
                if let error = error {
                    completion(false, "Bir hata oluştu: \(error.localizedDescription)")
                } else {
                    self.friends.append(email)  // Yeni eklenen arkadaşı listeye ekleyin
                    completion(true, "Arkadaş başarıyla eklendi")
                }
            }
        }
    }

    func deleteFriend(email: String, completion: @escaping (Bool, String) -> Void) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            completion(false, "Bir hata oluştu.")
            return
        }
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { [self] snapshot, error in
            if let error = error {
                completion(false, "Bir hata oluştu: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty, let userDoc = documents.first else {
                completion(false, "Kullanıcı bulunamadı.")
                return
            }
            
            let friendId = userDoc.documentID
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }
            
            // Belgelerin ID'sini oluşturma
            let friendshipId1 = "\(currentUserId)_\(friendId)"
            let friendshipId2 = "\(friendId)_\(currentUserId)"

            // İlk arkadaşlık belgesini sil
            db.collection("friendships").document(friendshipId1).delete { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    completion(false, "İlk belge silinirken bir hata oluştu: \(error.localizedDescription)")
                } else {
                    // İkinci arkadaşlık belgesini sil
                    self.db.collection("friendships").document(friendshipId2).delete { error in
                        if let error = error {
                            completion(false, "İkinci belge silinirken bir hata oluştu: \(error.localizedDescription)")
                        } else {
                            // Başarıyla silindi, arkadaş listesini güncelle
                            if let index = self.friends.firstIndex(of: email) {
                                self.friends.remove(at: index)
                            }
                            self.fetchFriends()
                            completion(true, "Arkadaş başarıyla silindi.")
                        }
                    }
                }
            }
        }
    }
}
