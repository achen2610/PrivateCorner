//
//  PasscodeViewController.swift
//  PrivateCorner
//
//  Created by a on 8/22/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class PasscodeViewController: UITableViewController {
    
    @IBOutlet weak var passcodeTable: UITableView!
    @IBOutlet weak var recoverySwitch: UISwitch!
    @IBOutlet weak var touchIDSwitch: UISwitch!
    @IBOutlet weak var changePasscodeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Key.Screen.passcode
        tableView.delaysContentTouches = false

        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
    }
    
    // MARK: Button Selectors

    @IBAction func clickChangePasscode(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let lockScreen  = mainStoryboard.instantiateViewController(withIdentifier: "LockScreen") as! LockScreenViewController
        let viewModel = LockScreenViewModel(delegate: lockScreen, totalDotCount: 6)
        viewModel.passcodeState = .ChangePass
        viewModel.passcodeSaved = ""
        lockScreen.viewModel = viewModel
        present(lockScreen, animated: true, completion: nil)
    }
    
    @IBAction func switchChanged(sender: UISwitch) {
        if sender == recoverySwitch {
            UserDefaults.standard.set(sender.isOn, forKey: Key.UserDefaults.enablePasswordRecovery)
            UserDefaults.standard.synchronize()
        } else if sender == touchIDSwitch {
            UserDefaults.standard.set(sender.isOn, forKey: Key.UserDefaults.enableTouchID)
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: Event Handling
    func loadData() {
        let enablePasswordRecovery = UserDefaults.standard.bool(forKey: Key.UserDefaults.enablePasswordRecovery)
        if !enablePasswordRecovery {
            recoverySwitch.isOn = false
        } else {
            recoverySwitch.isOn = true
        }
        
        let enableTouchID = UserDefaults.standard.bool(forKey: Key.UserDefaults.enableTouchID)
        if !enableTouchID {
            touchIDSwitch.isOn = false
        } else {
            touchIDSwitch.isOn = true
        }
    }
}
