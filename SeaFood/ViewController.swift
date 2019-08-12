//
//  ViewController.swift
//  SeaFood
//
//  Created by ad lay on 8/5/19.
//  Copyright © 2019 ad lay. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
        imageView.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("could not create ciImage from user picked image")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func detect(image: CIImage){
        print("in detect")
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("could not create VNCoreModel for inception")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("failed to classify results")
        }
            if let firstResult = results.first{
                if(firstResult.identifier.contains("hotdog")){
                self.navigationItem.title = "This is a hotdog."
                    
            }else {
                self.navigationItem.title = "(\(firstResult.identifier)) !hotdog"
                }
                
            }
            if(results.count > 0 ){
                if(self.matches(text: results[0].identifier, regex : "*hotdog*")){
                    print("this is a hotdog")
                }else{
                    print("I think this is a \(results[0].identifier)")
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])
        }
        catch{
            print(error)
        }
    }

    func matches(text: String , regex: String) -> Bool {
        return text.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

