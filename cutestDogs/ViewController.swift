//
//  ViewController.swift
//  cutestDogs
//
//  Created by Бадый Шагаалан on 19.12.2019.
//  Copyright © 2019 badyi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var MyView: GradientView!
    
    @IBOutlet weak var showBreedsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MyView.beginColor = UIColor(hexString: "#DB7093")
        MyView.endColor = UIColor.white
        showBreedsButton.setTitleColor(UIColor(hexString: "#FF69B4"), for: .normal)
    }
}

