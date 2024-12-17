//
//  AccountView.swift
//
//  Created by Gaurav Bansal on 27/10/24.
//
import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel: AccountViewModel
    @FocusState private var keyboardFocused: Bool
    
    init(isLoggedIn: Binding<Bool>, updateUserData: @escaping (UserData) -> Void) {
        _viewModel = StateObject(wrappedValue: AccountViewModel(isLoggedIn: isLoggedIn, updateUserData: updateUserData))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text(viewModel.isLogin ? "Login" : "Sign Up")
                        .font(.largeTitle)
                        .padding()
                    
                    if !viewModel.isLogin {
                        CustomTextField(placeholder: "Name", text: $viewModel.formData.name)
                        CustomTextField(placeholder: "Age",   text: Binding(
                            get: { String(viewModel.formData.age) },
                            set: { viewModel.formData.age = Int($0) ?? 0 }
                        ))
                        CustomTextField(placeholder: "Contact", text: $viewModel.formData.contact)
                    }
                    
                    CustomTextField(placeholder: "Email", text: $viewModel.formData.email)
                    
                    CustomTextField(
                        placeholder: "Password",
                        text: $viewModel.formData.password,
                        isSecure: true
                    )
                    
                    CustomButton(action: {
                        viewModel.isLogin ? viewModel.handleLogin() : viewModel.handleSignup()
                    }, label: viewModel.isLogin ? "Login" : "Sign Up")
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .indigo))
                            .padding(.top)
                    }
                    
                    if let errorMessage = viewModel.alertMessage {
                        Text(errorMessage)
                            .foregroundColor(Color(.systemRed))
                            .padding()
                    }
                    
                    Button(action: { viewModel.isLogin.toggle() }) {
                        Text(viewModel.isLogin ? "Create an account" : "Already have an account?")
                            .foregroundColor(Color(.systemIndigo))
                    }
                }
                .padding()
                .alert(isPresented: $viewModel.isAlertPresented) {
                    Alert(title: Text("Alert"), message: Text(viewModel.alertMessage ?? ""), dismissButton: .default(Text("OK")))
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        
                        Button("Done") {
                            keyboardFocused = false
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
            }
        }
    }
}

