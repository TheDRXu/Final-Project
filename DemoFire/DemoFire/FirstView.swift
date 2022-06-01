//
//  FirstView.swift
//  DemoFire
//
//  Created by Dwayne Reinaldy on 5/29/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import Kingfisher

struct FirstView: View {
    @State private var currentUser = Auth.auth().currentUser
    @State private var userDisplayName = ""
    @State private var userGender = ""
    @State private var userFirstLoginStr = ""
    @State private var userBirthday = Date()
    @State private var currentDate = Date()
    @State private var genderSelect = 0
    @State private var country = ""
    @State private var alertMsg = ""
    @State private var showAlert = false
    @State private var showContentView = false
    @State private var myAlert = Alert(title: Text(""))
    @State private var isShowPhotoLibrary = false
    @State private var image = UIImage()
    @State private var bool = false
    @State private var hairSelect = 0
    @State private var clothesSelect = 0
    @State private var faceSelect = 0
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var gender = ["male", "female"]
    var hair = ["bald","short","long"]
    var clothes = ["tshirt","sweater","turtleneck"]
    var face = ["lol","smile","angry"]
    let myDateFormatter = DateFormatter()
    let flgFormatter = DateFormatter()
    var userEmail: String
    var userPassword: String
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    VStack{
                        Text("Custom Character")
                        Spacer()
                            .frame(height:20)
                        ZStack{
                            Image("Hair"+String(hairSelect+1))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 80)
                                .offset(x:-5)
                            Image("Face"+String(faceSelect+1))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 65, height: 65)
                                .offset(x:3,y:5)
                        }
                        Image("Body"+String(clothesSelect+1))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 100)
                            .offset(x:-12,y:-5)
                        Button{
                            randomPic()
                        }label:{
                            Text("Random")
                        }
                        HStack{
                            Picker(selection: $hairSelect, label: Text("select hair")){
                                ForEach(hair.indices){ index in
                                    Text(hair[index])
                                }
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                        HStack{
                            Picker(selection: $clothesSelect, label: Text("select clothes")){
                                ForEach(clothes.indices){ index in
                                    Text(clothes[index])
                                }
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                        HStack{
                            Picker(selection: $faceSelect, label: Text("select face")){
                                ForEach(face.indices){ index in
                                    Text(face[index])
                                }
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                        
                    }
                    Group{
                        HStack{
                            Image(systemName: "person.fill")
                            TextField("Username: ", text: $userDisplayName)
                        }
                        HStack{
                            Image(systemName: "g.circle")
                            Text("Gender")
                            Spacer()
                            Picker(selection: $genderSelect, label: Text("Gender")) {
                                Text(gender[0]).tag(0)
                                Text(gender[1]).tag(1)
                            }.pickerStyle(SegmentedPickerStyle())
                            .frame(width: 100)
                            .shadow(radius: 5)
                        }
                        HStack{
                            Image(systemName: "calendar.circle")
                            DatePicker("Birthday", selection: $userBirthday, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                        }
                        TextField("Country: ", text: $country)
                    }
                    HStack{
                        Button(action:{
                            if userDisplayName == "" {
                                alertMsg = "Username can't be empty"
                                showAlert = true
                            }
                            else{
                                FireBase.shared.setUserDisplayName(userDisplayName: userDisplayName)
                                let newUser = UserData(userGender: gender[genderSelect], userBD: myDateFormatter.string(from: userBirthday), userFirstLogin: userFirstLoginStr, userCountry: country)
                                FireBase.shared.createUserData(ud: newUser, uid: currentUser!.uid) {
                                    (result) in
                                    switch result {
                                    case .success(let sucmsg):
                                        print(sucmsg)
                                        uploadPhoto()
                                        bool.toggle()
                                    case .failure(_):
                                        print("Picture can't be uploaded")
                                    }
                                }
                            }
                        }){
                            Text("Continue")
                                .font(.system(size: 27))
                                .bold()
                                .frame(width: 150, height: 50)
                                .foregroundColor(.red)
                        }
                        .alert(isPresented: $showAlert) { () -> Alert in
                            return self.myAlert
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BgDark"))
        .navigationTitle("User Settings")
        .onAppear{
            myDateFormatter.dateFormat = "y MMM dd"
            flgFormatter.dateFormat = "y MMM dd HH:mm"
            self.userFirstLoginStr = flgFormatter.string(from: currentDate)
        }
        .fullScreenCover(isPresented: $bool, content: {
            ContentView()
        })
        
    }

    func randomPic() -> Void {
        hairSelect = Int.random(in: 0...2)
        clothesSelect = Int.random(in: 0...2)
        faceSelect = Int.random(in: 0...2)
    }
    func uploadPhoto() -> Void {
        let text = "char"+String(hairSelect+1)+String(clothesSelect+1)+String(faceSelect+1)
        let charImage = UIImage(named: text)
        FireBase.shared.uploadPhoto(image: charImage!) { result in
            switch result {
            case .success(let url):
                print("Photo uploaded")
                FireBase.shared.setUserPhoto(url: url) { result in
                    switch result {
                    case .success(let msg):
                        print(msg)
                        FireBase.shared.userSignOut()
                    case .failure(_):
                        print("error")
                    }
                }
            case .failure(_):
               print("Photo can't be uploaded")
            }
        }
    }
}


struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView(userEmail: "", userPassword: "")
    }
}
