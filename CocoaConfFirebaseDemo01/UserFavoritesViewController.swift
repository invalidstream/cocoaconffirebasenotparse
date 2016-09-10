//
//  UserFavoritesViewController.swift
//  CocoaConfFirebaseDemo01
//
//  Created by Chris Adamson on 9/2/16.
//  Copyright © 2016 Subsequently & Furthermore, Inc. All rights reserved.
//

import UIKit
import Firebase

private struct FavoriteItem {
    let favoriteId : String
    let title : String
}

class UserFavoritesViewController: UITableViewController {

    private var firebaseSessions : FIRDatabaseReference?
    
    private var firebaseAttendees : FIRDatabaseReference?
    private var firebaseHandle : UInt?
    private var firebaseUser : FIRDatabaseReference?

    private var favoriteTitles : [FavoriteItem] = []
    
    @IBOutlet var editBarButtonItem: UIBarButtonItem!

    deinit {
        if let firebaseHandle = firebaseHandle {
            firebaseSessions?.removeObserver(withHandle: firebaseHandle)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firebaseSessions = FIRDatabase.database().reference().child("sessions")
        
        // TODO: this doesn't need to be a property
        firebaseAttendees = FIRDatabase.database().reference().child("attendees")
        
        var userId : String // TODO: don't need?
        if let oldId = UserDefaults.standard.string(forKey: "userId") {
            userId  = oldId
            firebaseUser = firebaseAttendees?.child(oldId)
        } else {
            firebaseUser = firebaseAttendees?.childByAutoId()
            let newId = firebaseUser?.key
            userId = newId!
            let firebaseUserName = firebaseUser?.child("name")
            firebaseUserName?.setValue("Foo Bar")
            UserDefaults.standard.setValue(newId, forKey: "userId")
            UserDefaults.standard.synchronize()
        }
        
        let firebaseUserFavorites = firebaseUser?.child("favorites")
        firebaseHandle = firebaseUserFavorites?.observe(FIRDataEventType.value, with: { [weak self] (snapshot) in
            self?.parseFavoritesFrom(snapshot)
        })

    }

    private func parseFavoritesFrom(_ snapshot: FIRDataSnapshot) {
        guard let fbFavorites = snapshot.value as? [String : Any] else {
            return
        }
        
        favoriteTitles.removeAll()
        for (sessionId, _) in fbFavorites {
            firebaseSessions?.child(sessionId).child("title").observeSingleEvent(of: FIRDataEventType.value, with: { [weak self] snapshot in
                if let title = snapshot.value as? String {
                    self?.favoriteTitles.append(FavoriteItem(favoriteId: sessionId,
                                                            title: title))
                    self?.tableView.reloadData()
                }
            })
        }
    }
    
    @IBAction func handleEditBarItemTapped(_ sender: AnyObject) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        editBarButtonItem.title = tableView.isEditing ? "Done" : "Edit"
        editBarButtonItem.style = tableView.isEditing ? .done : .plain
    }
    
    // MARK: table data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteTitles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath)
        cell.textLabel?.text = favoriteTitles[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let favorite = favoriteTitles[indexPath.row]

        let firebaseFavorite = firebaseUser?.child("favorites").child(favorite.favoriteId)
        firebaseFavorite?.removeValue()

        // TODO: hack: removing the last favorite
        // causes the entire "favorites" location to disappear, so we don't
        // observe an update from it
        if favoriteTitles.count == 1 {
            favoriteTitles.removeAll()
            tableView.reloadData()
        }
        
    }
    
}
