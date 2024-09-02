//
//  UnifiedView.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 2.07.2024.
//

import SwiftUI

struct UnifiedView: View {
    @ObservedObject var viewModel: PlanViewModel

    var body: some View {
        NavigationView {
            VStack {
                // Plan türünü seçmek için bir Picker (Günlük, Haftalık, Aylık)
                Picker("Select Plan Type", selection: $viewModel.selectedPlanType) {
                    Text("Daily").tag(PlanType.daily)
                    Text("Weekly").tag(PlanType.weekly)
                    Text("Monthly").tag(PlanType.monthly)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: viewModel.selectedPlanType) { newPlanType in
                    viewModel.fetchItems(for: newPlanType) // Seçilen plana göre planları getir
                }

                // Planları listelemek için ScrollView
                ScrollView {
                    VStack(spacing: 20) {
                        // Günlük Planlar
                        Section(header: Text("Daily Plans").font(.headline)) {
                            ForEach(viewModel.items.filter { $0.planType == .daily }) { plan in
                                PlanItemView(viewModel: viewModel, plan: plan)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .padding(.horizontal)
                                    .transition(.slide)
                            }
                        }

                        // Haftalık Planlar
                        Section(header: Text("Weekly Plans").font(.headline)) {
                            ForEach(viewModel.items.filter { $0.planType == .weekly }) { plan in
                                PlanItemView(viewModel: viewModel, plan: plan)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .padding(.horizontal)
                                    .transition(.slide)
                            }
                        }

                        // Aylık Planlar
                        Section(header: Text("Monthly Plans").font(.headline)) {
                            ForEach(viewModel.items.filter { $0.planType == .monthly }) { plan in
                                PlanItemView(viewModel: viewModel, plan: plan)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .padding(.horizontal)
                                    .transition(.slide)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Unified Plans")
        }
        .onAppear {
            viewModel.fetchItems(for: viewModel.selectedPlanType) // Sayfa açıldığında planları getir
        }
    }
}
