//
//  ViewController.swift
//  Agora-Video-With-ARKit
//
//  Created by GongYuhua on 2017/12/27.
//  Copyright © 2017年 Agora.io All rights reserved.
//

import UIKit
import ARKit
import AgoraRtcEngineKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    fileprivate let agoraKit: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: <#Your AppId#>, delegate: nil)
        engine.setVideoProfile(.portrait360P, swapWidthAndHeight: false)
        engine.setChannelProfile(.liveBroadcasting)
        engine.setClientRole(.broadcaster)
        engine.enableVideo()
        return engine
    }()
    
    fileprivate let videoSource = ARVideoSource()
    fileprivate var unusedScreenNodes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        
        agoraKit.delegate = self
        agoraKit.setVideoSource(videoSource)
        agoraKit.joinChannel(byToken: nil, channelId: "agoraar", info: nil, uid: 0, joinSuccess: nil)
        
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            showUnsupportedDeviceError()
            return
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @IBAction func doSceneViewTapped(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        
        guard let result = sceneView.hitTest(location, types: .existingPlane).first else {
            return
        }
        
        let scene = SCNScene(named: "art.scnassets/displayer.scn")!
        let rootNode = scene.rootNode
        rootNode.simdTransform = result.worldTransform
        sceneView.scene.rootNode.addChildNode(rootNode)
        
        let displayer = rootNode.childNode(withName: "displayer", recursively: false)!
        let screen = displayer.childNode(withName: "screen", recursively: false)!
        
        unusedScreenNodes.append(screen)
    }
    
    private func showUnsupportedDeviceError() {
        // This device does not support 6DOF world tracking.
        let alertController = UIAlertController(
            title: "ARKit is not available on this device.",
            message: "This app requires world tracking, which is available only on iOS devices with the A9 processor or later.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let plane = SCNBox(width: CGFloat(planeAnchor.extent.x),
                           height: CGFloat(planeAnchor.extent.y),
                           length: CGFloat(planeAnchor.extent.z),
                           chamferRadius: 0)
        plane.firstMaterial?.diffuse.contents = UIColor.red
        
        let planeNode = SCNNode(geometry: plane)
        node.addChildNode(planeNode)
        planeNode.runAction(SCNAction.fadeOut(duration: 1))
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        videoSource.sendBuffer(frame.capturedImage, timestamp: frame.timestamp)
    }
}

extension ViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("error: \(errorCode.rawValue)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("warning: \(warningCode.rawValue)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("did join channel with uid:\(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didRejoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("did rejoin channel")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("did joined of uid: \(uid)")
        
        guard !unusedScreenNodes.isEmpty else {
            return
        }
        
        let screenNode = unusedScreenNodes.removeFirst()
        let renderer = ARVideoRenderer()
        renderer.renderNode = screenNode
        
        agoraKit.setRemoteVideoRenderer(renderer, forUserId: uid)
    }
}
