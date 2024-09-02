//
//  PlanViewModel.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 11.08.2024.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation

class PlanViewModel: ObservableObject {
    @Published var items: [Plan] = [] // 'items' olarak plans dizisini tanımlıyoruz
    @Published var showingNewItemView: Bool = false
    @Published var selectedPlanType: PlanType = .daily
    var userId: String
    private var db = Firestore.firestore() // Firestore referansı

    init(userId: String) {
        self.userId = userId
        fetchItems(for: selectedPlanType) // Başlangıçta selectedPlanType'ı kullanıyoruz
    }
    
    
    func fetchUserPlans(userId : String, completion: @escaping ([Plan]) -> Void) {
        let db = Firestore.firestore()
        
        
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let planIds = data?["plans"] as? [String] {
                    let plansRef = db.collection("plans")
                    plansRef.whereField("id", in: planIds).getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error fetching plans: \(error)")
                            completion([])
                        } else {
                            var plans: [Plan] = []
                            for document in querySnapshot!.documents {
                                let data = document.data()
                                let plan = Plan(
                                    ownerEmail: data["ownerEmail"] as? String ?? "",
                                    title: data["title"] as? String ?? "",
                                    details: data["details"]as? String ?? "",
                                    startDate: data["startDate"]as? TimeInterval ?? TimeInterval.pi,
                                    endDate: data["endDate"]as? TimeInterval ?? TimeInterval.infinity,
                                    createdDate: data["createdDate"]as? TimeInterval ?? TimeInterval.infinity,
                                    isDone: data["isDone"]as? Bool ?? true,
                                    planType: data["planType"] as? PlanType ?? .daily,
                                    creatorId: data["creatorId"] as? String ?? "",
                                    sharedWith: data["sharedWith"] as? [String] ?? [],
                                    category: data["category"] as? String
                                )
                                plans.append(plan)
                            }
                            completion(plans)
                        }
                    }
                } else {
                    completion([])
                }
            } else {
                completion([])
            }
        }
        
        
        
        
    }

    func fetchItems(for planType: PlanType) {
        let db = Firestore.firestore()
        
        db.collection("plans")
            .whereField("sharedWith", arrayContains: Auth.auth().currentUser?.email ?? "")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching plans: \(error.localizedDescription)")
                    return
                }
                
                // Planları Plan modeline dönüştürme ve items dizisine atama
                self.items = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Plan.self)
                } ?? []
            }
        db.collection("plans").whereField("sharedWith", arrayContains: Auth.auth().currentUser?.email ?? "")
            .getDocuments { snapshot, error in
                if let error { return }
                guard let documents = snapshot?.documents else { return }

                self.items = documents.compactMap { document in
                    try? document.data(as: Plan.self)
                }
            }
    }

    func toggleIsDone(plan: Plan) {
        guard let planId = plan.id else { return }
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
        db.collection("plans").document(id).delete { error in
            if error != nil {
                print("Error deleting plan: (error)")
            } else {
                DispatchQueue.main.async {
                    self.items.removeAll { $0.id == id }
                }
            }
        }
    }
    func sharePlan(plan: Plan, with friends: [String]) {
        guard let planId = plan.id else { return }
        
        db.collection("plans").document(planId).updateData([
            "sharedWith": FieldValue.arrayUnion(friends)
        ]) { error in
            if error != nil {
                print("Plan paylaşılırken hata oluştu: (error)")
            } else {
                print("Plan başarıyla paylaşıldı.")
            }
        }
    }
}
