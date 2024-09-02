//
//  Plan.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 11.08.2024.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

enum PlanType: String, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

struct Plan: Identifiable, Codable, Hashable {
    let ownerEmail: String?
    var id: String?
    let title: String?
    let details: String?
    let startDate: TimeInterval?
    let endDate: TimeInterval?
    let createdDate: TimeInterval?
    var isDone: Bool?
    let planType: PlanType?
    let creatorId: String?
    var sharedWith: [String]?
    let category: String?

    // Planın tamamlanma durumunu güncelleme fonksiyonu
    mutating func setDone(_ state: Bool) {
        isDone = state
    }

    // Planı paylaşma fonksiyonu
    mutating func shareWith(friendEmail: String) {
        if !(sharedWith?.contains(friendEmail) ?? false) {
            sharedWith?.append(friendEmail)
        }
    }

    // Bu modelin sözlüğe dönüştürülmesi için bir yardımcı fonksiyon
    func asDictionary() -> [String: Any] {
        return [
            "id": id ?? "",
            "title": title ?? "",
            "details": details ?? "",
            "startDate": startDate ?? .nan,
            "endDate": endDate ?? .nan,
            "createdDate": createdDate ?? .nan,
            "isDone": isDone ?? false,
            "planType": planType?.rawValue ?? PlanType.daily.rawValue,
            "creatorId": creatorId ?? "",
            "sharedWith": sharedWith ?? [],
            "category": category ?? "",
        ]
    }
}
