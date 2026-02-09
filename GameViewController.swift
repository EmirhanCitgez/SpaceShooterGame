//
//  GameViewController.swift
//  SpaceShooter
//
//  Created by Emirhan Çitgez on 09/08/2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // SceneMeneger'ı setup et
            SceneManager.shared.setup(with: view)
            
            //Ana menüye git
            SceneManager.shared.goToMenu()
            
            view.ignoresSiblingOrder = true
            view.showsPhysics = true
            
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
