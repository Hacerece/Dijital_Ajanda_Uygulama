//
//  TLButton.swift
//  MyDaily
//
//  Created by Hacer Ece Güllük on 5.06.2024.
//

import SwiftUI

struct TLButton: View {
    let title: String
    let background: Color
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(background)

                Text(title)
                    .foregroundColor(Color.white)
                    .bold()
            }
        }
    }
}

struct TLButton_Previews: PreviewProvider {
    static var previews: some View {
        TLButton(title: "Value",
                 background: .gray) {
            // Action
        }
    }
}
