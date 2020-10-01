//
//  newNoteTableViewCell.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit
import RealmSwift

class newNoteTableViewCell: UITableViewCell, UITextViewDelegate {
    
    let realm = try! Realm()

    @IBOutlet weak var lyricsField: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    
//    var callback: ((String) -> ())?
    
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        // make sure scroll is disabled
//        lyricsField.isScrollEnabled = false
//
//        lyricsField.delegate = self
//    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        let str = textView.text ?? ""
//        // tell the controller
//        callback?(str)
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
    }
    
    
}
