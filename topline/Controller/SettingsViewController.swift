//
//  SettingsViewController.swift
//  topline
//
//  Created by Michael Handkins on 1/2/21.
//

import UIKit

class SettingsViewController: UIViewController {

    let defaults = UserDefaults.standard
    
    @IBOutlet weak var indigoButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var pinkButton: UIButton!
    @IBOutlet weak var goldButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBarTint()
    }
    
    func setBarTint() {
        redButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
        indigoButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
        greenButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
        pinkButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
        goldButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
        
        if let theme = defaults.string(forKey: "theme") {
            switch theme {
            case "LAIndigo":
                indigoButton.setImage(UIImage.init(systemName: "circle.fill"), for: .normal)
            case "LAGreen":
                greenButton.setImage(UIImage.init(systemName: "circle.fill"), for: .normal)
            case "LAPink":
                pinkButton.setImage(UIImage.init(systemName: "circle.fill"), for: .normal)
            case "LAGold":
                goldButton.setImage(UIImage.init(systemName: "circle.fill"), for: .normal)
            case "LARed":
                redButton.setImage(UIImage.init(systemName: "circle.fill"), for: .normal)
            default:
                indigoButton.setImage(UIImage.init(systemName: "circle.fill"), for: .normal)
            }
            self.navigationController?.navigationBar.tintColor = UIColor.init(named: theme)
        }
    }
    
    
    
    @IBAction func indigoPressed(_ sender: Any) {
        self.defaults.setValue("LAIndigo", forKey: "theme")
        setBarTint()
    }
    
    @IBAction func greenPressed(_ sender: Any) {
        self.defaults.setValue("LAGreen", forKey: "theme")
        setBarTint()
    }
    
    @IBAction func pinkPressed(_ sender: Any) {
        self.defaults.setValue("LAPink", forKey: "theme")
        setBarTint()
    }
    
    @IBAction func goldPressed(_ sender: Any) {
        self.defaults.setValue("LAGold", forKey: "theme")
        setBarTint()
    }
    
    @IBAction func redPressed(_ sender: Any) {
        self.defaults.setValue("LARed", forKey: "theme")
        setBarTint()
    }
    

}
