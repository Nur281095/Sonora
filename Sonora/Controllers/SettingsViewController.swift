//
//  SettingsViewController.swift
//  Show Cues Swift
//
//  Created by Carl Andrews on 9/23/19.
//  Copyright © 2019 Carl R Andrews, Inc. All rights reserved.
//
// Settings

import UIKit
import MessageUI
import StoreKit
//import KAlert

enum AppStoreReviewManager {
    static func requestReviewIfAppropriate() {
    }
}


class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    let defaults = UserDefaults.standard
    var clock24hour = false
    var showValueSlider: UILabel!
    var fadeSwitch2: UISwitch?
    var fadeSwitch4: UISwitch?
    var fadeSwitch6: UISwitch?
    var segmentSelection: Int = 3
    var datePicker: UIDatePicker!
    var masterVolume: Float = 0.0
    var numbers:Float = 0
    
    @IBOutlet weak var clockFormat24Switch: UISwitch!
    @IBOutlet weak var cueSheetSwitch: UISwitch!
//    @IBOutlet weak var noFadeSwitch: UISwitch!
    @IBOutlet weak var warningSwitch: UISwitch!
    @IBOutlet weak var showcountdownSwitch: UISwitch!
    @IBOutlet weak var showTrackNumbers: UISwitch!
    @IBOutlet weak var playPauseSwitch: UISwitch!
    @IBOutlet weak var testText: UILabel!
    @IBOutlet var fadeSwitch: UISegmentedControl!
    @IBOutlet var masterVolumeSlider: UISlider!
    @IBOutlet var masterVolumeLabel: UILabel!
    @IBOutlet var showLengthSlider: UIView!
    @IBOutlet var showLengthLabel: UILabel!
    @IBOutlet var startTrackNumber: UIView!
    @IBOutlet var startTrackLabel: UILabel!
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load saved data
        clockFormat24Switch.isOn = defaults.bool(forKey: "clockFormat24Switch")
        playPauseSwitch.isOn = defaults.bool(forKey: "playPauseSwitch")
   //     noFadeSwitch.isOn = defaults.bool(forKey: "noFadeSwitch")
        showTrackNumbers.isOn = defaults.bool(forKey: "showTrackNumbers")
        cueSheetSwitch.isOn = defaults.bool(forKey: "cueSheetSwitch")
        showcountdownSwitch.isOn = defaults.bool(forKey:"showcountdownSwitch")
        showLengthLabel.text = defaults.string(forKey:"showLengthLabel")
        startTrackLabel.text = defaults.string(forKey:"showTrackLabel")
        
        //using AppStorage to save data with a default value if nothing yet saved
        //https://www.hackingwithswift.com/books/ios-swiftui/storing-user-settings-with-userdefaults
        // @AppStorage("tapCount") private var tapCount = 0
        
        //add border to show length label
        showLengthLabel.layer.borderColor = UIColor.systemTeal.cgColor
        showLengthLabel.layer.borderWidth = 2.0
        showLengthLabel.layer.cornerRadius = 8
        showLengthLabel.backgroundColor = UIColor.systemTeal
        showLengthLabel.layer.masksToBounds = true
        
        //add border to starting track label
        startTrackLabel.layer.borderColor = UIColor.systemTeal.cgColor
        startTrackLabel.layer.borderWidth = 2.0
        startTrackLabel.layer.cornerRadius = 8
        startTrackLabel.backgroundColor = UIColor.systemTeal
        startTrackLabel.layer.masksToBounds = true
        
        //add border to master volume label
        masterVolumeLabel.layer.borderColor = UIColor.systemTeal.cgColor
        masterVolumeLabel.layer.borderWidth = 2.0
        masterVolumeLabel.layer.cornerRadius = 8
        masterVolumeLabel.backgroundColor = UIColor.systemTeal
        masterVolumeLabel.layer.masksToBounds = true

        
        loadFadeSwitch()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        masterVolumeSlider.value = defaults.float(forKey: "masterVolumeSlider") * 10
        masterVolumeLabel.text = defaults.string(forKey: "masterVolumeLabel")
        masterVolume = defaults.float(forKey: "masterVolume")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadFadeSwitch() {
        //load saved fade duration
        segmentSelection = defaults.integer (forKey: "segment")
        
        print("segment value ", segmentSelection)
        if segmentSelection == 0{
            print("short is true")
            fadeSwitch.selectedSegmentIndex = 0
        }
        if segmentSelection == 1{
            print("medium is true")
            fadeSwitch.selectedSegmentIndex = 1
        }
        if segmentSelection == 2{
            print("long is true")
            fadeSwitch.selectedSegmentIndex = 2
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 20)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Save Data before segue.
        // Pass the selected object to the new view controller.
    }
    
    //MARK: - Settings Switches
    @IBAction func clockFormat24Switch(sender:UISwitch ) {
        //when countdown tiume is on, Clock is off
        if clockFormat24Switch.isOn == true{
            showcountdownSwitch.isOn = false
        }
        defaults.set(clockFormat24Switch.isOn, forKey: "clockFormat24Switch")
        defaults.set(showcountdownSwitch.isOn, forKey: "showcountdownSwitch")
    }
    
    @IBAction func startTrackNumber(_ sender: UISlider) {
            sender.setValue(sender.value.rounded(.down), animated: true)
            startTrackLabel.text = "\(Int(sender.value))"
            defaults.set(startTrackLabel.text, forKey: "showTrackLabel")
        print("start track label", startTrackLabel.text!)
    }
    
    @IBAction func showLengthSlider(_ sender: UISlider) {
            sender.setValue(sender.value.rounded(.down), animated: true)
            showLengthLabel.text = "\(Int(sender.value))"
            defaults.set(showLengthLabel.text, forKey: "showLengthLabel")
    }
    
    @IBAction func masterVolumeSlider(_ sender: UISlider) {
        sender.setValue(sender.value.rounded(.down), animated: true)
        masterVolumeLabel.text = "\(masterVolumeSlider.value / 10)"
        masterVolume = Float(masterVolumeLabel.text!)!
        
        defaults.set(masterVolumeSlider.value, forKey: "masterVolumeSlider")
        defaults.set(masterVolumeLabel.text, forKey: "masterVolumeLabel")
        defaults.set(masterVolume, forKey: "masterVolume")

        print ("settings saved master volume ", masterVolume)
    }
    
    @IBAction func fadeDurationChanged(_ sender: Any) {
        switch fadeSwitch.selectedSegmentIndex
        {
        case 0:
            print ("Short Fade")
            segmentSelection = 0
            defaults.set(segmentSelection, forKey: "segment")
        case 1:
            print ("Medium Fade")
            segmentSelection = 1
            defaults.set(segmentSelection, forKey: "segment")
        case 2:
            print ("Long Fade")
            segmentSelection = 2
            defaults.set(segmentSelection, forKey: "segment")
        default:
            break
        }
        loadFadeSwitch()
    }
    
    @IBAction func playPauseSwitch(sender:UISwitch ) {
        defaults.set(playPauseSwitch.isOn, forKey: "playPauseSwitch")
    }
    
