//
//  SessionDetailViewController.swift
//  CocoaConfFirebaseDemo01
//
//  Created by Chris Adamson on 9/2/16.
//  Copyright © 2016 Subsequently & Furthermore, Inc. All rights reserved.
//

import UIKit
import Firebase

class SessionDetailViewController: UIViewController {

    // TODO: this doesn't need to be a property
    private var firebaseAttendees : FIRDatabaseReference?
    private var firebaseUser : FIRDatabaseReference?

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var speakerNameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    var session : Session? {
        didSet {
            titleLabel.text = session?.title
            speakerNameLabel.text = session?.speakerName
            descriptionLabel.text = session?.description
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func handleMakeFavoriteTapped(_ sender: AnyObject) {
        guard let session = session, let sessionId = session.id else { return }

        
        firebaseAttendees = FIRDatabase.database().reference().child("attendees")

        // TODO: need to DRY this up vs favorites VC
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
        let firebaseFavorite = firebaseUserFavorites?.child(sessionId)
        firebaseFavorite?.setValue(true)
    }
    
}
