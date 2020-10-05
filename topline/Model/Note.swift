//
//  Note.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit
import RealmSwift

class Note: Object {
    
    @objc dynamic var title: String = "Untitled"
    @objc dynamic var id = Date()
    let lyrics = List<LyricLine>()
    let recordings = List<String>()
    
}
