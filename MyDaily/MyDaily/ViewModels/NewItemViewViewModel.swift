//
//  NewItemViewViewModel.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 3.06.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import EventKit
import UIKit

class NewItemViewViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var startDate: Date = Date() // Başlangıç tarihi
    @Published var endDate: Date = Date() // Bitiş tarihi
    @Published var planType: PlanType = .daily
    @Published var showAlert: Bool = false
    @Published var description: String = ""
    @Published var selectedCategory: String = "Günlük Hayat" // Varsayılan kategori

    let categories = ["Ev", "Sağlık", "İş", "Eğitim", "Alışveriş", "Seyahat", "Spor/Hobi", "Toplantılar ve Randevular"]
    private let eventStore = EKEventStore()

    var canSave: Bool {
        return !title.isEmpty && endDate >= Date() // Bitiş tarihini kontrol ediyoruz
    }

    func save(userId: String, completion: @escaping () -> Void) {
        // Plan türünü güncelle
        updatePlanTypeBasedOnDates()
        addItemToFirestore(title: title, startDate: startDate, endDate: endDate, planType: planType, userId: userId, description: description) {
            // Firestore'a kaydedildikten sonra Apple Calendar'a ekleyin
            self.saveToCalendar(title: self.title, startDate: self.startDate, endDate: self.endDate) { success, error in
                if success {
                    print("Etkinlik başarıyla Apple Calendar'a eklendi.")
                } else {
                    print("Apple Calendar'a etkinlik eklenemedi: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                }
                completion()
            }
        }
    }


    // Apple Calendar'a etkinlik eklemek için izin isteyin ve etkinliği ekleyin
    func saveToCalendar(title: String, startDate: Date, endDate: Date, completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if let error = error {
                completion(false, error)
                return
            }

            if granted {
                // Etkinlik oluşturma ve kaydetme işlemi
                let event = EKEvent(eventStore: self.eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                event.notes = self.description
                
                do {
                    try self.eventStore.save(event, span: .thisEvent)
                    completion(true, nil)
                } catch let error {
                    completion(false, error)
                }
            } else {
                // Kullanıcı izni reddetti
                DispatchQueue.main.async {
                    self.showCalendarAccessAlert()
                }
                completion(false, NSError(domain: "CalendarAccessDenied", code: 1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı takvim erişimine izin vermedi."]))
            }
        }
    }

    private func showCalendarAccessAlert() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        let alert = UIAlertController(title: "Takvim Erişimi Gerekli", message: "Takvim etkinlikleri eklemek için takvim erişimine izin vermelisiniz. Lütfen Ayarlar'dan izin verin.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ayarlar'a Git", style: .default, handler: { (_) in
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
        }))

        // Uyarıyı göster
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alert, animated: true, completion: nil)
        }
    }

    private func addItemToFirestore(title: String, startDate: Date, endDate: Date, planType: PlanType, userId: String, description: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let newItem = Plan(
            ownerEmail: Auth.auth().currentUser?.email ?? "",
            id: UUID().uuidString,
            title: title,
            details: description,
            startDate: startDate.timeIntervalSince1970,
            endDate: endDate.timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            planType: planType,
            creatorId: userId,
            sharedWith: [Auth.auth().currentUser?.email ?? ""],
            category: selectedCategory
        )

        do {
            _ = try db.collection("plans").addDocument(from: newItem) { error in
                if let error = error {
                    print("Error adding item to Firestore: \(error.localizedDescription)")
                } else {
                    print("Veri başarıyla kaydedildi")
                    completion() 
                }
            }
        } catch {
            print("Error setting data to Firestore: \(error)")
        }
    }

    // Tarih aralığına göre plan türünü günceller
    func updatePlanTypeBasedOnDates() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        let daysBetween = components.day ?? 0

        if daysBetween == 0 {
            planType = .daily
        } else if daysBetween >= 1 && daysBetween <= 7 {
            planType = .weekly
        } else {
            planType = .monthly
        }
    }
}
