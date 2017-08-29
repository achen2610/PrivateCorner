//
//  PasscodeViewController.swift
//  PrivateCorner
//
//  Created by a on 8/22/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class PasscodeViewController: UIViewController {
    
    @IBOutlet weak var passcodeTable: UITableView!
    
    struct cellIdentifiers {
        static let passcodeCellA    = "PasscodeCellA"
        static let passcodeCellB    = "PasscodeCellB"
        static let passcodeCellC    = "PasscodeCellC"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Key.Screen.passcode
    }
    
    // MARK: Button Selectors
    
    func clickedChangePasscodeButton() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let lockScreen  = mainStoryboard.instantiateViewController(withIdentifier: "LockScreen") as! LockScreenViewController
        let viewModel = LockScreenViewModel(delegate: lockScreen, totalDotCount: 6)
        viewModel.passcodeState = .ChangePass
        viewModel.passcodeSaved = ""
        lockScreen.viewModel = viewModel
        present(lockScreen, animated: true, completion: nil)
    }
    
    func switchChanged(sender: UISwitch) {
        switch sender.tag {
        case 81:
            UserDefaults.standard.set(sender.isOn, forKey: Key.UserDefaults.enablePasswordRecovery)
            UserDefaults.standard.synchronize()
            break
            
        case 82:
            UserDefaults.standard.set(sender.isOn, forKey: Key.UserDefaults.enableTouchID)
            UserDefaults.standard.synchronize()
            break
        default:
            break
        }
    }
}
