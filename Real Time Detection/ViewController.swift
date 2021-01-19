//
//  ViewController.swift
//  Real Time Detection
//
//  Created by Jerry Lai on 2021-01-19.
//  Copyright © 2021 Jerry Lai. All rights reserved.
//

import UIKit
import AVKit
import Vision

class RealTimeDetectionController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let identifierLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        
        
        previewLayer.frame = view.bounds
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        view.addSubview(identifierLabel)
        
        identifierLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        identifierLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        identifierLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 32).isActive = true
        identifierLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from conn: AVCaptureConnection){
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else{return}
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let request = VNCoreMLRequest(model: model){
            (finishReq, err) in
            
            guard let results = finishReq.results as? [VNClassificationObservation] else{return}
            
            guard let firstObs = results.first else {return}
            
            print(firstObs.identifier, firstObs.confidence)
            
            DispatchQueue.main.async {
                self.identifierLabel.text = "\(firstObs.identifier): \(firstObs.confidence*100)%"
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }


}

class HomeViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tabBarItem.image = UIImage(systemName: "house")
    }
    
}


class objectTrackingController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
}
