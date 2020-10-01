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
    var parent = LinkingObjects(fromType: Note.self, property: "lyrics")
    let audio: Recording? = Recording()
}


