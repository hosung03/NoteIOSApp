//
//  NoteTableViewCell.swift
//  NoteIOSApp
//
//  Created by Hosung, Lee on 2016. 12. 5..
//  Copyright © 2016년 hosung. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var lbNote: UILabel!
    @IBOutlet weak var lbLocation: UILabel!
    @IBOutlet weak var ivThumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
