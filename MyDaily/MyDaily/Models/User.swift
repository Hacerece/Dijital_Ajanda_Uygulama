//
//  User.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 3.06.2024.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    var id: String?
    var email: String?
    var name: String?
    var joined: TimeInterval?

    func asDictionary() -> [String: Any] {
        return [
            "id": id ?? "",
            "email": email ?? "",
            "name": name ?? "",
            "joined": joined ?? .nan,
        ]
    }
}
