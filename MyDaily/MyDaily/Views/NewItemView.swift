//
//  NewItemView.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 3.06.2024.
//

import SwiftUI

struct NewItemView: View {
    @StateObject var viewModel = NewItemViewViewModel()
    @Binding var newItemPresented: Bool
    let userId: String
    var onSave: (() -> Void)?

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Başlık", text: $viewModel.title)
                        .textFieldStyle(DefaultTextFieldStyle())

                    TextField("Açıklama", text: $viewModel.description)
                        .textFieldStyle(DefaultTextFieldStyle())

                    // Kategori seçici
                    Picker("Etiket", selection: $viewModel.selectedCategory) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    // Tek bir DatePicker kullanarak başlangıç tarihini seçiyoruz
                    DatePicker("Başlangıç Tarihi", selection: $viewModel.startDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())

                    // Bitiş tarihini seçiyoruz, başlangıç tarihinden önce olmamalı
                    DatePicker("Bitiş Tarihi", selection: $viewModel.endDate, in: viewModel.startDate..., displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .onChange(of: viewModel.endDate) { newEndDate in
                            // Tarihler arasında seçim yapıldığında plan türünü güncelleriz
                            viewModel.updatePlanTypeBasedOnDates()
                        }

                    // Plan türünü otomatik olarak belirliyoruz
                    Text("Plan Türü: \(viewModel.planType.rawValue.capitalized)")
                        .padding()

                    Button("Kaydet") {
                        if viewModel.canSave {
                            viewModel.save(userId: userId, completion: onSave!)
                            newItemPresented = false
                        } else {
                            viewModel.showAlert = true
                        }
                    }
                    .padding()
                }
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(
                        title: Text("Hata"),
                        message: Text("Lütfen tüm alanları doldurun ve geçerli bir tarih aralığı seçin.")
                    )
                }
            }
            .navigationTitle("Yeni Plan")
        }
    }
}

struct NewItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemView(newItemPresented: .constant(true), userId: "sampleUserId")
    }
}
