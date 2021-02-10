//
//  FirestoreService.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/9/21.


import Foundation
import Firebase

class UserService: ObservableObject {
    @Published var user: TaskyUser?
    
    func fetchUserBy(id: String){
        Firestore.firestore().collection("users").document(id).getDocument { (docSnapshot, err) in
            if let err = err {
                print("Error fetching user \(id), error: \(err.localizedDescription)")
                return
            }
            
            self.user = try? docSnapshot?.data(as: TaskyUser.self)
            
            print("the user of \(id) is \(self.user)")
        }
    }
}
