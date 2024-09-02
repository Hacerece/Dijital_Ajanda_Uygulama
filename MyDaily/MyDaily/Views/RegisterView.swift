//
//  RegisterView.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 3.06.2024.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel = RegisterViewViewModel()

    var body: some View {
        VStack {
            HeaderView(title: "My Daily",
                       subtitle: "Hadi Başlayalım",
                       angle: 15,
                       background: .gray)
            TextField("Adı", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .padding(.top, 20)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Şifre", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            Button(action: {
                viewModel.register()
            }) {
                Text("Kayıt Ol")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.top, 20)
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            Spacer()
            VStack {
                Text("Hesabın Var Mı?")
                
                NavigationLink("Giriş Yap",
                               destination: LoginView())
                .navigationBarBackButtonHidden(true)
            }
            .padding(.bottom, 50)
            Spacer()
        }
        .padding()
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
