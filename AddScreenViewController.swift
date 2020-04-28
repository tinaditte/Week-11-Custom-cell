//
//  AddScreenViewController.swift
//  MyPersonalNotebook
//
//  Created by Tina Thomsen on 15/03/2020.
//  Copyright © 2020 Tina Thomsen. All rights reserved.
//
/*
Upload image from camera or photoroll to Cloudstorage
Upload image from an imageview, where the image was just dragged an image to storyboard

1) Download image from Cloud Storage (V)
2) Add image field to Note class (V)
3) Display image when note is shown (v)
4) Upload an image from image view to Cloud storage (v)
5) Use ios photoalbum to select an image (v)
6) Allow user to change current photo to a photo  (v)
*/

import UIKit
import FirebaseFirestore
import FirebaseStorage
import SDWebImage

class AddScreenViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
	
	//Outlets
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var imageView: UIImageView!
	
	//Fields
	var downloadURL: String?
	var rowNumber = 0
	var behaveAsNew = false
	var imagePicker = UIImagePickerController()
	private var newImageData: Data?
	
    override func viewDidLoad() {
		super.viewDidLoad()
		imagePicker.delegate = self //assign the object from this class to handle image picking return. Self reference the object
		
		if behaveAsNew == false{
			showNote()
		}else if behaveAsNew == true{
			print("new note mode entered in asvc")
		}
	}
	
	func config() {
		imageView.image = UIImage()
	}
	
	//IMAGE FUNCTIONS'
	
	@IBAction func downloadBtn(_ sender: Any) {
		imagePicker.sourceType = .photoLibrary
		imagePicker.delegate = self
		present(imagePicker, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let imageData = img.jpegData(compressionQuality: 0.8){
			self.imageView.image = img
			self.newImageData = imageData
		}
		let note = CloudStorage.getNoteAt(index: rowNumber)
		let noteid = note.id
		CloudStorage.uploadImgData(imageData: newImageData, noteid: noteid)
		self.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		imagePicker.dismiss(animated: true, completion: nil)
	}

	//NOTE FUNCTIONS
	@IBAction func saveNote(_ sender: Any) {
		if behaveAsNew == true{
			insertNewNote()
		}else if behaveAsNew == false{
			CloudStorage.updateNote(index: rowNumber, head: textField.text!, body: textView.text!, image: "empty", url: downloadURL ?? "empty")
		}
	}
	
	func showNote(){
		let note = CloudStorage.getNoteAt(index: rowNumber)
		let noteid = note.id
		let image = note.image
		let imageurl = URL(string: image)
		textField.text = note.head
		textView.text = note.body
		if note.image != "empty"{
			CloudStorage.downloadImage(noteid: noteid, iv: imageView)
			imageView.sd_setImage(with: imageurl, completed: nil)
		}else{
			print("Note is empty")
		}
	}
	
	func insertNewNote(){
		let newNote = CloudStorage.createNote(head: textField.text!, body: textView.text!, img: "empty", url: "")
		CloudStorage.list.append(newNote)
	}
}
