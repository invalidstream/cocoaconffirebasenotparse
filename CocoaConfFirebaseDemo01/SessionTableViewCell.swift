//
//  SessionTableViewCell.swift
//  CocoaConfFirebaseDemo01
//
//  Created by Chris Adamson on 9/2/16.
//  Copyright © 2016 Subsequently & Furthermore, Inc. All rights reserved.
//

import UIKit

class SessionTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var speakerLabel: UILabel!
    
    var session : Session? {
        didSet {
            titleLabel.text = session?.title
            speakerLabel.text = session?.speakerName
        }
    }
    
}
