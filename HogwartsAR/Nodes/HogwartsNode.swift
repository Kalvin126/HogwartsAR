//
//  HogwartsNode.swift
//  HogwartsAR
//
//  Created by Kalvin Loc on 8/15/17.
//  Copyright © 2017 Kalvin Loc. All rights reserved.
//

import ARKit
import ModelIO
import SceneKit
import SceneKit.ModelIO

final class HogwartsNode {

    var scene: SCNScene!

    var scale: Double = 0.005 {
        didSet {
            updateScale(scale)
        }
    }

    init() {
        scene = SCNScene(named: "art.scnassets/Hogwarts.obj")!

        updateScale(scale)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Actions
extension HogwartsNode {

    func initPos(with anchor: ARPlaneAnchor) {
        scene.rootNode.position = SCNVector3(anchor.center.x, 0.1, anchor.center.z)
    }

    func updateScale(_ scale: Double) {
        scene.rootNode.scale = SCNVector3(scale, scale, scale)
    }

    func update(with anchor: ARPlaneAnchor) {
        scene.rootNode.position = SCNVector3(anchor.center.x, 0.1, anchor.center.z)
    }

}
