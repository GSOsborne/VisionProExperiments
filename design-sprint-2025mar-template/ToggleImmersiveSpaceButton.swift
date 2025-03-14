//
//  ToggleImmersiveSpaceButton.swift
//  design-sprint-2025mar-template
//
//  Created by jenny on 3/6/25.
//  updated by Jeah on 3/14/25.

import SwiftUI

struct ToggleImmersiveSpaceButton: View {

    @Environment(AppModel.self) private var appModel

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    @Binding var isInImmersiveSpace: Bool

    var body: some View {
        Button {
            Task { @MainActor in
                switch appModel.immersiveSpaceState {
                    case .open:
                        // Transition to closed state
                        appModel.immersiveSpaceState = .inTransition
                        await dismissImmersiveSpace()
                        // Don't set immersiveSpaceState to .closed because there
                        // are multiple paths to ImmersiveView.onDisappear().
                        // Only set .closed in ImmersiveView.onDisappear().
                        appModel.immersiveSpaceState = .closed

                    case .closed:
                        // Transition to open state
                        appModel.immersiveSpaceState = .inTransition
                        switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                            case .opened:
                            // Don't set immersiveSpaceState to .open because there
                            // may be multiple paths to ImmersiveView.onAppear().
                            // Only set .open in ImmersiveView.onAppear().
                                break
                            case .userCancelled, .error:
                            // On error, we need to mark the immersive space
                            // as closed because it failed to open.
                                appModel.immersiveSpaceState = .closed
                            @unknown default:
                                appModel.immersiveSpaceState = .closed
                        }

                    case .inTransition:
                        // Avoid triggering actions if already in transition
                        break
                }
            }
        } label: {
            Text(appModel.immersiveSpaceState == .open ? "Go Back to Home" : "Start the Game")
        }
        .disabled(appModel.immersiveSpaceState == .inTransition)
        .animation(.none, value: 0)
        .fontWeight(.semibold)
    }
}
