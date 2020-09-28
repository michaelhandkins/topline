//
//  ViewSongController.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit
import RealmSwift

class ViewSongController: UITableViewController {
    
    let realm = try! Realm()
    var song: Note? {
        didSet {
            print("Song assigned to controller")
            lyrics = song?.lyrics
            print(lyrics)
        }
    }
    
    var lyrics: List<String>?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "newNoteTableViewCell", bundle: nil), forCellReuseIdentifier: "lyricsCell")
        title = song?.title
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return song?.lyrics?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lyricsCell", for: indexPath) as! newNoteTableViewCell

        cell.lyricsField.text = "test"
        

        return cell
    }

}
