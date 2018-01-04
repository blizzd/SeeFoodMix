//
//  ViewController.swift
//  SeeFoodMix
//
//  Created by Admin on 18.12.17.
//  Copyright © 2017 Ionut-Catalin Bolea. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    let version = "2017-12-18"
    
    var apiKey = ""
    var classifications : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
        shareButton.isHidden = true
        resultImage.isHidden = true
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            
            ////If your plist contain root as Dictionary
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                    if dic["BLUEMIX_API_KEY"] != nil {
                        apiKey = dic["BLUEMIX_API_KEY"] as! String
                        print("API KEY set")
                    } else {
                        fatalError("Incorrect plist file")
                    }
                }
            }
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            
            let failure = {(error:Error) in print(error.localizedDescription)}
            
            visualRecognition.classify(imageFile: fileURL, owners: nil, classifierIDs: nil, threshold: 0.6, language: "en", failure: failure, success: { (classifiedImages) in
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                self.classifications = []
                
                for index in 1..<classes.count {
                    self.classifications.append(classes[index].classification.lowercased())
                }
                print(self.classifications)
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                }
                
                if (self.classifications.contains("muffin")) {
                    DispatchQueue.main.async {
                       self.navigationItem.title = "Muffin!"
                       self.navigationController?.navigationBar.barTintColor = UIColor.brown
                       self.navigationController?.navigationBar.isTranslucent = false
                        // self.resultImage.isHidden = false
                       // self.resultImage.image = UIImage(named: "")
                       self.shareButton.isHidden = false
                    }
                    
                } else if (self.classifications.contains("chihuahua")) {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Chihuahua!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.yellow
                        self.navigationController?.navigationBar.isTranslucent = false
                        // self.resultImage.isHidden = false
                        // self.resultImage.image = UIImage(named: "")
                        self.shareButton.isHidden = false
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Most likely " + self.classifications.first!
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = true
                        // self.resultImage.isHidden = false
                        // self.resultImage.image = UIImage(named: "")
                        self.shareButton.isHidden = false
                    }
                    
                }
                
            })
            
        } else {
            print("There was an error picking an image")
        }
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let composeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            composeVC?.setInitialText("I found a "+navigationItem.title!)
            composeVC?.add(imageView.image)
            present(composeVC!, animated: true, completion: nil)
        } else {
            self.navigationItem.title = "Please login to Twitter"
        }
        
        
    }
    
}

