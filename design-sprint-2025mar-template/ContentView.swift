//
//  ContentView.swift
//  design-sprint-2025mar-template
//
//  Created by jenny on 3/6/25.
//  updated by Jeah on 3/14/25.

import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

// Background music 🎵
class AudioPlayerManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    
    func startBackgroundMusic() {
        if let path = Bundle.main.path(forResource: "backgroundmusic", ofType: "mp3") {
            do {
                let url = URL(fileURLWithPath: path)
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // loop
                audioPlayer?.play() // Start playing the music
            } catch {
                print("Error playing background music: \(error.localizedDescription)")
            }
        } else {
            print("Could not find backgroundmusic.mp3 in bundle.")
        }
    }
}


struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var isInImmersiveSpace = false
    @State private var score = 0
    @Binding var selectedObject: String
    
    
    var body: some View {
        HStack {
            VStack {
                if isInImmersiveSpace {
                    Spacer()
                                Text("How many times can you hit the target?🎯")
                                    .font(.title)
                                    .bold()
                                    .padding()

                                Text("Score: \(score)")
                                    .font(.system(size: 36, weight: .bold))
                                    .padding(20)
                                    .background(Color.white.opacity(0.4))
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                    .padding(.top, 30)
                    Spacer()
                    
                            } else {
                                
                    Spacer()
                    Text("Welcome to the Mini Game:\n Throw the Ball☄️")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 10)
                    
                    
                    Text("Press the start button below to enter immersive space\nwhere you can throw the ball and aim for the target.\nYour score will keep track of how well you match the target!")
                        .font(.body)
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 10)
                    
                } 
                    
                    // Button to start the game/enter the immersive space
                    ToggleImmersiveSpaceButton(isInImmersiveSpace: $isInImmersiveSpace)
                    Spacer()
                }
                
                VStack {
                    if !isInImmersiveSpace {
                        Spacer()
                        
                        // Ball Selection UI
                        Text("Pick your Ball")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 10)
                        
                        // Options - 3d models
                        RealityView { content in
                            addObject(to: content, selectedObject: selectedObject)
                        }
                        .frame(width: 100, height: 100)
                        .id(selectedObject) // Forces SwiftUI to reload RealityView
                        
                        // Picker for Ball Selection - buttons
                        Picker("Object", selection: $selectedObject) {
                            Text("Metal Ball").tag("Metalball")
                            Text("Plastic Ball").tag("Plasticball")
                            Text("Glass Ball").tag("Glassball")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 400)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                    }
                }
            }
            .padding()
            .onAppear {
                audioManager.startBackgroundMusic()
            }
            
            // Show immersive view when enabled
            if isInImmersiveSpace {
                ImmersiveView(score: $score)
                    .edgesIgnoringSafeArea(.all)
                
                
            }
        }
    }
    
    // Function to add objects to RealityKit scene
    func addObject(to content: RealityViewContent, selectedObject: String) {
        content.entities.forEach { content.remove($0) } // Remove previous entities
        
        let sphereMesh = MeshResource.generateSphere(radius: 0.03)
        
        // Metal Ball
        if selectedObject == "Metalball" {
            let material = SimpleMaterial(color: .red, isMetallic: true)
            let sphereEntity = ModelEntity(mesh: sphereMesh, materials: [material])
            content.add(sphereEntity)
            
            // Plastic Ball
        } else if selectedObject == "Plasticball" {
            let material = SimpleMaterial(color: .systemTeal, isMetallic: false)
            let sphereEntity = ModelEntity(mesh: sphereMesh, materials: [material])
            content.add(sphereEntity)
            
            // Glass Ball
        } else if selectedObject == "Glassball" {
            let material = SimpleMaterial(color: .clear, isMetallic: false)
            let sphereEntity = ModelEntity(mesh: sphereMesh, materials: [material])
            content.add(sphereEntity)
        }
    }
    
    

