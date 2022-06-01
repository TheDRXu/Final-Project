//
//  UserView.swift
//  DemoFire
//
//  Created by Dwayne Reinaldy on 5/11/22.
//

import SwiftUI
import Kingfisher
import FirebaseAuth

struct UserView: View {
    
    init(){
        UITableView.appearance().backgroundColor = .clear
    }
    
    @State private var currentUser = Auth.auth().currentUser
    @State private var userPhotoURL = URL(string: "")
    @State private var showContentView = false
    @State private var currentUserData = UserData(id: "", userGender: "", userBD: "", userFirstLogin: "", userCountry: "")
    var body: some View {
        NavigationView{
            VStack{
                Form {
                    HStack{
                        Text("User information")
                            .font(.system(size: 27))
                            .bold()
                    }
                    .frame(height: 100)
                    HStack {
                        Spacer()
                        KFImage(userPhotoURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 150)
                        Spacer()
                    }
                    Group{
                        HStack {
                            Image(systemName: "person.crop.circle")
                            if currentUser?.displayName != nil {
                                Text("Username: " + (currentUser?.displayName)!)
                            } else {
                                Text("Username not found")
                            }
                        }
                        HStack{
                            Image(systemName: "g.circle")
                            Text("Gender: " + currentUserData.userGender)
                        }
                        HStack{
                            Image(systemName: "calendar")
                            Text("Birthday: " + currentUserData.userBD)
                        }
                        HStack{
                            Image(systemName: "globe")
                            Text("Country: " + currentUserData.userCountry)
                        }
                        HStack{
                            Image(systemName: "clock")
                            Text("Last Signed In: " + currentUserData.userFirstLogin)
                        }
                        HStack{
                            Image(systemName: "face.smiling")
                            Text("UID: " + currentUser!.uid)
                        }
                    }
                }
            }.onAppear{
                userPhotoURL = (currentUser?.photoURL)
                FireBase.shared.fetchUsers(){ result in
                    switch (result) {
                    case .success(let usersArray):
                        for u in usersArray {
                            if u.id == currentUser?.uid {
                                currentUserData = u
                                break
                            }
                        }
                    case .failure(_):
                        print("Photo can't be shown")
                    }
                }
            }
            .background(Color("BgDark"))
            .navigationBarItems(trailing: Button(action:{
                FireBase.shared.userSignOut()
                showContentView = true
            }){
                HStack{
                    Text("Log Out")
                }.font(.title3)
                .foregroundColor(.red)
            }.fullScreenCover(isPresented: $showContentView, content: {
                ContentView()
            }))
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
