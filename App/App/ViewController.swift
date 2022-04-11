//
//  ViewController.swift
//  App
//
//  Created by Константин Вороненко on 11.04.22.
//

import UIKit
import RealityKit
import ARKit

enum AnchorName: String {
    case name = "rocky"
}

final class ViewController: UIViewController {
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        arView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = result.first {
            let anchor = ARAnchor(name: AnchorName.name.rawValue, transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            let alert = UIAlertController(title: "Move your camera", message: .none, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    private func setupARView() {
        arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)
    }
    
    private func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        anchors.forEach { anchor in
            if let anchorName = anchor.name,
               anchorName == AnchorName.name.rawValue {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}
