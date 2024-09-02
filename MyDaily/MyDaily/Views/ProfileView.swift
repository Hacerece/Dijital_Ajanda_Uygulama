//
//  ProfileView.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 3.06.2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {

    let userId: String
    let userEmail: String

    @ObservedObject var viewModel = ProfileViewViewModel()
    @State private var friendEmail: String = ""
    @State private var showingToast = false
    @State private var toastMessage = "Bir hata oluştu."
    @State private var showingDeleteAlert = false
    @State private var friendToDelete: String?
    @State private var myColor: Color = .red

    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    Section() {
                        if let user = viewModel.user, let name = user.name, let email = user.email, let date = user.joined {
                            Text("Adı: \(name)")
                            Text("Email: \(email)")
                            Text("Üyelik Tarihi: \(Date(timeIntervalSince1970: date).formatted(date: .abbreviated, time: .shortened))")
                        } else {
                            Text("Bir hata oluştu!")
                        }
                    }
                    
                    Section(header: Text("ARKADAŞ EKLE")) {
                        TextField("Arkadaşının Emailini Gir", text: $friendEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button("Arkadaş Ekle") {
                            addFriend()
                            viewModel.fetchFriends()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    Section(header: Text("ARKADAŞLAR")) {
                        if viewModel.friends.isEmpty {
                            Text("Henüz eklenmiş bir arkadaş yok.")
                                .foregroundColor(.gray)
                        } else {
                            List(viewModel.friends, id: \.self) { friend in
                                Text(friend)
                                    .onTapGesture {
                                        friendToDelete = friend
                                        showingDeleteAlert = true
                                    }
                            }
                        }
                    }
                    
                    Section {
                        Button("Oturumu Kapat") {
                            logOut()
                        }
                        .foregroundColor(.red)
                    }
                }
                .navigationTitle("Kullanıcı Bilgileri")
                .onAppear {
                    viewModel.fetchUser()
                    viewModel.fetchFriends()
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Arkadaşı Sil"),
                        message: Text("Bu arkadaşı silmek istediğinize emin misiniz?"),
                        primaryButton: .destructive(Text("Sil")) {
                            if let friend = friendToDelete {
                                viewModel.deleteFriend(email: friend) { isSuccess, message in
                                    toastMessage = message
                                    showingToast = true
                                    if isSuccess {
                                        myColor = .green
                                        friendEmail = ""
                                        viewModel.fetchUser()
                                        viewModel.fetchFriends()
                                    } else {
                                        myColor = .red
                                    }
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            ToastView(isShowing: $showingToast, message: toastMessage, backgroundColor: myColor)
        }
    }

    private func addFriend() {
        viewModel.addFriend(email: friendEmail) { success, message in
            toastMessage = message
            showingToast = true
            if success {
                myColor = .green
                friendEmail = ""
                viewModel.fetchUser()
                viewModel.fetchFriends()
            } else {
                myColor = .red
            }
        }
    }

    private func deleteFriend(email: String) {
        viewModel.deleteFriend(email: email) { success, message in
            toastMessage = message
            showingToast = true
            if success {
                myColor = .green
                viewModel.fetchUser()
                viewModel.fetchFriends()
            } else {
                myColor = .red
            }
        }
    }

    private func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Oturum kapatılamadı: \(error.localizedDescription)")
        }
    }
}
