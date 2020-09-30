//
//  newNoteTableViewCell.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit

class newNoteTableViewCell: UITableViewCell {

    @IBOutlet weak var lyricsField: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    
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
