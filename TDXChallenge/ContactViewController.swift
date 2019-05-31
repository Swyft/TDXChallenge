//
//  ContactViewController.swift
//  TDXChallenge
//
//  Created by David Fekke on 5/30/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import SalesforceSDKCore
import AVKit

class ContactViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var contactId: String = ""
    var imagePicker: UIImagePickerController!
    
    let firstNameTextView: UITextView = {
        let firstNameText = UITextView()
        firstNameText.text = ""
        
        firstNameText.translatesAutoresizingMaskIntoConstraints = false
        return firstNameText
    }()
    
    let lastNameTextView: UITextView = {
        let lastNameText = UITextView()
        lastNameText.text = ""
        
        lastNameText.translatesAutoresizingMaskIntoConstraints = false
        return lastNameText
    }()
    
    let addressTextView: UITextView = {
        let addressText = UITextView()
        addressText.text = ""
        
        addressText.translatesAutoresizingMaskIntoConstraints = false
        return addressText
    }()
    
    let emailTextView: UITextView = {
        let emailText = UITextView()
        emailText.text = ""
        
        emailText.translatesAutoresizingMaskIntoConstraints = false
        return emailText
    }()
    
    let phoneTextView: UITextView = {
        let phoneText = UITextView()
        phoneText.text = ""
        
        phoneText.translatesAutoresizingMaskIntoConstraints = false
        return phoneText
    }()
    
    let activateCameraButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Photo", for: .normal)
        button.addTarget(self, action: #selector(cameraButtonPressed), for: .touchUpInside)
        return button
    }()
    
    @objc func cameraButtonPressed() {
        print("Add Camera")
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            print("Could not select image")
            return
        }
        let imageData: Data = selectedImage.jpegData(compressionQuality: 0.0)!
        let uuid = NSUUID().uuidString
        let b64 = imageData.base64EncodedString()
        let fields = [
            "Name": uuid,
            "Body": b64,
            "ParentId":self.contactId
        ]
        //RestClient.shared.create("Attachment", fields: fields, onFailure: , onSuccess: nil)
        RestClient.shared.create("Attachment", fields: fields, onFailure: { err, arg  in
            print("Failure")
        }, onSuccess: { dict, response in
            print("Success")
        })
        
        //RestClient.shared.
        // print out the image size as a test
        
        print(selectedImage.size)
    }
    
    override func loadView() {
        super.loadView()
        self.title = "Contact"
        
        let soqlQuery = "SELECT Id, FirstName, LastName, MailingStreet, Email, Phone FROM Contact WHERE Id = '\(self.contactId)' LIMIT 10"
        let request = RestClient.shared.request(forQuery: soqlQuery)
        
        RestClient.shared.send(request: request, onFailure: { (error, urlResponse) in
            SalesforceLogger.d(type(of:self), message:"Error invoking: \(request)")
        }) { [weak self] (response, urlResponse) in
            
            guard let strongSelf = self,
                let jsonResponse = response as? Dictionary<String,Any>,
                let result = jsonResponse ["records"] as? [Dictionary<String,Any>]  else {
                    return
            }
            
            SalesforceLogger.d(type(of:strongSelf),message:"Invoked: \(request)")
            
            DispatchQueue.main.async {
                let myDict = result[0]
                if let firstName = myDict["FirstName"] {
                    self?.firstNameTextView.text = firstName as? String
                } else {
                    self?.firstNameTextView.text = ""
                }
                
                if let lastName = myDict["LastName"] {
                    self?.lastNameTextView.text = lastName as? String
                } else {
                    self?.lastNameTextView.text = ""
                }
                if let address = myDict["MailingStreet"] {
                    self?.addressTextView.text = address as? String
                } else {
                    self?.addressTextView.text = ""
                }
                if let email = myDict["Email"] {
                    self?.emailTextView.text = email as? String
                } else {
                    self?.emailTextView.text = ""
                }
                if let phone = myDict["Phone"] {
                    self?.phoneTextView.text = phone as? String
                } else {
                    self?.phoneTextView.text = ""
                }
                
            }
        }
        
    }
    
    private func layoutView() {
        let standardSpacing: CGFloat = 8.0
        
        view.backgroundColor = .white
        view.addSubview(firstNameTextView)
        view.addSubview(lastNameTextView)
        view.addSubview(activateCameraButton)
        view.addSubview(addressTextView)
        view.addSubview(emailTextView)
        view.addSubview(phoneTextView)
        
        firstNameTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: standardSpacing).isActive = true
        firstNameTextView.widthAnchor.constraint(equalToConstant: view.frame.size.width - standardSpacing).isActive = true
        firstNameTextView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        firstNameTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        lastNameTextView.topAnchor.constraint(equalTo: firstNameTextView.bottomAnchor).isActive = true
        lastNameTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: standardSpacing).isActive = true
        lastNameTextView.widthAnchor.constraint(equalToConstant: view.frame.size.width - standardSpacing).isActive = true
        lastNameTextView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addressTextView.topAnchor.constraint(equalTo: lastNameTextView.bottomAnchor).isActive = true
        addressTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: standardSpacing).isActive = true
        addressTextView.widthAnchor.constraint(equalToConstant: view.frame.size.width - standardSpacing).isActive = true
        addressTextView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        emailTextView.topAnchor.constraint(equalTo: addressTextView.bottomAnchor).isActive = true
        emailTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: standardSpacing).isActive = true
        emailTextView.widthAnchor.constraint(equalToConstant: view.frame.size.width - standardSpacing).isActive = true
        emailTextView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        phoneTextView.topAnchor.constraint(equalTo: emailTextView.bottomAnchor).isActive = true
        phoneTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: standardSpacing).isActive = true
        phoneTextView.widthAnchor.constraint(equalToConstant: view.frame.size.width - standardSpacing).isActive = true
        phoneTextView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        activateCameraButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: standardSpacing).isActive = true
        activateCameraButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        activateCameraButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activateCameraButton.topAnchor.constraint(equalTo: phoneTextView.bottomAnchor).isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutView()
        
//        session.sessionPreset = AVCaptureSession.Preset.photo
//        let backCamera =  AVCaptureDevice.default(for: .video)
//        var error: NSError?
//        var input: AVCaptureDeviceInput!
//        do {
//            input = try AVCaptureDeviceInput(device: backCamera!)
//        } catch let error1 as NSError {
//            error = error1
//            input = nil
//            print(error!.localizedDescription)
//        }
//        if error == nil && session.canAddInput(input) {
//            session.addInput(input)
//            stillImageOutput = AVCapturePhotoOutput()
//            if session.canAddOutput(stillImageOutput ?? nil) {
//                session.addOutput(stillImageOutput ?? nil)
//                session.startRunning()
//            }
//        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
