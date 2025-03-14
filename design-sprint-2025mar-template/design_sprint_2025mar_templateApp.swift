//
//  design_sprint_2025mar_templateApp.swift
//  design-sprint-2025mar-template
//
//  Created by jenny on 3/6/25.
//  updated by Jeah on 3/14/25.

import SwiftUI

@main
struct design_sprint_2025mar_templateApp: App {

    @State private var appModel = AppModel()
    @State private var selectedObject = "Metalball"
    @State private var score: Int = 0

    var body: some Scene {
        WindowGroup {
            // Now `openImmersiveSpace` is accessed directly within ContentView
            ContentView(selectedObject: $selectedObject)
                .environment(appModel)
        }

        // ImmersiveSpace setup
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            // The immersive space content, passing the score and selectedObject
            PhysicsBall(selectedObject: $selectedObject, score: $score)
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
