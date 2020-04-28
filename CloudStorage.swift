//
//  CloudStorage.swift
//  MyPersonalNotebook
//
//  Created by Tina Thomsen on 15/03/2020.
//  Copyright © 2020 Tina Thomsen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SDWebImage

class CloudStorage{
	
	static var list = [ Note ]()
	static let db = Firestore.firestore()
	static let storage = Storage.storage()
	static var downloadURL: String?
	private static let notes = "Notes"
	static var imageArr: [UIImage] = []
	
	static func downloadImage(noteid: String, iv: UIImageView){
		print("Download called...")
		let imgref = storage.reference(withPath: noteid) //get filehandler
		imgref.getData(maxSize: 900000000000000000) { (data, error) in
			if error == nil{
				print("Success downloading image ")
				let img = UIImage(data: data!)
				DispatchQueue.main.async {
					//prevents bg thread from interrupting main thread, that handles user input
					iv.image = img
				}
			}else{
				print("An error occureed when downloading image: \(error.debugDescription)")
			}
		}
	}
	
	static func uploadImgData(imageData: Data?, noteid: String){
		guard let value = imageData as Data? else {return}
		let storageRef = storage.reference(withPath: noteid)
		storageRef.putData(value, metadata: nil) { (metadata, error) in
			if let error = error{
				print("Error wihile uploading image data; \(error)")
				return
			}
			storageRef.downloadURL { (url, error) in
				if let error = error {
					print(error)
				}
				if let url = url{
					self.downloadURL = url.absoluteString
					self.saveImgToDB(noteid: noteid)
				}
			}
		}
	}
	
	static func saveImgToDB(noteid: String){
		db.collection(notes).document(noteid).updateData(["image" : downloadURL])
	}
	
	static func getSize() -> Int{
		return list.count
	}
	
	static func getNoteAt(index: Int) -> Note{
		return list[index]
	}
	
	static func startListener(tableView: UITableView){
		print("Listening has begun")
		db.collection(notes).addSnapshotListener{ (snap, error) in
			if error == nil {
				self.list.removeAll() //empty array or duplicates will happen
				for note in snap!.documents{
					let map = note.data()
					let head = map["head"] as! String
					let body = map["body"] as! String
					let image = map["image"] as? String ?? "empty"
					let url = map["url"] as? String ?? "empty"
					let newNote = Note(id: note.documentID, head:head, body:body, img:image, imgurl: url)
					self.list.append(newNote)
				}
				DispatchQueue.main.async {
					tableView.reloadData()
				}
				
			}
		}
	}

	static func deleteNote(id:String){
		let docRef = db.collection(notes).document(id)
		docRef.delete()
	}
	
	static func createNote(head: String, body: String, img: String, url: String) -> Note {
		var map = [String: String]()
		map["head"] = head
		map["body"] = body
		map["empty"] = img
		map["url"] = url
		
		let docRef = db.collection(notes).addDocument(data: map)
		
		
		let newNote = Note(id: docRef.documentID, head: head, body: body, img: img, imgurl: url )
		list.append(newNote)
		print(newNote)
		return newNote
	}
	
	static func updateNote(index: Int, head: String, body:String, image:String, url:String ){
		let note = list[index]
		
		let docRef = db.collection(notes).document(note.id)
		var map = [String:String]()
		map["head"] = head
		map["body"] = body
		map["image"] = image
		map["url"] = url
		docRef.setData(map)}
}
