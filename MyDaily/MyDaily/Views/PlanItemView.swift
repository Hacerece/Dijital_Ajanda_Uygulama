//
//  PlanItemView.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 16.08.2024.
//

import SwiftUI
import FirebaseAuth

struct PlanItemView: View {
    @ObservedObject var viewModel: PlanViewModel
    let plan: Plan

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(plan.title ?? "")
                    .font(.body)
                Text("\(Date(timeIntervalSince1970: plan.startDate ?? .nan).formatted(date: .abbreviated, time: .shortened)) - (Date(timeIntervalSince1970: plan.endDate).formatted(date: .abbreviated, time: .shortened))")
                    .font(.footnote)
                    .foregroundColor(Color.secondary)
                Text(plan.details ?? "")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            Spacer()
            Button {
                viewModel.toggleIsDone(plan: plan)
            } label: {
                Image(systemName: plan.isDone ?? false ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}
struct PlanItemView_Previews: PreviewProvider {
    static var previews: some View {
        PlanItemView(viewModel: PlanViewModel(userId: "sampleUserId"), plan: Plan(ownerEmail: Auth.auth().currentUser?.email ?? "" ,id: "123", title: "Get milk", details: "Details here", startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, createdDate: Date().timeIntervalSince1970, isDone: false, planType: .daily, creatorId: "sampleUserId", sharedWith: [], category: "Günlük Hayat"))
    }
}
