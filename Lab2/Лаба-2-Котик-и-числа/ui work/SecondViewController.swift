//
//  SecondViewController.swift
//  ui work
//
//  Created by Sofia on 17.09.2026.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    let images = ["cat1", "cat2", "cat3"]
    var currentImageIndex = 0
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(named: images[0])
        
        timer = Timer.scheduledTimer(
            timeInterval: 3.0,
            target: self,
            selector: #selector(changeImages),
            userInfo: nil, repeats: true,
        )
    }
        @objc func changeImages() {
            currentImageIndex += 1
            
            if currentImageIndex >= images.count {
                currentImageIndex = 0
            }
            
            UIView.transition(
                with: imageView,
                duration: 1,
                options: .transitionCurlUp,
                animations: {self.imageView.image = UIImage(named: self.images[self.currentImageIndex])}
            )
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

