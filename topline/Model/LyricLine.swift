//
//  Lyrics.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import Foundation
import UIKit
import RealmSwift

class LyricLine: Object {
    @objc dynamic var text: String = ""
    @objc dynamic var date = Date()
    var parent = LinkingObjects(fromType: Note.self, property: "lyrics")
}


