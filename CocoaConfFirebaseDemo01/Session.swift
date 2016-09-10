//
//  Session.swift
//  CocoaConfFirebaseDemo01
//
//  Created by Chris Adamson on 9/2/16.
//  Copyright © 2016 Subsequently & Furthermore, Inc. All rights reserved.
//

import Foundation
import Firebase

struct Session {

    var id : String?
    var title : String?
    var speakerName : String?
    var description : String?
    
    init? (id: String, dict : [String : Any]) {
        guard let title = dict["title"] as? String,
            let speakerName = dict["speakerName"] as? String,
            let description = dict["description"] as? String else
        {
            return nil
        }
        self.id = id
        self.title = title
        self.speakerName = speakerName
        self.description = description
    }
}
