//
//  MyDailyListItemView.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 3.06.2024.
//

import SwiftUI
import FirebaseAuth

struct MyDailyListItemView: View {
    let plan: Plan

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(plan.title ?? "")
                    .font(.body)
                Text("\(Date(timeIntervalSince1970: plan.endDate ?? .nan).formatted(date: .abbreviated, time: .shortened))")
                    .font(.footnote)
                    .foregroundColor(Color.secondary)
                Text(plan.details ?? "")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                
                // Burada yeni etiket view'i ekleniyor
                Text(plan.category ?? "")
                    .font(.caption)
                    .padding(6)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top, 4) // Üstteki metinlerden biraz boşluk bırakmak için
            }
            Spacer()
            Button {
                // toggleIsDone fonksiyonunu burada tetikleyin
            } label: {
                Image(systemName: plan.isDone ?? false ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.blue)
            }
        }
    }
}
struct MyDailyListItemView_Previews: PreviewProvider {
    static var previews: some View {
        MyDailyListItemView(plan: Plan(ownerEmail: Auth.auth().currentUser?.email ?? "", id: "123", title: "Get milk", details: "Details here", startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, createdDate: Date().timeIntervalSince1970, isDone: false, planType: .daily, creatorId: "sampleUserId", sharedWith: [], category: "Günlük Hayat"))
    }
}
