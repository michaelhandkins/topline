//
//  Note.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit
import RealmSwift

class Note: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var text: [String] = []
    
}
