//
//  newNoteTableViewCell.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

//Wow! Thanks for the very thorough response! I really appreciate the wireframes and sample code you provided. I tried implementing these changes in several ways, starting with making my code as similar to the sample code provided, and still no dynamic height changes. Previously I had been setting the lyricsField delegate in the NoteViewController (which is the table view controller I’m trying to make this change on) and implementing textViewDidBeginEditing and textViewDidEndEditing functions. When I switched the lyricsField delegate to be the custom cell class (newNoteTableViewCell for me) as it was shown in the example, I then moved my textViewDidBeginEditing and textViewDidEndEditing functions to that class as well. I also made sure to add the callback variable, the didMoveToSuperview, and the textViewDidChange functions exactly as they were in the sample code. In the NoteViewController, I added the myData array up at the top and the cell.callback in the cellForRowAt, but instead of self.myData[indexPath.row] = str, I put
//
//```
//cell.callback = { str in
//            // update our data with the edited string
//            if self.myData.count > indexPath.row {
//                self.myData[indexPath.row] = str
//            } else {
//                self.myData.append(str)
//            }
//            // we don't need to do anything else here
//            // this will force the table to recalculate row heights
//            tableView.performBatchUpdates(nil)
//        }
//```
//
//because my myData array is starting off empty. The only difference that was made is that the scrolling stopped, but the cell still refused to adjust its height. What could I be missing at this point? I don’t have a height constraint on the textView. Here is the repo if you would have the time to take a look. I know that’s probably a lot to ask but I’m desperate to get this resolved. Thanks again for all of the help you’ve already provided.

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
