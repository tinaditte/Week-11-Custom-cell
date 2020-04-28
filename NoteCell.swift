//
//  NoteCell.swift
//  MyPersonalNotebook
//
//  Created by Tina Thomsen on 28/04/2020.
//  Copyright © 2020 Tina Thomsen. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
	
	var vc = ViewController.self
	
	//Outlets
	@IBOutlet weak var noteCellImage: UIImageView!
	@IBOutlet weak var noteCellLabel: UILabel!
	
	func setNote(note: Note) {
		let noteid = note.id
		let image = note.image
		let url = URL(string: image)
		noteCellLabel.text = note.head
		
		if note.image != "empty"{
			CloudStorage.downloadImage(noteid: noteid, iv: noteCellImage)
			noteCellImage.sd_setImage(with: url, completed: nil)
		}else{
			print("No image for note")
		}
	}
}
