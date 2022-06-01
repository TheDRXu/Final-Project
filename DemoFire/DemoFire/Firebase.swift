//
//  Firebase.swift
//  DemoFire
//
//  Created by Dwayne Reinaldy on 5/27/22.
//


import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestoreSwift
import FirebaseFirestore

class FireBase{
    static let shared = FireBase()
    func createUser(userEmail: String, pw: String, completion: @escaping((Result<String, RegError>) -> Void)) {
        Auth.auth().createUser(withEmail: userEmail, password: pw) { result, error in
             guard let user = result?.user,
                   error == nil else {
                if (error?.localizedDescription == "The email address is badly formatted."){
                    completion(.failure(RegError.emailFormat))
                }
                else if(error?.localizedDescription == "The password must be 6 characters long or more."){
                    completion(.failure(RegError.pwtooShort))
                }
                else if(error?.localizedDescription == "The email address is already in use by another account."){
                    completion(.failure(RegError.emailUsed))
                }
                else {
                    completion(.failure(RegError.others))
                }
                return
             }
            print(user.email, user.uid)
            completion(.success(user.uid))
        }
    }

    func userSignIn(userEmail: String, pw: String, completion: @escaping((Result<String, LoginError>) -> Void)) {
        Auth.auth().signIn(withEmail: userEmail, password: pw) { result, error in
             guard error == nil else {
                print(error?.localizedDescription)
                if (error?.localizedDescription == "The password is invalid or the user does not have a password.") {
                    completion(.failure(LoginError.pwInvalid))
                }
                else if (error?.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted.") {
                    completion(.failure(LoginError.noAccount))
                }
                else {
                    completion(.failure(LoginError.others))
                }
                return
             }
            completion(.success("Success"))
        }
    }
    
    func userSignOut() -> Void {
        do {
            try Auth.auth().signOut()
            if Auth.auth().currentUser == nil {
                print("Sign Out successful")
            }
        }
        catch {
            print("Sign Out Unsuccessful")
        }
    }
    

    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
            
            let fileReference = Storage.storage().reference().child(UUID().uuidString + ".jpg")
            if let data = image.jpegData(compressionQuality: 0.9) {
                
                fileReference.putData(data, metadata: nil) { result in
                    switch result {
                    case .success(_):
                         fileReference.downloadURL(completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
    func setUserPhoto(url: URL, completion: @escaping((Result<String, NormalErr>) -> Void)) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.photoURL = url
        completion(.success("set user photo successful"))
        changeRequest?.commitChanges(completion: { error in
           guard error == nil else {
               print(error?.localizedDescription)
                completion(.failure(NormalErr.error))
               return
           }
        })
    }
    
    func createUserData(ud: UserData, uid: String, completion: @escaping((Result<String, NormalErr>) -> Void)) {
        let db = Firestore.firestore()
        do {
            try db.collection("Users_Data").document(uid).setData(from: ud)
            completion(.success("create user data successful"))
        } catch {
            completion(.failure(NormalErr.error))
            print(error)
        }
    }
    
    func setUserDisplayName(userDisplayName: String) -> Void {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = userDisplayName
        changeRequest?.commitChanges(completion: { error in
           guard error == nil else {
                print(error?.localizedDescription)
                print("there's problem with user display name")
                return
           }
        })
    }
    
    func fetchUsers (completion: @escaping((Result<[UserData], NormalErr>) -> Void)) {
        let db = Firestore.firestore()
        db.collection("Users_Data").getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            let users = snapshot.documents.compactMap { snapshot in
                try? snapshot.data(as: UserData.self)
                
            }
            completion(.success(users))
            if error?.localizedDescription != nil {
                completion(.failure(NormalErr.error))
            }
        }
    }
}

enum RegError: Error {
    case emailFormat
    case pwtooShort
    case emailUsed
    case others
}

enum LoginError: Error {
    case pwInvalid
    case noAccount
    case others
}

enum NormalErr: Error {
    case error
}

struct UserData: Codable, Identifiable {
    @DocumentID var id: String?
    let userGender: String
    let userBD: String
    let userFirstLogin: String
    let userCountry: String
}

var countries: [String] = []
