//
//  HomeViewController.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit

class HomeViewController: UITableViewController {
    
    var notes: [Note] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 55
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = notes[indexPath.row].title

        return cell
    }

}
