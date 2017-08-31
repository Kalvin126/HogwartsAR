//
//  ViewController.swift
//  HogwartsAR
//
//  Created by Kalvin Loc on 8/15/17.
//  Copyright © 2017 Kalvin Loc. All rights reserved.
//

import UIKit
import SceneKit
import SceneKit.ModelIO
import ModelIO
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!

    @IBOutlet weak var scaleStepper: UIStepper!
    @IBOutlet weak var scaleLabel: UILabel!

    var planes = [UUID: Plane]()
    let hogwarts = HogwartsNode()

    let light = SCNLight()

    var isPlaneDetectingEnabled = true {
        didSet {
            guard let config = sceneView.session.configuration as? ARWorldTrackingConfiguration else { return }

            config.planeDetection = isPlaneDetectingEnabled ? .horizontal : []

            sceneView.session.run(config)
        }
    }

    var isPlaneHidden = false {
        didSet {
            planes.values.forEach {
                $0.isHidden = isPlaneHidden
            }
        }
    }

    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.showsStatistics = true

        sceneView.autoenablesDefaultLighting = false
        sceneView.automaticallyUpdatesLighting = true

        sceneView.scene = SCNScene()

        updateScaleLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true

        insertSpotLight(at: SCNVector3Make(0.0, 0.5, 0.0))

        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

}

// MARK: - Action
extension ViewController {

    // MARK: Update UI

    fileprivate func updateScaleLabel() {
        scaleLabel.text = "Scale: \(hogwarts.scale)x"
    }

    // MARK: Lighting

    fileprivate func insertSpotLight(at position: SCNVector3) {
        light.type = .omni
        light.spotInnerAngle = 45.0
        light.spotOuterAngle = 45.0

        let spotNode = SCNNode()
        spotNode.light = light
        spotNode.position = position

        spotNode.eulerAngles = SCNVector3Make(-Float.pi/2.0, 0.0, 0.0)

        sceneView.scene.rootNode.addChildNode(spotNode)
    }

}

// MARK: - Events
extension ViewController {

    @IBAction func tappedPlaneDetectionSwitch(_ sender: UISwitch) {
        isPlaneDetectingEnabled = sender.isOn
    }

    @IBAction func tappedShowPlaneSwitch(_ sender: UISwitch) {
        isPlaneHidden = !sender.isOn
    }

    @IBAction func scaleStepperChanged(_ sender: UIStepper) {
        hogwarts.scale = sender.value

        updateScaleLabel()
    }

}

// MARK: - ARSessionObserver
extension ViewController {
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        let plane = Plane(anchor: planeAnchor)
        planes[anchor.identifier] = plane

        if planes.count == 1 {
            node.addChildNode(hogwarts.scene.rootNode)
        }

        node.addChildNode(plane)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        guard let plane = planes[anchor.identifier] else { return }

        plane.update(with: planeAnchor)
        hogwarts.update(with: planeAnchor)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let estimate = sceneView.session.currentFrame?.lightEstimate else { return }

        light.intensity = estimate.ambientIntensity
    }

}