//    @IBAction func noFadeSwitch(sender:UISwitch ) {
//        defaults.set(noFadeSwitch.isOn, forKey: "noFadeSwitch")
//    }
    
    @IBAction func showTrackNumbers(sender:UISwitch ) {
        defaults.set(showTrackNumbers.isOn, forKey: "showTrackNumbers")
    }
    
    @IBAction func cueSheetSwitch(sender:UISwitch ) {
        defaults.set(cueSheetSwitch.isOn, forKey: "cueSheetSwitch")
    }
    
    @IBAction func showcountdownSwitch(sender:UISwitch ) {
        //when countdown tiume is on, Clock is off
        if showcountdownSwitch.isOn == true{
            clockFormat24Switch.isOn = false
            showLengthLabel.text = defaults.string(forKey:"showLengthLabel")
            startTrackLabel.text = defaults.string(forKey:"showTrackLabel")
        }
        defaults.set(clockFormat24Switch.isOn, forKey: "clockFormat24Switch")
        defaults.set(showcountdownSwitch.isOn, forKey: "showcountdownSwitch")
    }
    
    //MARK: - help info
    @IBAction func helpFadeOutDuration6() {
        self.showCustomAlertWith(
            message: "Set SHORT for 2 second fade.\n Set MEDIUM for 4 second fade.\n Set LONG for 6 second fade.",
            descMsg: "",
            itemimage: nil,
            actions: nil)
    }
    
    @IBAction func help24Clock() {
        self.showCustomAlertWith(
            message: "24 hour format for Clock.",
            descMsg: "This will show a real-time clock in 24 hour format.",
            // itemimage: #imageLiteral(resourceName: "logo.png"),
            itemimage: nil,
            actions: nil)
    }
    
    @IBAction func TimerCountDown() {
        self.showCustomAlertWith(
            message: "Displays countdown timer instead of Clock. If You are using the timer, set the show length in minutes.",
            descMsg: "",
            itemimage: nil,
            actions: nil)
    }
    
    @IBAction func helpcountdownTrackTimerStart() {
        self.showCustomAlertWith(
            message: "Select the track number for the timer to start counting down.",
            descMsg: "",
            itemimage: nil,
            actions: nil)
    }
    
    @IBAction func helpShowLengthTimer() {
        self.showCustomAlertWith(
            message: "Enter the show length in minutes for Count down.",
            descMsg: "",
            itemimage: nil,
            actions: nil)
    }
    
    @IBAction func helpPlayPause() {
        self.showCustomAlertWith(
            message: "By default the NEXT button is used to Fade. Turn ON to use the PLAY/PAUSE button to Fade. This will disable the option to Pause. ",
            descMsg: "",
            itemimage: nil,
            actions: nil)
    }
    
    @IBAction func helpNoPause() {
        self.showCustomAlertWith(
            message: "Enable No Pause between tracks. This will play tracks without stopping, until a fadeout.",
            descMsg: "",
            itemimage: nil,
            actions: nil)
    }
    
    @IBAction func helpShowTrackNumbers() {
        self.showCustomAlertWith(
            message: "Display the track numbers next to the track titles, in order.",
            descMsg: "",
            itemimage: nil,
            actions: nil)
    }
    
    @IBAction func helpCueSheets() {
        self.showCustomAlertWith(
            message: "Displays Cue Sheet for sound tech to run your show. See instructions for more info.",
            
            descMsg: "",
            itemimage: nil,
            actions: nil)
    }
    
    //MARK: - Settings Web links
    @IBAction func facebookButtonTapped(_ sender: UIButton) {
        let appURL = NSURL(string: "https://www.facebook.com/ShowCues?ref=bookmarks")!
        _ = NSURL(string: "https://www.facebook.com/ShowCues?ref=bookmarks")!
        
        if UIApplication.shared.canOpenURL(appURL as URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL as URL, options:
                                            [:], completionHandler: nil)
            }
            else { UIApplication.shared.openURL(appURL as URL)
            }
        }
    }
    
    @IBAction func ratingReview() {
        let alert = UIAlertController(title: "Feedback",
                                      message: "Are you enjoying Show Cues? \n Please leave a 5 star review.\n Thank you for your support.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes I love it!",
                                      style: .default, handler: { [weak self]_ in
            guard let scene = self?.view.window?.windowScene else{
                print("no scene")
                return
            }
            if #available(iOS 14.0, *) {
                SKStoreReviewController.requestReview(in: scene)
            } else {
                // Fallback on earlier versions
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Leave Feedback",
                                      style: .default, handler: { _ in
            //collect feedback by email
            let recipientEmail = "carlrandrews@me.com"
            let subject = "Show Cues Feedback"
            let body = ""
            
            // Show default mail composer
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([recipientEmail])
                mail.setSubject(subject)
                mail.setMessageBody(body, isHTML: false)
                self.present(mail, animated: true)
                
                // Show third party email composer if default Mail app is not present
            } else if let emailUrl = self.createEmailUrl(to: recipientEmail, subject: subject, body: body) {
                UIApplication.shared.open(emailUrl)
            }
        }))
        self.present(alert, animated: true)
    }
    
    //    @IBAction func ShowCuesWebsite (_ sender: UIButton) {
    //      //  let appURL = NSURL(string: "http://mojosoftwareonline.com/showcues.htm")!
    //      //  _ = NSURL(string: "http://mojosoftwareonline.com/showcues.htm")!
    //
    //        if UIApplication.shared.canOpenURL(appURL as URL) {
    //            if #available(iOS 10.0, *) {
    //                UIApplication.shared.open(appURL as URL, options:
    //                                            [:], completionHandler: nil)
    //            }
    //            else { UIApplication.shared.openURL(appURL as URL)
    //            }
    //        }
    //    }
    
    @IBAction func sendEmail(_ sender: UIButton) {
        
        let recipientEmail = "carlrandrews@me.com"
        let subject = "Show Cues"
        let body = "Please send us your comments or questions."
        
        // Show default mail composer
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            present(mail, animated: true)
            
            // Show third party email composer if default Mail app is not present
        } else if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body) {
            UIApplication.shared.open(emailUrl)
        }
    }
    
    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        return defaultUrl
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
