//
//  ToastView.swift
//  MyDaily
//
//  Created by Yakup Açış on 23.08.2024.
//

import SwiftUI

struct ToastView: View {
    @Binding var isShowing: Bool
    var message: String
    var duration: TimeInterval = 3.0
    var backgroundColor: Color = .red

    var body: some View {
        if isShowing {
            VStack {
                Text(message)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(backgroundColor)
                    .cornerRadius(8)
                    .shadow(radius: 10)
                    .transition(.move(edge: .top))
                    .zIndex(1)
                Spacer()
            }
            .padding(.top, 50)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
            .animation(.easeInOut, value: isShowing)
        }
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) { state in
            ToastView(isShowing: state, message: "An error occurred!", duration: 3)
        }
    }
}

// StatefulPreviewWrapper, binding'in çalışabilmesi için gerekli olan yapıdır.
struct StatefulPreviewWrapper<T: View>: View {
    @State private var value: Bool
    var content: (Binding<Bool>) -> T

    init(_ initialValue: Bool, content: @escaping (Binding<Bool>) -> T) {
        _value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
