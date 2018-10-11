//
//  SettingViewController.swift
//  PrivateCorner
//
//  Created by a on 3/15/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit
import CDAlertView
import MessageUI

class SettingViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var settingTable: UITableView!
    // MARK: Object lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Key.Screen.setting
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(performSeguePasscodeViewWithNotification(noti:)),
                                               name: Notification.Name(rawValue: Key.SString.notiPerformSeguePasscodeView),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showAlertWhenChangePassSuccess(noti:)),
                                               name: Notification.Name(rawValue: Key.SString.notiAlertChangePassSuccess),
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
    }
    
    // MARK: Event handling
    @objc func performSeguePasscodeViewWithNotification(noti: Notification) {
        self.performSegue(withIdentifier: "seguePasscodeViewController", sender: nil)
    }
    
    @objc func showAlertWhenChangePassSuccess(noti: Notification) {
        let alert = CDAlertView(title: nil, message: "Change passcode success!", type: .success)
        alert.show()
        
        delay(1.0, execute: { 
            alert.hide(isPopupAnimated: true)
        })
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        
        switch section {
        case 1:
            /*
            if indexPath.row == 0 {
                //Passcode
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let lockScreen  = mainStoryboard.instantiateViewController(withIdentifier: "LockScreen") as! LockScreenViewController
                let viewModel = LockScreenViewModel(delegate: lockScreen, totalDotCount: 6)
                viewModel.passcodeState = .RequirePass
                viewModel.passcodeSaved = UserDefaults.standard.value(forKey: "passcodeSaved") as? String
                lockScreen.viewModel = viewModel
                lockScreen.isHeroEnabled = true
                lockScreen.heroModalAnimationType = .fade
                present(lockScreen, animated: true, completion: nil)
            }
            */
            break
        case 2:
            if indexPath.row == 0 && MFMailComposeViewController.canSendMail() {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                // Configure the fields of the interface.
                composeVC.setToRecipients(["address@example.com"])
                composeVC.setSubject("Hello!")
                composeVC.setMessageBody("Hello this is my message body!", isHTML: false)
                // Present the view controller modally.
                self.present(composeVC, animated: true, completion: nil)
            }
            break
        default:
            return
        }
    }
    
    // MARK: - Mail Delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let err = error {
            print("Error when send mail : \(err)")
        }
        
        controller.dismiss(animated: true, completion: nil)
    }

}

