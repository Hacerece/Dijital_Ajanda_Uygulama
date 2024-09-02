//
//  MyDailyView.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 3.06.2024.
//


import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct MyDailyView: View {
    @StateObject var viewModel: MyDailyListViewViewModel
    
    
    init(userId: String, initialPlanType: PlanType) {
        _viewModel = StateObject(wrappedValue: MyDailyListViewViewModel(userId: userId, initialPlanType: initialPlanType))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Plan Türü", selection: $viewModel.selectedPlanType) {
                    Text("Günlük").tag(PlanType.daily)
                    Text("Haftalık").tag(PlanType.weekly)
                    Text("Aylık").tag(PlanType.monthly)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: viewModel.selectedPlanType) { newPlanType in
                    viewModel.fetchItems(for: newPlanType)
                }
                
                if viewModel.items.isEmpty {
                    Spacer()
                    if viewModel.selectedPlanType == .daily {
                        Text("Henüz hiç günlük plan oluşturmadınız")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    } else if viewModel.selectedPlanType == .weekly {
                        Text("Henüz hiç haftalık plan oluşturmadınız")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    } else if viewModel.selectedPlanType == .monthly {
                        Text("Henüz hiç aylık plan oluşturmadınız")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Henüz hiç plan oluşturmadınız")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    List(viewModel.items) { plan in
                        MyDailyListItemView(plan: plan)
                            .swipeActions {
                                Button("Sil") {
                                    viewModel.delete(id: plan.id ?? "")
                                }
                                .tint(.red)
                                Button("Paylaş") {
                                    viewModel.sharePlan(plan: plan)
                                }
                                .tint(.orange)
                            }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .onAppear {
                viewModel.fetchFriends()
            }
            .navigationTitle("Yapılacaklar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingNewItemView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingNewItemView) {
                NewItemView(newItemPresented: $viewModel.showingNewItemView, userId: viewModel.userId) {
                    viewModel.fetchItems(for: viewModel.selectedPlanType)
                }
            }
            .sheet(isPresented: $viewModel.showingShareSheet) {
                SharePlanView(viewModel: viewModel)
            }
        }
    }
}
struct SharePlanView: View {
    @ObservedObject var viewModel: MyDailyListViewViewModel
    @State private var selectedFriends: [String] = []
    @State private var showErrorToast: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if getFriendList().isEmpty {
                    Text("Henüz hiç arkadaşınız yok.")
                        .foregroundColor(.gray)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List {
                        ForEach(getFriendList(), id: \.self) { friend in
                            MultipleSelectionRow(title: friend, isSelected: selectedFriends.contains(friend)) {
                                if selectedFriends.contains(friend) {
                                    selectedFriends.removeAll { $0 == friend }
                                } else {
                                    selectedFriends.append(friend)
                                }
                            }
                        }
                    }
                }

                ToastView(isShowing: $showErrorToast, message: "Henüz hiç arkadaşınız yok!", backgroundColor: .red)
            }
            .navigationTitle("Arkadaş Seçimi")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Paylaş") {
                        if selectedFriends.isEmpty {
                            withAnimation {
                                showErrorToast = true
                            }
                        } else {
                            viewModel.performShare(with: selectedFriends)
                            viewModel.showingShareSheet = false
                        }
                    }
                }
            }
        }
    }

    // Bu fonksiyon, arkadaş listenizi getirir
    func getFriendList() -> [String] {
        
        let friendsEmail = viewModel.friends
        return friendsEmail
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
