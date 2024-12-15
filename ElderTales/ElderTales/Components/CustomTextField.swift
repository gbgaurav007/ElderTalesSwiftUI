//
//  CustomTextField.swift
//  EcoRide
//
//  Created by Gaurav Bansal on 27/10/24.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @State private var showPassword: Bool = false

    var body: some View {
        HStack {
            if isSecure && !showPassword {
                SecureField(placeholder, text: $text)
                    .padding()
            } else {
                TextField(placeholder, text: $text)
                    .padding()
            }

            if isSecure {
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye" : "eye.slash")
                        .foregroundColor(Color.gray)
                }
            }
        }
        .padding(.horizontal)
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(.systemGray6), lineWidth: 1)
        )
        .padding(.top, 5)
    }
}
