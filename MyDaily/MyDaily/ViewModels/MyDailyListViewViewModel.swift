//
//  MyDailyListViewViewModel.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 3.06.2024.
//

import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import UIKit

class MyDailyListViewViewModel: ObservableObject {
    @Published var items: [Plan] = []
    @Published var selectedPlanType: PlanType
    @Published var showingNewItemView: Bool = false
    @Published var showingShareSheet: Bool = false
    @Published var friends: [String] = [] // Arkadaş listesi
    @Published var isDataUpdated: Bool = false // Bu satırı ekleyin
    var planToShare: Plan?
    let userId: String
    private var db = Firestore.firestore()
    
    init(userId: String, initialPlanType: PlanType) {
        self.userId = userId
        self.selectedPlanType = initialPlanType
        fetchItems(for: initialPlanType)
        fetchFriends()
    }
    func fetchFriends() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            print("Bir hata oluştu.")
            return
        }
        
        // Friendship koleksiyonundan, usersEmail alanında current user's email'i içeren dökümanları çek
        db.collection("friendships")
            .whereField("usersEmail", arrayContains: currentUserEmail)
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
                
                guard let currentUserEmail = Auth.auth().currentUser?.email else {
                    print("Bir hata oluştu.")
                    return
                }
                
                var friends = [String]()
                for document in documents.documents {
                    if let usersEmail = document.data()["usersEmail"] as? [String] {
                        // Kendi emailimizi diziden çıkart ve geriye kalan emaili al
                        let friendEmail = usersEmail.filter { $0 != currentUserEmail }.first
                        
                        if let friendEmail = friendEmail {
                            friends.append(friendEmail)
                        }
                    }
                }
                self.friends = friends
            }
    }
    
    func fetchItems(for planType: PlanType) {
        let db = Firestore.firestore()
        db.collection("plans")
            .whereField("creatorId", isEqualTo: userId)
            .whereField("planType", isEqualTo: planType.rawValue)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                DispatchQueue.main.async {
                    self.items = documents.compactMap { doc in
                        try? doc.data(as: Plan.self)
                    }
                }
            }
    }
    func toggleIsDone(plan: Plan) {
        guard let planId = plan.id else { return }
        let db = Firestore.firestore()
        let newStatus = !(plan.isDone ?? false)
        db.collection("plans").document(planId).updateData(["isDone": newStatus]) { error in
            if error != nil {
                print("Error updating plan: (error)")
            } else {
                DispatchQueue.main.async {
                    if let index = self.items.firstIndex(where: { $0.id == planId }) {
                        self.items[index].isDone = newStatus
                    }
                }
            }
        }
    }
    
    func delete(id: String) {
        let db = Firestore.firestore()
        
        let collect = db.collection("plans").whereField("id", isEqualTo: id)
        collect.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching plan to delete: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No plan found with the provided ID to delete.")
                return
            }
            
            let document = documents[0]
            
            document.reference.delete { error in
                if let error = error {
                    print("Error deleting plan: \(error.localizedDescription)")
                } else {
                    print("Plan successfully deleted.")
                }
            }
        }
    }

    
    func sharePlan(plan: Plan) {
        self.planToShare = plan
        self.showingShareSheet = true
    }
    
    func performShare(with friends: [String]) {
        guard let plan = planToShare else { return }
        if friends.count == 0 { return }
        
        let db = Firestore.firestore()

        let collect = db.collection("plans").whereField("id", isEqualTo: plan.id ?? "")
        collect.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching plan: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No plan found with the provided ID.")
                return
            }
            
            // Assuming there is only one document with the given ID
            let document = documents[0]
            
            // Update the sharedWith field
            document.reference.updateData([
                "sharedWith": FieldValue.arrayUnion(friends)
            ]) { error in
                if let error = error {
                    print("Error sharing plan: \(error.localizedDescription)")
                } else {
                    print("Plan successfully shared with friends.")
                }
            }
        }

    }
}
