//
//  EventType.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 2.07.2024.
//

import Foundation

enum EventType: String, CaseIterable, Identifiable {
    case cinema = "Sinema"
    case coffee = "Kahve"
    case other = "Diğer"

    var id: String { self.rawValue }
    
    // İsteğe bağlı olarak her etkinlik türü için ikon, renk veya açıklama gibi özellikler ekleyebilirsiniz
    var description: String {
        switch self {
        case .cinema:
            return "Bir sinema etkinliği oluşturun."
        case .coffee:
            return "Bir kahve etkinliği oluşturun."
        case .other:
            return "Başka bir türde etkinlik oluşturun."
        }
    }
}

