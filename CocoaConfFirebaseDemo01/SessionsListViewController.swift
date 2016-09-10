//
//  SessionsListViewController.swift
//  CocoaConfFirebaseDemo01
//
//  Created by Chris Adamson on 9/2/16.
//  Copyright © 2016 Subsequently & Furthermore, Inc. All rights reserved.
//

import UIKit
import Firebase

class SessionsListViewController: UITableViewController {
    
    var firebaseSessions : FIRDatabaseReference?
    var firebaseHandle : UInt?
    
    var sessions : [Session] = []
    
    deinit {
        if let firebaseHandle = firebaseHandle {
            firebaseSessions?.removeObserver(withHandle: firebaseHandle)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseSessions = FIRDatabase.database().reference().child("sessions")
        
        firebaseHandle = firebaseSessions?.observe(FIRDataEventType.value, with: { [weak self] (snapshot) in
            self?.parseSessionsFrom(snapshot)
            self?.tableView.reloadData()
            })
        
        updateDetailPaneWith(nil)
    }
    
    private func parseSessionsFrom(_ snapshot: FIRDataSnapshot) {
        guard let fbSessions = snapshot.value as? [String : Any] else {
            return
        }
        
        sessions.removeAll()
        for (id, value) in fbSessions {
            if let sessionDict = value as? [String : Any],
                let session = Session(id: id, dict: sessionDict) {
                sessions.append(session)
            }
        }
    }
    
    private func updateDetailPaneWith(_ sessionMb: Session?) {
        if let splitVC = splitViewController,
            let sessionDetailVC = splitVC.viewControllers.last as? SessionDetailViewController {
            sessionDetailVC.session = sessionMb
        }
    }
    
    // MARK: table data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath) as! SessionTableViewCell
        cell.session = sessions[indexPath.row]
        return cell
    }
    
    
    // MARK: table delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let session = sessions[indexPath.row]
        NSLog ("tell splitView \(splitViewController) about session \(session)")
        updateDetailPaneWith(session)
    }
    
}
