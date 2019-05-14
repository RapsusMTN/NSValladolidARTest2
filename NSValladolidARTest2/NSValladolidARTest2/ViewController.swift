//
//  ViewController.swift
//  NSValladolidARTest2
//
//  Created by Jorge Martín on 14/05/2019.
//  Copyright © 2019 Jorge Martín. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    
    @IBOutlet weak var sceneView: ARSCNView!
    
    private var hud:MBProgressHUD!
    
    var chair:SCNNode = SCNNode()
    
    //MARK: -Cycle App
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setARSceneInView()
        setARViewDelegateAndDebugOptions()
        registerTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Create and set the ARConfiguration
        let configuration = ARImageTrackingConfiguration()
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("No se han encontrado las imagenes")
        }
        configuration.trackingImages = referenceImages
        self.sceneView.session.run(configuration, options: [])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    //MARK: -Functions
    
    func registerTapGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        self.sceneView.addGestureRecognizer(pinchGesture)
    }
    
    @objc func pinched(recognizer: UIPinchGestureRecognizer) {
        
        if recognizer.state == .changed {
            
            guard let sceneView = recognizer.view as? ARSCNView else {
                return  }
            
            let touch = recognizer.location(in: sceneView)
            
            let hitResults = self.sceneView.hitTest(touch, options: nil)
            
            if let hitResult = hitResults.first {
                
                let chairNode = hitResult.node
                
                let pinchScaleX = Float(recognizer.scale) * chairNode.scale.x
                let pinchScaleY = Float(recognizer.scale) * chairNode.scale.y
                let pinchScaleZ = Float(recognizer.scale) * chairNode.scale.z
                
                
                chairNode.scale = SCNVector3(pinchScaleX,pinchScaleY,pinchScaleZ)
                let bounding: (SCNVector3,SCNVector3) = chairNode.boundingBox
                let x = (bounding.1.x - bounding.0.x) * chairNode.scale.x
                let y = (bounding.1.y - bounding.0.y) * chairNode.scale.y
                let z = (bounding.1.z - bounding.0.z) * chairNode.scale.z
                print("""
                    X = \(pinchScaleX) , Y = \(pinchScaleY), Z = \(pinchScaleZ) , \n
                    X: \(x) , Y: \(y) , Z: \(z)
                    """)
                recognizer.scale = 1
                
            }
        }
        
    }
    
    func setARSceneInView() {
        self.view.addSubview(self.sceneView)
        
        self.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
  
    func setARViewDelegateAndDebugOptions() {
        self.sceneView.delegate = self
        self.sceneView.showsStatistics = true
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.debugOptions = .showFeaturePoints
        
    }
    
    func get3dModel() -> SCNNode {
        let scene = SCNScene(named: "art.scnassets/chair.scn")
        let chairNode = scene?.rootNode.childNode(withName: "chair", recursively: true)
        chairNode?.scale = SCNVector3(20.0,20.0,20.0)
        return chairNode!
    }
    
    //MARK: -Actions
    
    
}

//MARK: - ARDelegate
extension ViewController:ARSCNViewDelegate {
    
    //Render the model
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARImageAnchor {
            
            DispatchQueue.main.async {
                self.hud = MBProgressHUD.showAdded(to: self.sceneView, animated: true)
                self.hud.label.text = "Imagen detectada"
                self.hud.hide(animated: true, afterDelay: 3.0)
            }
            
            self.chair = get3dModel()
            chair.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
            
            node.addChildNode(chair)
        }
    }
}


    
  




