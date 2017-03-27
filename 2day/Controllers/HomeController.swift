//
//  HomeController.swift
//  2day
//
//  Created by Anastasiya Dumyak on 3/26/17.
//  Copyright © 2017 AnastasiyaDumiak. All rights reserved.
//

import UIKit

class HomeController: UIViewController {

    
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabel), userInfo: nil, repeats:true);
    }
    
    func setupUI() {
        view.layer.contents = UIImage(named:"natureplaceholder")?.cgImage
        view.layer.contentsGravity = kCAGravityResizeAspectFill
        nameLabel.text = "Hey, have a nice day, My Friend!"
    }

    func updateLabel() -> Void {
        clockLabel.text = dateFormatter.string(from: Date());
    }
}
