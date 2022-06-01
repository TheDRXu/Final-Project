//
//  ContentView.swift
//  DemoFire
//
//  Created by Dwayne Reinaldy on 5/11/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct ContentView: View {
    @State private var userEmail = ""
    @State private var userPassword = ""
    @State private var alertMsg = ""
    @State private var showAlert = false
    @State private var showView = false
    @State private var returnBool = false
    var body: some View {
        NavigationView{
            VStack{
                    VStack(spacing:0){
                        Text("HELLO")
                            .font(.largeTitle)
                            .foregroundColor(Color("TextDark"))
                        Text("Sign in to your account")
                            .foregroundColor(Color("TextDark"))
                    }
                    .offset(x:0,y:-40)
                    Spacer()
                Group{
                    HStack(spacing:0){
                        Image(systemName: "envelope.badge.fill")
                            .foregroundColor(Color("Color1"))
                            .padding([.leading], 15)
                        CustomTextField(
                            placeholder: Text("Email: ").foregroundColor(Color.blue),
                            text: $userEmail, secure: false, isEmail: true
                        )
                    }
                    HStack(spacing:0){
                        Image(systemName: "eye.slash.fill")
                            .foregroundColor(Color("Color1"))
                            .padding([.leading], 15)
                        CustomTextField(
                            placeholder: Text("Password: ").foregroundColor(Color.blue),
                            text: $userPassword, secure: true, isEmail: false
                        )
                    }
                }.offset(y:-40)
                HStack(spacing:-50){
                    Button(action:{
                        FireBase.shared.userSignIn(userEmail: userEmail, pw: userPassword){
                            (result) in
                            switch result {
                            case .success( _):
                                if let user = Auth.auth().currentUser {
                                    print("\(user.uid) Signed In!")
                                    FireBase.shared.fetchUsers(){
                                        (result) in
                                        switch result {
                                        case .success(let udArray):
                                            print("User sign in!")
                                            for u in udArray {
                                                if u.id == user.uid {
                                                    returnBool = true
                                                }
                                            }
                                            showView = true
                                            
                                        case .failure(_):
                                            print("User not found!")
                                            returnBool = false
                                        }
                                    }
                                } else {
                                    print("Sign in failed")
                                }
                            case .failure(let errormsg):
                                switch errormsg {
                                case .pwInvalid:
                                    alertMsg = "Wrong Password!"
                                    showAlert = true
                                case .noAccount:
                                    alertMsg = "User not found! Please register first!"
                                    showAlert = true
                                case .others:
                                    alertMsg = "Please enter correct email!"
                                    showAlert = true
                                }
                            }
                        }
                }
            ){
                        ButtonView(buttonText: "Log In")
                            .foregroundColor(Color("TextDark"))
                    }
                Image(systemName: "arrow.right.circle")
                    .foregroundColor(Color("Color1"))
                }.offset(x:80)
                    NavigationLink(destination: UserView(), isActive: $showView) {
                        EmptyView()
                    }
                
                
                Text("Don't have an account?")
                    .foregroundColor(Color("TextDark"))
                NavigationLink(
                    destination: RegisterView()){
                    ButtonView(buttonText: "Register")
                         
                }
                Spacer()
                
            }
            .background(
                Color("BgDark")
            )
            .alert(isPresented: $showAlert) { () -> Alert in
                return Alert(title: Text("Oops! Something wrong!"), message: Text(alertMsg),  dismissButton: .default(Text("OK")))
            }
            
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }
    var secure: Bool
    var isEmail: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if secure {
                SecureField("", text: $text, onCommit: commit)
                    .textFieldStyle(MyTextFieldStyle())
            } else {
                if isEmail {
                    TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                        .textFieldStyle(MyTextFieldStyle())
                        .keyboardType(.emailAddress)
                } else {
                    TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                        .textFieldStyle(MyTextFieldStyle())
                }
            }
            if text.isEmpty {
                placeholder
                    .offset(x: 40)
            }
        }
    }
}

struct MyTextFieldStyle: TextFieldStyle {
    var bgBlue = Color(red: 203/255, green: 217/255, blue: 228/255)
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .foregroundColor(.black)
        .padding(20)
        .background(bgBlue)
            .opacity(0.8)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color(red: 121/255, green: 124/255, blue: 177/255), lineWidth: 2)
        ).padding()
    }
}

struct ButtonView: View {
    var buttonText: String
    var body: some View {
        Text(buttonText)
            .font(.system(size: 25))
            .foregroundColor(Color("TextDark"))
            .frame(width: 160)
            .padding()
    }
}

