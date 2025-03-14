//
//  ImmersiveView.swift
//  design-sprint-2025mar-template
//
//  Created by jenny on 3/6/25.
//  updated by Jeah on 3/14/25.

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Binding var score: Int
    @State private var verticalOffsets: [CGFloat] = []
    
    func ensureArraySize(index: Int) {
            // If the array is smaller than the index, add new elements to match the number of targets
            while verticalOffsets.count <= index {
                verticalOffsets.append(0)  // Add a default offset (can be randomized or set based on your game logic)
            }
        }
    
    var body: some View {
        HStack {
            VStack {
                Text("How many times can you hit the target?")
                    .font(.title)
                    .bold()
                    .padding(.top, 30)
                
                Text("Score: \(score)")
                    .font(.system(size: 36, weight: .bold))
                    .padding(20)
                    .background(Color.white.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.top, 10)
            }
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.5))
            
            Spacer()
            
           
                
                RealityView { content in
                    // Add the initial RealityKit content
                    if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                        content.add(immersiveContentEntity)
                        
                        // Put skybox here.  See example in World project available at
                        // https://developer.apple.com/
                    }
                }
            }
        }
    }
    
