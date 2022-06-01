//
//  DemoFireApp.swift
//  DemoFire
//
//  Created by Dwayne Reinaldy on 5/11/22.
//

import SwiftUI
import Firebase
@main
struct DemoFireApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
