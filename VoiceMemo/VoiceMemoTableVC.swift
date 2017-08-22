//
//  VoiceMemoTableVC.swift
//  VoiceMemo
//
//  Created by 付 旦 on 8/21/17.
//  Copyright © 2017 付 旦. All rights reserved.
//

import UIKit

class VoiceMemoTableVC: UITableViewController {
    var voiceRecords = [VoiceRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // query database here
        refreshData()
        tableView.addRefresh(self, with: #selector(refreshData))
        
    }
    
    func refreshData() {
        guard let voiceRecords = appD.dataManager.fetch() else {
            print("error querying database"); return
        }
        
        self.voiceRecords = voiceRecords.sorted(by: { (one, two) -> Bool in
            return one.creationDate as Date? ?? Date() > two.creationDate as Date? ?? Date()
        })
        tableView.reloadData()
        tableView.endRefresh()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voiceRecords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "voiceCell", for: indexPath) as! VoiceMemoTableViewCell
        let record = voiceRecords[indexPath.row]
        cell.nameLabel.text = record.fileName
        cell.descriptionLabel.text = (record.creationDate as Date?)?.toTimeString()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let record = voiceRecords[indexPath.row]
        guard let fileName = record.fileName else {
            print("invalid file name at index \(indexPath.row)"); return
        }
        VM.shared.playFile(fileName)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
                self.appD.dataManager.delete(self.voiceRecords.remove(at: indexPath.row))
                tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [delete]
    }
    
}

class VoiceMemoTableViewCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
}

