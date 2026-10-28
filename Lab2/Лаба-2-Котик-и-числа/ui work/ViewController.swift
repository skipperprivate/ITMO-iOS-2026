//
//  ViewController.swift
//  ui work
//
//  Created by Sofia on 17.09.2026.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "Здесь будут рандомные числа"
    }
    @IBAction func randomNum(_ sender: UIButton) {
        label.text = String.init(Int.random(in: 1...100))
    }

}

