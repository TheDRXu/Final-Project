//
//  RegisterView.swift
//  DemoFire
//
//  Created by Dwayne Reinaldy on 5/27/22.
//

import SwiftUI
import FirebaseAuth

struct Background<Content: View>: View {
    private var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        Color.white
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .overlay(content)
    }
}

struct RegisterView: View {
    
    @State private var userEmail = ""
    @State private var userPass = ""
    @State private var userConfirmPass = ""
    @State private var userGender = ""
    @State private var alertMsg = ""
    @State private var showAlert = false
    @State private var showFLView = false
    @State private var myAlert = Alert(title: Text(""))
    @State private var selectedIndex = 0
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        
        Background{
        VStack{
            Text("Register")
                 .foregroundColor(Color("TextDark"))
                 .font(.largeTitle)
                 .offset(x:-100,y:-80)
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
                    text: $userPass, secure: true, isEmail: false
                )
            }
            
            HStack {
                if userPass != userConfirmPass {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                        .padding([.leading], 15)
                } else {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .padding([.leading], 15)
                }
                CustomTextField(
                    placeholder: Text("Confirm password: ").foregroundColor(Color.blue),
                    text: $userConfirmPass, secure: true, isEmail: false
                )
            }
            HStack(spacing:-45) {
                Button(action:{
                    if userEmail != "" && userPass != ""{
                        if userPass != userConfirmPass {
                            showAlertMsg(msg: "You're password are different. Check again!")
                        } else {
                            FireBase.shared.createUser(userEmail: userEmail, pw: userPass) {
                                (result) in
                                switch result {
                                case .success( _):
                                    showAlertMsg(msg: "User created")
                                    
                                case .failure(let errormsg):
                                    print("Sign up failed")
                                    switch errormsg {
                                    case .emailFormat:
                                        showAlertMsg(msg: "Please input correct email")
                                    case .emailUsed:
                                        showAlertMsg(msg: "Email is used by other user")
                                    case .pwtooShort:
                                        showAlertMsg(msg: "Password is at least 6 characters")
                                    case .others:
                                        showAlertMsg(msg: "Please register again")
                                    }
                                    break
                                }
                            }
                        }
                    }
                    else {
                        showAlertMsg(msg: "Username and Password can't be empty")
                    }
                }){
                    ButtonView(buttonText: "Register")
                }.alert(isPresented: $showAlert) { () -> Alert in
                    return myAlert
                }
                Image(systemName: "arrow.right.circle")
                    .foregroundColor(Color("Color1"))
            }
            .padding()
            .offset(x:80)
        }
        .fullScreenCover(isPresented: $showFLView, content: {
            FirstView(userEmail: userEmail, userPassword: userPass)
        })
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action:{self.presentationMode.wrappedValue.dismiss()}){
            HStack {
                Image(systemName: "chevron.left")
                Text("Return")
            }.foregroundColor(.black)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BgDark"))
        }
    }
    
    func changetoFirstView() -> Void {
        print(Auth.auth().currentUser!.uid)
        self.presentationMode.wrappedValue.dismiss()
        self.showFLView = true
    }
    
    func showAlertMsg(msg: String) -> Void {
        self.alertMsg = msg
        if alertMsg == "User created" {
            self.myAlert = Alert(title: Text("Successful"), message: Text(alertMsg), dismissButton: .cancel(Text("Set up your profile"), action:changetoFirstView))
            self.showAlert = true
        }
        else {
            self.myAlert = Alert(title: Text("Unsuccessful"), message: Text(alertMsg), dismissButton: .cancel(Text("There's problem")))
            self.showAlert = true
        }
    }
    
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

//fix the navigationLink back button gesture
extension UINavigationController: UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
            super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
