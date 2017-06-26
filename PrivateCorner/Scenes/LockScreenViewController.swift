//
//  LockScreenViewController.swift
//  PrivateCorner
//
//  Created by a on 3/9/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

class LockScreenViewController: UIViewController, LockScreenViewModelDelegate  {
    var buttonArray = [UIButton]()
    var viewModel: LockScreenViewModel!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var PasscodeView: PasscodeView!
    @IBOutlet weak var OneButton: UIButton!
    @IBOutlet weak var TwoButton: UIButton!
    @IBOutlet weak var ThreeButton: UIButton!
    @IBOutlet weak var FourButton: UIButton!
    @IBOutlet weak var FiveButton: UIButton!
    @IBOutlet weak var SixButton: UIButton!
    @IBOutlet weak var SevenButton: UIButton!
    @IBOutlet weak var EightButton: UIButton!
    @IBOutlet weak var NineButton: UIButton!
    @IBOutlet weak var ZeroButton: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var LogoButton: UIButton!
    
    // MARK: Object lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleUI()
        PasscodeView.totalDotCount = 6
        viewModel = LockScreenViewModel(delegate: self, totalDotCount: 6)
    }
    
    // MARK: Event handling
    
    private func styleUI() {
        
        backgroundImageView.image = UIImage.init(named: "data-security-tips.jpg")
        blurImage()

        buttonArray.append(ZeroButton)
        buttonArray.append(OneButton)
        buttonArray.append(TwoButton)
        buttonArray.append(ThreeButton)
        buttonArray.append(FourButton)
        buttonArray.append(FiveButton)
        buttonArray.append(SixButton)
        buttonArray.append(SevenButton)
        buttonArray.append(EightButton)
        buttonArray.append(NineButton)

        for button in buttonArray {
            self.styleButton(button: button)
            button.tag = buttonArray.index(of: button)!
            button.addTarget(self, action: #selector(clickedNumberButton(sender:)), for: .touchUpInside)
        }
        self.styleButton(button: CancelButton)
        self.styleButton(button: LogoButton)
        CancelButton.addTarget(self, action: #selector(clickedCancelButton(sender:)), for: .touchUpInside)
        LogoButton.titleLabel?.numberOfLines = 2;
    }
    
    private func blurImage() {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            backgroundImageView.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = backgroundImageView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            backgroundImageView.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        }
    }
    
    private func styleButton(button: UIButton) {
        button.layer.cornerRadius = 5.0;
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0;
    }
    
    func wrongPasscode() {
        PasscodeView.shakeAnimationWithCompletion {
            self.viewModel.clearInput()
            self.TitleLabel.text = "MẬT KHẨU SAI. THỬ LẠI !"
        }
    }
    

    // MARK: Navigation
    func navigateToHomeScreen() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        navigationController?.pushViewController(appDelegate.tabBarController, animated: true)
    }

    // MARK: Display logic
    
    
    // MARK: Selector logic
    
    func clickedNumberButton(sender: UIButton!) {
        print("clicked \(sender.tag) Button")
        
        viewModel.appendInputString(string: "\(sender.tag)")
    }
    
    func clickedCancelButton(sender: UIButton!) {
        print("clicked Cancel Button")
        
        if viewModel.passcodeState == .SecondInput && viewModel.inputDotCount == 0 {
            viewModel.resetInputString()
        } else {
            viewModel.deleteInputString(isFull: PasscodeView.isFull)
        }
    }

    // MARK: LockScreenViewModelDelegate
    func validationSuccess() {
        TitleLabel.text = "NHẬP MẬT KHẨU CỦA BẠN"
        viewModel.clearInput()
        navigateToHomeScreen()
    }
    
    func validationFail() {
        wrongPasscode()
    }
    
    func setInputDotCount(inputDotCount: Int) {
        PasscodeView.inputDotCount = inputDotCount
    }
    
    func setTitleLabel(text: String) {
        TitleLabel.text = text
    }
    
    func setTitleButton(text: String) {
        CancelButton.setTitle(text, for: .normal)
    }
}


