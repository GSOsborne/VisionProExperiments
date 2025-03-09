//
//  ImmersiveView.swift
//  GestureControl
//
//  Created by MedVR07 on 3/9/25.
//

import SwiftUI
import RealityKit

struct PhysicsBall: View {
    @State private var currentEntityPosition =
    SIMD3<Float> (x:0, y:1, z:0)
    @State private var resetPosition = SIMD3<Float> (x:0, y:1.0, z: -1.5)
    @State private var isDragging: Bool = false
    @State private var sphereRadius: Float = 0.3
    @State private var theSphereEntity : ModelEntity?
    @State private var forceToApply : SIMD3<Float> = .zero
    @State private var subs: [EventSubscription] = []
    
    var body: some View {
        RealityView{ content in
            
            let sphereMesh = MeshResource.generateSphere(radius: sphereRadius)
            let material = SimpleMaterial(color: .red, isMetallic: true)
            let sphereEntity = ModelEntity(mesh:sphereMesh, materials: [material])
            theSphereEntity = sphereEntity
            let shape = ShapeResource.generateSphere(radius: sphereRadius)
            sphereEntity.position.x = 0.0
            sphereEntity.position.y = 1.0
            sphereEntity.position.z = -1.5
            
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
            content.add(floorEntity)
            
            let subscribe = content.subscribe(to: CollisionEvents.Began.self, on: theSphereEntity) { event in
                print("Collision between ball and floor, I assume")
                theSphereEntity?.position = resetPosition
                theSphereEntity?.physicsMotion?.linearVelocity = [0.0 , 0.0, 0.0]
                theSphereEntity?.physicsBody?.isAffectedByGravity = false
                                }
            subs.append(subscribe)
            
        }.gesture(DragGesture().targetedToAnyEntity()
            .onChanged{ value in
                theSphereEntity?.physicsMotion?.linearVelocity = [0.0 , 0.0, 0.0]
                if isDragging == false {
                    currentEntityPosition = value.entity.position
                    
                    isDragging = true
                }
                
            let gestureTranslation =
                value.convert(
                    value.gestureValue.translation3D,
                    from: .local,
                    to: .scene
                )
                forceToApply = gestureTranslation
                
                value.entity.position =
                currentEntityPosition + gestureTranslation
                
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
}

#Preview(immersionStyle:.automatic) {
    PhysicsBall()
}
