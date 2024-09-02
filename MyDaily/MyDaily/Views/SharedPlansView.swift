//
//  SharedPlansView.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 6.06.2024.
//

import SwiftUI
import FirebaseAuth

struct SharedPlansView: View {
    var userId: String
    @State var userPlans: [Plan] = []
    @StateObject var viewModel: PlanViewModel
    
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: PlanViewModel(userId: userId))
        self.userId = userId
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.items.isEmpty {
                    Text("Henüz paylaşılmış bir plan yok.")
                        .foregroundColor(.gray)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List(viewModel.items) { plan in
                        if plan.sharedWith?.count != 1 {
                            ZStack(alignment: .topTrailing) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Plan: \(plan.title ?? "Bilinmiyor")")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Plan Detayı: \(plan.details ?? "Bilinmiyor")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Paylaşan: \(plan.ownerEmail ?? "Bilinmiyor")")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                    
                                    let sharedUsers = plan.sharedWith ?? []
                                    let usersToDisplay = sharedUsers.dropFirst()
                                    Text("Paylaşılan kullanıcılar: \(usersToDisplay.joined(separator: "\n"))")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Plan Başlangıç Tarihi: \(Date(timeIntervalSince1970: plan.startDate ?? .nan).formatted(date: .abbreviated, time: .shortened))")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Plan Bitiş Tarihi: \(Date(timeIntervalSince1970: plan.endDate ?? .nan).formatted(date: .abbreviated, time: .shortened))")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                    
                                    Text(plan.category ?? "")
                                        .font(.caption)
                                        .padding(6)
                                        .background(Color.purple)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .padding(.top, 4) // Üstteki metinlerden biraz boşluk bırakmak için
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    Date(timeIntervalSince1970: plan.endDate ?? .nan) < Date() ?
                                    Color.red : Color(UIColor.systemBackground)
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 4)
                                .listRowSeparator(.hidden)
                                
                                // Sağ üst köşeye todo image'i ekliyoruz
                                Image("todo")
                                    .resizable()
                                    .frame(width: 48, height: 48)  // Görüntünün boyutunu ayarlıyoruz
                                    .padding(8)  // Sağ üst köşe padding'i
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Paylaşılan Planlar")
            .onAppear {
                viewModel.fetchItems(for: .daily)
            }
        }
    }
}
