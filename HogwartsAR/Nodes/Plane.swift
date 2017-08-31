//
//  Plane.swift
//  HogwartsAR
//
//  Created by Kalvin Loc on 8/15/17.
//  Copyright © 2017 Kalvin Loc. All rights reserved.
//

import ARKit
import SceneKit

final class Plane: SCNNode {

    let anchor: ARPlaneAnchor
    let planeGeometry: SCNPlane

    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))

        super.init()

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue.withAlphaComponent(0.4)

        planeGeometry.materials = [material]

        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)

        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)

        setTextureScale()
        addChildNode(planeNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Actions
extension Plane {

    func update(with anchor: ARPlaneAnchor) {
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)

        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        setTextureScale()
    }

    func setTextureScale() {
        let material = planeGeometry.materials.first!
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(planeGeometry.width), Float(planeGeometry.height), 1.0)
        material.diffuse.wrapS = .repeat

        material.diffuse.wrapT = .repeat
    }

}

