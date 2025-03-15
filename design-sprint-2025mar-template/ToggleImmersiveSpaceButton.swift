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
                        appModel.immersiveSpaceState = .inTransition
                        await dismissImmersiveSpace()
                        appModel.immersiveSpaceState = .closed
                        isInImmersiveSpace = false

                    case .closed:
                        appModel.immersiveSpaceState = .inTransition
                        switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                            case .opened:
                                isInImmersiveSpace = true
                            case .userCancelled, .error:
                                appModel.immersiveSpaceState = .closed
                                isInImmersiveSpace = false
                            @unknown default:
                                appModel.immersiveSpaceState = .closed
                                isInImmersiveSpace = false
                        }

                    case .inTransition:
                        break
                }
            }
        } label: {
            Text(isInImmersiveSpace ? "Go Back to Home" : "Start the Game")
        }
        .disabled(appModel.immersiveSpaceState == .inTransition)
        .animation(.none, value: isInImmersiveSpace)
        .fontWeight(.semibold)
    }
}
