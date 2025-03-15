//
//  ImmersiveView.swift
//  GestureControl
//
//  Created by MedVR07 on 3/9/25.
//  updated by Jeah on 3/14/25.

import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

struct PhysicsBall: View {
    @State private var startingEntityPosition =
    SIMD3<Float> (x:0, y:1, z:0)
    @State private var lastFrameEntityPosition =
    SIMD3<Float> (x:0, y:1, z:0)
    @State private var currentEntityPosition =
    SIMD3<Float> (x:0, y:1, z:0)
    @State private var resetPosition = SIMD3<Float> (x:1.0, y:1.0, z: -1.5)
    @State private var targetStartPosition = SIMD3<Float> (x:0.0, y:2.0, z: -2.0)
    @State private var targetScaleMultiplier = Float(0.3)
    @State private var isDragging: Bool = false
    @State private var sphereRadius: Float = 0.3
    @State private var theSphereEntity : ModelEntity?
    @State private var theFloorEntity : ModelEntity?
    @State private var theTargetEntity : Entity?
    @State private var forceToApply : SIMD3<Float> = .zero
    @State private var subs: [EventSubscription] = []
    @Binding var selectedObject: String
    @Binding var ballScore: Int
    @State var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        RealityView{ content in
            if let targetContentEntity = try? await Entity(named: "target", in: realityKitContentBundle){
                
                targetContentEntity.position = targetStartPosition
                targetContentEntity.transform.rotation = simd_quatf (angle: -90, axis: SIMD3<Float>(x: 0, y: 1, z: 0))
                targetContentEntity.scale *= targetScaleMultiplier
                let targetBoxSize = SIMD3<Float>(x: 0.3, y: 1.6, z: 1.6)
                let targetShape = ShapeResource.generateBox(size: targetBoxSize)
                var targetPhysicsBody = PhysicsBodyComponent(
                    shapes: [targetShape],
                    density: 10_000
                )
                targetPhysicsBody.mode = .kinematic
                
                targetContentEntity.components.set(CollisionComponent(shapes: [targetShape]))
                
                targetContentEntity.components.set(targetPhysicsBody)
                theTargetEntity = targetContentEntity
                content.add(targetContentEntity)
                
                
            }
    
        }
        
        
        RealityView{ content in
            
            let sphereMesh = MeshResource.generateSphere(radius: sphereRadius)
            
            let material: SimpleMaterial
                        switch selectedObject {
                        case "Metalball":
                            material = SimpleMaterial(color: .red, isMetallic: true)
                        case "Plasticball":
                            material = SimpleMaterial(color: .systemTeal, isMetallic: false)
                        case "Glassball":
                            material = SimpleMaterial(color: .clear, isMetallic: false)
                        default:
                            material = SimpleMaterial(color: .red, isMetallic: true)
                        }
            
            let sphereEntity = ModelEntity(mesh:sphereMesh, materials: [material])
            theSphereEntity = sphereEntity
            let shape = ShapeResource.generateSphere(radius: sphereRadius)
            sphereEntity.position = resetPosition
            
            sphereEntity.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.3)])
            )
            
            var physicsBody = PhysicsBodyComponent(
                shapes: [shape],
                density: 10_000
            )
            let physicsMotion = PhysicsMotionComponent(
                linearVelocity: [0.0, 0.0, 0.0]
            )
            physicsBody.isAffectedByGravity = false
            
            sphereEntity.components.set(physicsBody)
            sphereEntity.components.set(physicsMotion)
            
            
            sphereEntity.components.set(InputTargetComponent())
            
            sphereEntity.components.set(HoverEffectComponent())
            
            content.add(sphereEntity)
            
            //also want a floor for the ball to bounce on
            let floorMesh = MeshResource.generateBox(width: 100, height: 0.01, depth: 100)
            let floorMaterial = SimpleMaterial(color: .clear, isMetallic: false)
            
            let floorEntity = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
            
            let floorShape = ShapeResource.generateBox(size: [100, 0.01, 100])
            floorEntity.position.x = 0.0
            floorEntity.position.y = 0.0
            floorEntity.position.z = 0.0
            floorEntity.components.set(CollisionComponent(shapes: [.generateBox(size: [100.0, 0.01, 100.0])]))
            var floorPhysicsBody = PhysicsBodyComponent(
                shapes: [floorShape],
                density: 10_000)
            floorPhysicsBody.isAffectedByGravity = false
            floorEntity.components.set(floorPhysicsBody)
            theFloorEntity = floorEntity
            content.add(floorEntity)
            
            let subscribe = content.subscribe(to: CollisionEvents.Began.self, on: theSphereEntity) { event in
                if(event.entityA == self.theFloorEntity || event.entityB == self.theFloorEntity){
                    print("Collision between ball and floor, I assume")
                    playCollisionSound()
                    theSphereEntity?.position = resetPosition
                    theSphereEntity?.physicsMotion?.linearVelocity = [0.0 , 0.0, 0.0]
                    theSphereEntity?.physicsBody?.isAffectedByGravity = false
                }
                else if(event.entityA == self.theTargetEntity || event.entityB == self.theTargetEntity){
                    
                    ballScore = ballScore + 1
                    
                    print("score is: " + ballScore.description)
                }
            }
            subs.append(subscribe)
            
        }.gesture(DragGesture().targetedToAnyEntity()
            .onChanged{ value in
                theSphereEntity?.physicsMotion?.linearVelocity = [0.0 , 0.0, 0.0]
                if isDragging == false {
                    startingEntityPosition = value.entity.position
                    
                    isDragging = true
                }
                currentEntityPosition = value.entity.position
                
            let gestureTranslation =
                value.convert(
                    value.gestureValue.translation3D,
                    from: .local,
                    to: .scene
                )
                forceToApply = normalize(currentEntityPosition -  lastFrameEntityPosition)
                lastFrameEntityPosition = value.entity.position
                value.entity.position =
                startingEntityPosition + gestureTranslation
                
            }.onEnded{value in
                isDragging=false
                theSphereEntity?.physicsMotion?.linearVelocity = forceToApply * 5
                theSphereEntity?.physicsBody?.isAffectedByGravity = true
                
            }
        )
        .hoverEffect{ effect, isActive, _ in
            effect.scaleEffect(isActive ? 1.05 : 1.0)
        }
        
    }
    func playCollisionSound() {
        guard let path = Bundle.main.path(forResource: "Shoop 2", ofType:"m4a") else {
            return }
        let url = URL(fileURLWithPath: path)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    
    }

