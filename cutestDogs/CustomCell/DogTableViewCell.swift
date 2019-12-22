//
//  DogTableViewCell.swift
//  cutestDogs
//
//  Created by Бадый Шагаалан on 19.12.2019.
//  Copyright © 2019 badyi. All rights reserved.
//

import UIKit

class DogTableViewCell: UITableViewCell {
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var CellLabel: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(with dog: DogView){
        CellLabel.text = dog.breed + " " + dog.subBreed
        icon.image = dog.icon
        if dog.icon == nil {
            activity.startAnimating()
            activity.isHidden = false
        } else {
            activity.stopAnimating()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        //
    }
}
