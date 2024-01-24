/*------------------------------------
 
 Sonora
 Created by cubycode @2017
 purchased by Carl R Andrews, Inc.
 
 Show Cues
 Created by Carl R Andrews, Inc.
 
 11/17/23
 ------------------------------------*/

import UIKit
import MediaPlayer
import AudioToolbox
import AVFoundation
import MessageUI
import Foundation
import SwiftUI


extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                                                            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}

extension TimeInterval {
    var time:String {
        return String(format:"%02dd %02dh %02dm %02ds", Int((self/86400)), Int((self/3600.0)), Int((self/60.0)), Int((self)))
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension UILabel {
    func setSizeFont (sizeFont: Double) {
        self.font =  UIFont(name: self.font.fontName, size: CGFloat(sizeFont))!
        self.sizeToFit()
    }
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider2 = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider2?.value = volume
        }
    }
}

// MARK: - GLOBAL VARIABLES -----------------------------------------------------

typealias Completion = (() -> Void)
let mixer = AVAudioMixerNode()

private let volumeView: MPVolumeView = MPVolumeView()
private var volumeSlider: UISlider?

var iPhoneDevice: Bool = true
var showsRouteButton: Bool = false
var seconds: Int = 0
var minutes: Int = 0
var addMultiplier: Int = 60
var countdownStart2: UILabel?
var myVolume:Float?
var nowPlaying = " "
var musicPlayer:MPMusicPlayerController?
var songsCollection:MPMediaItemCollection?
var songs:NSArray?
var myArray:[String] = []
var myMutableArray:NSMutableArray?
var segmentSelection: Int = 3
var xyz: Int = 0
var defaults = UserDefaults.standard
var cueSheetSwitch: Bool = false
var cueSheetTextViewText: UILabel?
var songTimer = Timer()
var countdownTimer = Timer()
var currentTimeTimer = Timer()
var batteryStatusTimer = Timer()
var delayTimer = Timer()
var showcountdownSwitch: Bool = false
var sleepTime = 0.0 {
    didSet {
        print(sleepTime)
    }
}
var timeRemaining2: UILabel?
var timerIsRunning = false
var fadeStarted: Bool = false
var loadingDone = false
var passedValue: String = ""
var intToPass:Int!
var text: String = ""
var text0: String = ""
var text1: String = ""
var text2: String = ""
var text3: String = ""
var text4: String = ""
var text2b: String = ""
var detailViewHome: UIView!
var playAll1: Bool = false
//var pause1: Bool = false
var delay1: Bool = false
var loop1: Bool = false
var rename1: Bool = false
//var noFadeSwitch: Bool = false
var spinner = UIActivityIndicatorView(style: .large)
var number:Int = 0
//var delayTime: String = ""
var delayTime: UITextField?

var songsSaved: NSMutableArray?
var songsSelected: Bool = false
var isFading: Bool = false
var currentSongNumber = musicPlayer!.indexOfNowPlayingItem
var mediaItems:Int!
var batteryLevel: Float { UIDevice.current.batteryLevel }
var currentVolume:Float = 0
var counter:Float = 0
var currentTime: Double = 0
var remainingCountdownTime: Double = 0

//var seconds:Int!
var level_Battery: UILabel!

//---------------------------------------------------------

class LocalAudioData : NSObject,NSCoding {
    
    var Name:String?
    var mediaItem:MPMediaItem?
    
    required init(name:String,mediaItem:MPMediaItem) {
        self.Name = name
        self.mediaItem = mediaItem
    }
    required convenience init(coder aDecoder: NSCoder) {
        let Name = aDecoder.decodeObject(forKey: "shortname") as! String
        let mediaItem = aDecoder.decodeObject(forKey: "mediaItem") as! MPMediaItem
        self.init(name: Name, mediaItem: mediaItem)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Name, forKey: "shortname")
        aCoder.encode(mediaItem, forKey: "mediaItem")
    }
}

class MusicPlayerVC: UIViewController,
                     MPMediaPickerControllerDelegate,
                     AVAudioPlayerDelegate
{
    
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var cueSheetTextViewText: UILabel!
    @IBOutlet weak var delayTimeLabel: UILabel!
    // Music Control Buttons
    @IBOutlet weak var playPauseOutlet: UIButton!
    @IBOutlet weak var menuOutlet: UIButton!
    // Labels
    @IBOutlet weak var songTitleLabel: UILabel!
    // Song Timer Labels
    @IBOutlet weak var timeRemainingLabel: UILabel?
    @IBOutlet var myClock: UILabel!
    @IBOutlet var myClockCountdown: UILabel!
    @IBOutlet var batteryImage: UIImageView!
    @IBOutlet var timeRemaining2: UILabel!
    
   // @IBOutlet var delay: UISwitch!

    //Track Settings
    var trackPlay: UISwitch!
    var trackPause: UISwitch!
    weak var trackDelay: UISwitch!
    weak var trackLoop: UISwitch!
    //other variables
    var arrAudio = [LocalAudioData]()
    var userDefaults = UserDefaults.standard
    var musicKey = "musicKey"
    var mediaPickerDone: Bool!
    var currentTrack: String?
    var masterVolume: Float = 0.0
    var timerRunning = false
    var countdownTimer = Timer()
    var currentSongNumber: Int = 0
    var startTrackFormated: Int = 0
    var startTrackLabel: Int = 0
    
    @IBOutlet var resetCountdownTimer: UIButton!
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    private func setupVolumeListener()
    {
        let frameView:CGRect = CGRectMake(0, 0, 0, 0)
        let volumeView = MPVolumeView(frame: frameView)
        self.view.addSubview(volumeView)
    }
    
    @IBAction func resetCountdownTimerButton(_ sender: Any) {
        currentTime = 0
        if currentTime == 0 {
            //myClockCountdown.text = "00:00"
            myClockCountdown.alpha = 0
            countdownTimer.invalidate()
            timerRunning = false
        }
    }
    
    // MARK: - LOAD INDIVIDUAL TRACK SETTING
    func getTrackSettings(){
        //get index of current track to load settings
        
//        let songNumber = musicPlayer!.indexOfNowPlayingItem
        //songTitleLabel.text = defaults.string(forKey: "songIndexRow")
//        songTitleLabel.text = currentTrack
//        print ("load song number ", songNumber)
//        print ("load song number current track ", songTitleLabel.text as Any)
       
//        let currentIndex = songNumber
//        //print("load index current ", currentIndex)
//        text = "\(String(describing: currentIndex))"
//        text = songTitleLabel.text ?? "track"
//        text0 = text + "playAll"
//        print("load playAll text ", text0)
//        //Autoplay
//        playAll1 = defaults.bool(forKey: text0)
        
       // text2 = text + "delay"
       // print("load delay text ", text2)
        
       //delay not loading???
        
//        delay1 = defaults.bool(forKey: text2)
//        print("load delay on ", delay1)
//        if delay1 == true{
//            text2b = text + "delayTime"
//            delayTime?.text = defaults.string(forKey: text2b)
//            print("load delayTime", delayTime as Any)
//            print("load delay1 getsettings ", delay1)
//            text2b = text + "delayTime"
//            let delayTime = defaults.string(forKey: text2b)
//            print("load delayTime", delayTime as Any)
//            delayTimeShow()
//        }
//        
//        text3 = text + "loop"
//        print("loop text ", text3)
//        loop1 = defaults.bool(forKey: text3)
//     }
    
//    @objc func delayTimeShow(){
//        //myVolume = defaults.float (forKey: "myVolume")
//        //volumeSlider.value = myVolume!
//        //print("my voluime delay ", myVolume!)
//        //print(" load2 xyz ", xyz)
//        let str2 = String(xyz)
//        delayTimeLabel.text = str2
//        xyz = xyz - 1
//        
//        if (xyz < 0){
//            xyz = 0
//            delayTimer.invalidate()
//            delayTimeLabel.alpha = 0
//            delayTimeLabel.text = ""
//            //print("load volume for before delay track ", myVolume!)
//            playPauseButt2()
//            playPauseOutlet.setBackgroundImage(UIImage(systemName: "pause.fill")!, for: .normal)
//            playPauseOutlet.tintColor = .green
//            songTitleLabel.textColor = .green
//            songTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSongProgress), userInfo: nil, repeats: true)}
    }
    
    // MARK: - NOW PLAYING CHANGED
    @objc func nowPlayingChanged(_ notification: Notification) {
        
//        if loadingDone == true {
//            getTrackSettings()
//        }
        
        volumeSlider.value = defaults.float (forKey: "myVolumeSlider")
        myVolume = defaults.float(forKey: "masterVolume")
        MPVolumeView.setVolume(myVolume!)

        
        //After playAll, if pause is on track setting, pause and return
//        if pause1 == true{
//            //print("pause track button on")
//            musicPlayer!.pause()
//            playPauseOutlet.setBackgroundImage(UIImage(systemName:
//                                                        "play.fill")!, for: .normal)
//            playPauseOutlet.tintColor = .yellow
//            songTitleLabel.textColor = .yellow
//            pause1 = false
//            return
//        }

        songTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSongProgress), userInfo: nil, repeats: true)
        
        //No pause directly play next track setting set to autoplay
       // let noFadeSwitch = defaults.bool(forKey: "noFadeSwitch")
        //print("no pause ", noFadeSwitch)

//        if loop1 == true{
//            print("Loop button On")
//            var showTrackNumbers: Bool
//            showTrackNumbers = defaults.bool(forKey: "showTrackNumbers")
//            let currentItem = musicPlayer?.nowPlayingItem as MPMediaItem?
//            let songTitle = currentItem!.value(forProperty: MPMediaItemPropertyTitle) as! NSString
//
//            //If track Numbers is turned On
//            if showTrackNumbers == true{
//                let songNumber = musicPlayer!.indexOfNowPlayingItem
//                let str2 = String(songNumber + 1)
//                print ("str2 " , str2)
//                songTitleLabel.text = str2 + " " + " \(String(describing: songTitle))"
//            }
//            else{
//                songTitleLabel.text = "\(String(describing: songTitle))"
//            }
//
//            //Only show first 30 characters of Song Title
//            let text = songTitleLabel.text
//            let resultPrefix = text!.prefix(30)
//
//            songTitleLabel.alpha = 1
//
//            songTitleLabel.adjustsFontSizeToFitWidth = true
//            songTitleLabel.minimumScaleFactor = 0.5
//            songTitleLabel.numberOfLines = 0
//            songTitleLabel.text = String(resultPrefix)
//
//            //   musicPlayer!.play()
//            musicPlayer!.repeatMode = MPMusicRepeatMode.one
//            playPauseOutlet.setBackgroundImage(UIImage(systemName: "pause.fill")!, for: .normal)
//            playPauseOutlet.tintColor = .green
//            songTitleLabel.textColor = .green
//
//            return
//        }
        
//            if playAll1 == true{
//            let songNumber = musicPlayer!.indexOfNowPlayingItem
//            if songNumber == 0 {
//                musicPlayer!.pause()
//                playPauseOutlet.setBackgroundImage(UIImage(systemName: "play.fill")!, for: .normal)
//                playPauseOutlet.tintColor = .yellow
//                songTitleLabel.textColor = .yellow
//                playAll1 = false
//            }else{
//                musicPlayer!.play()
//                playPauseOutlet.setBackgroundImage(UIImage(systemName: "pause.fill")!, for: .normal)
//                playPauseOutlet.tintColor = .green
//                songTitleLabel.textColor = .green
//                playPauseButt2()
//                songTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSongProgress), userInfo: nil, repeats: true)}
//                playAll1 = false
//        }
//        else{
            musicPlayer!.pause()
            playPauseOutlet.setBackgroundImage(UIImage(systemName:
                                                        "play.fill")!, for: .normal)
            playPauseOutlet.tintColor = .yellow
            songTitleLabel.textColor = .yellow
            playAll1 = false
//        }
        
        // MARK: - SONG TITLE
        let currentItem = musicPlayer?.nowPlayingItem as MPMediaItem?
        
        //check to be sure tracks are on the device to prevent crash
        if currentItem == nil{
            return
        }
        
        if currentItem != nil {
            let songTitle = currentItem!.value(forProperty: MPMediaItemPropertyTitle) as! NSString
            
            print("song title ", songTitle)
            
            var showTrackNumbers: Bool
            showTrackNumbers = defaults.bool(forKey: "showTrackNumbers")
            
            //If track Numbers is selected Setting
            if showTrackNumbers == true{
                let songNumber = musicPlayer!.indexOfNowPlayingItem
                let str2 = String(songNumber + 1)
                songTitleLabel.text = str2 + " " + " \(String(describing: songTitle))"
            }
            else{
                songTitleLabel.text = "\(String(describing: songTitle))"
            }
            //set var for songtitlelabel to use on tracksettings
            currentTrack = songTitleLabel.text
            
            //Only show first 30 characters of Song Title
            let text = songTitleLabel.text
            let resultPrefix = text!.prefix(30)
            
            songTitleLabel.adjustsFontSizeToFitWidth = true
            songTitleLabel.minimumScaleFactor = 0.5
            songTitleLabel.numberOfLines = 0
            
            //fade in songtitle change
            songTitleLabel.fadeTransition(0.25)
            
            songTitleLabel.text = String(resultPrefix)
 
//            playPauseOutlet.setBackgroundImage(UIImage(systemName:
//                                                        "play.fill")!, for: .normal)
//            playPauseOutlet.tintColor = .yellow
//            songTitleLabel.textColor = .yellow
            playAll1 = false

            
            //save playlist track titles
            myArray.append(String(describing: songTitleLabel.text!))
            UserDefaults.standard.set(myArray, forKey: "myArray")
            //print("myArray ",myArray)
            
            updateSongProgress()
        }
        
        // MARK: - CUE SHEETS
        //Cue Sheet Comments are input in Apple Music on computer
        if currentItem != nil {
            let comments = currentItem?.value(forProperty: MPMediaItemPropertyComments) as? NSString
            //print ("comments ", comments as Any)
            cueSheetTextViewText?.text = (comments ?? " ") as String
            cueSheetTextViewText?.text = songTitleLabel.text! + " \n " + (cueSheetTextViewText?.text!)!
        }
        else {
            cueSheetTextViewText?.text = "No Cues were created for this song"
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        //print("remove Observer")
    }
    
    // MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        
        self.becomeFirstResponder()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        setupCommandCenter()
        
        volumeSlider.value = defaults.float (forKey: "masterVolumeSlider")
        myVolume = defaults.float(forKey: "masterVolume")
        MPVolumeView.setVolume(myVolume!)
        print ("my volume will appear ", myVolume!)
        print ("my volume will appear slider value ", volumeSlider.value)
        
        delayTimeLabel.alpha = 0
        cueSheetTextViewText.alpha = 0
        songTitleLabel.alpha = 0
        
        //get device size iPhone or iPad
        if UIDevice.current.userInterfaceIdiom == .phone {
            //print("running on iPhone")
            iPhoneDevice = true
        }else{
            iPhoneDevice = false
        }
        
        //check if countdown switch is ON
        showcountdownSwitch =
        defaults.bool(forKey: "showcountdownSwitch")
        if showcountdownSwitch == true {
            myClockCountdown.alpha = 1
            myClock.alpha = 0
        }else{
            myClockCountdown.alpha = 0
            myClock.alpha = 1
        }
        
        cueSheetSwitch = defaults.bool(forKey: "cueSheetSwitch")
        if cueSheetSwitch == true{
            songTitleLabel.alpha = 0
            cueSheetTextViewText.alpha = 1
        }else{
            UIView.animate(withDuration: 0.5,
                           delay: 0.1,
                           options: .curveEaseIn,
                           animations: { [weak self] in
                self?.songTitleLabel.alpha = 1
            }, completion: nil)
        }
        
        currentTimeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getCurrentTime), userInfo: nil, repeats: true)
        
        playPauseOutlet.setBackgroundImage(UIImage(systemName:
                                                    "play.fill")!, for: .normal)
        playPauseOutlet.tintColor = .yellow
        songTitleLabel.textColor = .yellow
        
        myClockCountdown?.setValue(UIColor.yellow, forKeyPath: "textColor")
        
        masterVolume = defaults.float(forKey: "masterVolume")
        
        showLengthLabelSetup()
        initializeMusicPlayer()
    }
    
    
    func showLengthLabelSetup(){
        currentTime = Double(defaults.float(forKey: "showLengthLabel"))
        let multi = 60
        currentTime = currentTime * Double(multi)
        //print ("countdown time ", currentTime)
        let showMinutes = Int(currentTime) / 60 % 60
        let showSeconds = Int(currentTime) % 60
        self.myClockCountdown.text = String(format:"%02i:%02i", showMinutes, showSeconds)
        //print ("countdown time text ", myClockCountdown.text!)
    }
    
    // MARK: - UPDATE countdown show time PROGRESS
    @objc func updateCountDownTimeProgress() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] timer in
            print("timer current time", currentTime)
            currentTime -= 1
            
            let currentMinutes = Int(currentTime) / 60 % 60
            let currentSeconds = Int(currentTime) % 60
            self.myClockCountdown.text = String(format:"%02i:%02i", currentMinutes, currentSeconds)
            
            if currentTime <= 0 {
                self.myClockCountdown?.setValue(UIColor.red, forKeyPath: "textColor")
                self.timerRunning = false
                timer.invalidate()
                self.countdownTimer.invalidate()
            }
        }
    }
    
    // MARK: - REMOTE CONTROL CENTER
    func setupCommandCenter() {
        // get remote commands
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.playPauseButt(commandCenter.self
            )
            return .success
        }
        commandCenter.playCommand.isEnabled = true
        
        
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.playPauseButt(commandCenter.self
            )
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        
        
        commandCenter.nextTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.nextButt(commandCenter.self
            )
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        
        
        commandCenter.previousTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.prevButt(commandCenter.self
            )
            return .success
        }
        commandCenter.previousTrackCommand.isEnabled = true
    }
    
    @objc func playCommand(_ action: MPRemoteCommandEvent) {
        playPauseButt(self)
    }
    @objc func pauseCommand(_ action: MPRemoteCommandEvent) {
        playPauseButt(self)
    }
    
    func setupPlaylist(){
        songTitleLabel.alpha = 0
        timeRemainingLabel?.alpha = 0
        timeRemaining2?.alpha = 0
        
        //run thru all songs to save playlist table data
        currentSongNumber = musicPlayer!.indexOfNowPlayingItem
        mediaItems = defaults.integer(forKey: "mediaItems")
        //print ("currentMedia ", mediaItems!)
        //print("currentNumber ", currentSongNumber)
        
        if  currentSongNumber == 0{
            songTitleLabel.alpha = 1
            
            //force music player to show time remaing instead of 0 for first track until Play
            volumeSlider.value = 0
            musicPlayer!.play()
            musicPlayer!.skipToNextItem()
            musicPlayer!.skipToPreviousItem()
            timeRemaining2?.alpha = 1
            
            getOrientation()
            
            volumeSlider.value = defaults.float (forKey: "myVolumeSlider")
            myVolume = defaults.float(forKey: "masterVolume")
            MPVolumeView.setVolume(myVolume!)
            
//            if myVolume! <= 0 {
//                myVolume = 0.8 //default volume for first time loading
//                //volumeSlider.value = myVolume ?? 0.8
//                //set volume to save
//                defaults.set(volumeSlider.value, forKey: "myVolumeSlider")
//                defaults.set(myVolume, forKey: "masterVolume")
//            }
        }else{
            songTitleLabel.alpha = 0
            perform(#selector(addSongToList), with: nil, afterDelay: 0.1)
        }
    }
    
    @objc func addSongToList() {
        if currentSongNumber < mediaItems{
            musicPlayer!.skipToNextItem()
            currentSongNumber = musicPlayer!.indexOfNowPlayingItem
            setupPlaylist()
        }
    }
    
    // MARK: - SETUP PLAYER
    @objc func setupPlayer(){
        //if no Pause is on
//        let noFadeSwitch = defaults.bool(forKey: "noFadeSwitch")
//        if noFadeSwitch == true {
//            musicPlayer!.shuffleMode = MPMusicShuffleMode.off
//            musicPlayer!.play()
//            musicPlayer!.skipToNextItem()
//            musicPlayer!.pause()
//        }else{
            //Skip next and back to initialize the player
            musicPlayer!.shuffleMode = MPMusicShuffleMode.off
            musicPlayer!.play()
            musicPlayer!.skipToNextItem()
//        }
        setupPlaylist()
    }
    
    
    // MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        //try to recive remote control
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [])
        try! AVAudioSession.sharedInstance().setActive(true)
        
        self.becomeFirstResponder()
        
        mediaPickerDone = false
        songsSelected = false
        defaults.set(songsSelected, forKey: "songsSelected")
        
        spinner.style = .large
        spinner.color = .yellow
        spinner.transform = CGAffineTransform.init(scaleX: 2, y: 2)
        
        // keep device from sleeping
        UIApplication.shared.isIdleTimerDisabled = true
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
//        let level = UIDevice.current.batteryLevel
//        let battery_Level = Int(level * 100)
//        print("battery level ", battery_Level)

//        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
        //show volume slider
//        var wrapperView = UIView(frame: CGRectMake(30, 200, 260, 20))
//        self.view.backgroundColor = UIColor.clear
//        self.view.addSubview(wrapperView)
//        var volumeView = MPVolumeView(frame: wrapperView.bounds)
//        wrapperView.addSubview(volumeView)
        
        timeRemainingLabel?.adjustsFontSizeToFitWidth = true
        timeRemainingLabel?.textColor = .yellow
        
        timeRemaining2?.adjustsFontSizeToFitWidth = true
        timeRemaining2?.textColor = .yellow
        
        songTitleLabel.font = songTitleLabel.font.withSize(80)
        songTitleLabel.adjustsFontSizeToFitWidth = true
        
        //clock
        myClock.adjustsFontSizeToFitWidth = true
        myClock.backgroundColor = UIColor.clear
        
        myClockCountdown.adjustsFontSizeToFitWidth = true
        myClockCountdown.backgroundColor = UIColor.clear
        
        songTitleLabel.adjustsFontSizeToFitWidth = true
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            songTitleLabel.font = songTitleLabel.font.withSize(140)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        getOrientation()
    }
    
    // MARK: - GET CURRENT TIME AND BATTERY LEVEL
    @objc func getCurrentTime() {
        var batteryState: UIDevice.BatteryState { UIDevice.current.batteryState }
        let level = UIDevice.current.batteryLevel
        let battery_Level = Int(level * 100)
        print("battery level ", battery_Level)
        
        //let stringFloat =  String(describing: battery_Level)
        //batteryLevelLabel.text = stringFloat
        
        if battery_Level >= 100{
            batteryImage.image = UIImage(named: "battery100")
            //batteryLevelLabel.textColor = .black
        }
        if battery_Level <= 90{
            batteryImage.image = UIImage(named: "battery90")
            //batteryLevelLabel.textColor = .black
        }
        if battery_Level <= 80{
            batteryImage.image = UIImage(named: "battery80")
            //batteryLevelLabel.textColor = .black
        }
        if battery_Level <= 70{
            batteryImage.image = UIImage(named: "battery70")
            //batteryLevelLabel.textColor = .black
        }
        if battery_Level <= 60{
            batteryImage.image = UIImage(named: "battery60")
            //batteryLevelLabel.textColor = .black
        }
        if battery_Level <= 50{
            batteryImage.image = UIImage(named: "battery50")
            //batteryLevelLabel.textColor = .black
        }
        if battery_Level <= 40{
            batteryImage.image = UIImage(named: "battery40")
            //batteryLevelLabel.textColor = .black
        }
        if battery_Level <= 30{
            batteryImage.image = UIImage(named: "battery30")
            //batteryLevelLabel.textColor = .black
        }
        if battery_Level <= 20{
            batteryImage.image = UIImage(named: "battery20")
            //batteryLevelLabel.textColor = .black
        }
        if battery_Level <= 10{
            batteryImage.image = UIImage(named: "battery10")
            //batteryLevelLabel.textColor = .black
        }
        if battery_Level <= 5{
            batteryImage.image = UIImage(named: "battery5")
            //batteryLevelLabel.textColor = .black
        }
        
        switch batteryState {
        case .charging:
            batteryImage.image = UIImage(named: "batteryCharging")
            //batteryLevelLabel.text = ""
            print("charging")
        case .unknown:
            print("checking battery state")
        case .unplugged:
            print("unplugged")
        case .full:
            batteryImage.image = UIImage(named: "batteryCharging")
            //batteryLevelLabel.text = ""
            print("full battery")
        @unknown default:
            print("checking battery state")
        }
        
        var clockFormat24Switch: Bool
        clockFormat24Switch =
        defaults.bool(forKey: "clockFormat24Switch")
        //check to show 24hr or 12hr clock on display
        if clockFormat24Switch == true {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let date24 = dateFormatter.string(from: NSDate() as Date)
            myClock.text = String(date24)
        }else{
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm"
            formatter.amSymbol = ""
            formatter.pmSymbol = ""
            formatter.timeStyle = .short
            formatter.doesRelativeDateFormatting = true
            let d = formatter.string(from: NSDate() as Date)
            myClock.text = String(d)
        }
    }
    
    // MARK: - INITIALIZE MUSIC PLAYER
    func initializeMusicPlayer() {
        musicPlayer = MPMusicPlayerController.applicationQueuePlayer
        //musicPlayer = MPMusicPlayerController.applicationMusicPlayer
        
        // Start getting Notification when a song changes
        musicPlayer!.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingChanged(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        
        // Set Pause image
        if musicPlayer!.playbackState == MPMusicPlaybackState.playing {
            
            // Set Play image
        } else if musicPlayer!.playbackState == MPMusicPlaybackState.paused ||
                    musicPlayer!.playbackState == MPMusicPlaybackState.stopped {
        }
    }
    
    // MARK: - UPDATE SONG PROGRESS
    @objc func updateSongProgress() {
        
        if musicPlayer?.nowPlayingItem != nil{
            
            let currentItem: MPMediaItem = musicPlayer!.nowPlayingItem!
            let currentTime: Double = musicPlayer!.currentPlaybackTime
            
            // Set current song remaining time
            let nowPlayingItemDuration = currentItem.value(forProperty: MPMediaItemPropertyPlaybackDuration) as! Double
            let remainingTime: Double = nowPlayingItemDuration - currentTime
            // let hours = Int(remainingTime) / 3600
            let minutes = Int(remainingTime) / 60 % 60
            seconds = Int(remainingTime) % 60
            
            //print("now playing duration ", nowPlayingItemDuration)
            print("remaining Time ",remainingTime)
            
            // Show song time remaining
            timeRemainingLabel?.text = String(format:"%02i:%02i", minutes, seconds)
            timeRemaining2?.text =     String(format:"%02i:%02i", minutes, seconds)
        }
    }
    
    
    // MARK: - OPEN PLAYLIST BUTTON
    @IBAction func openPlaylistButt(_ sender: AnyObject) {
        songTitleLabel.alpha = 0
        
        
        //animate button
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.menuOutlet.transform = CGAffineTransform(scaleX: 0.7, y: 0.0)
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.menuOutlet.transform = CGAffineTransform.identity
            }
        })
        
        // Open the media Picker Controller to build your playlist
        let mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.anyAudio)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = true
        mediaPicker.prompt = "Select Playlist"
        
        present(mediaPicker, animated: true, completion: nil)
    }
    
    // MARK: - MEDIA PICKER DELEGATE -> Called when you built your playlist
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPickerDone = true
        songTitleLabel.text = ""
        songTitleLabel.alpha = 0
        
        createSpinnerView()
        
        musicPlayer!.shuffleMode = MPMusicShuffleMode.off
        
        //clean out previous playlist array
        myArray.removeAll()
        //save empty playlist to start new Playlist
        if mediaItemCollection.items.count > 0 {
            musicPlayer!.setQueue(with: mediaItemCollection)
            // Empty the arrays of songs
            songsCollection = nil
            musicPlayer!.shuffleMode = MPMusicShuffleMode.off
            songsCollection = mediaItemCollection as MPMediaItemCollection
            songs = songsCollection!.items as NSArray
            
            //so playlist view will fill tableview
            songsSelected = true
            defaults.set(songsSelected, forKey: "songsSelected")
            
            defaults.set(mediaItemCollection.items.count, forKey: "mediaItems")
            
            dismiss(animated: true, completion: nil)
            timeRemaining2.alpha = 0
            timeRemainingLabel!.alpha = 0
            loadingDone = true
            perform(#selector(setupPlayer), with: nil, afterDelay: 0.1)
        }
    }
    
    // MARK: - SPINNER ANIMATION
    func createSpinnerView() {
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // wait two seconds to simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // then remove the spinner view controller
            spinner.removeFromSuperview()
            self.mediaPickerDone = false
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //save Master Volume from settngs
    func saveMasterVolume() {
        defaults.set(volumeSlider.value, forKey: "myVolumeSlider")
        defaults.set(myVolume, forKey: "masterVolume")
    }
    
    // MARK: - PLAY BUTTON
    @IBAction func playPauseButt(_ sender: AnyObject) {
        let currentItem0 =  musicPlayer?.nowPlayingItem
        if currentItem0 == nil {
            self.showCustomAlertWith(
                message: "Please select songs for your playlist using the hamburger button in the bottom right corner.",
                descMsg: "",
                itemimage: nil,
                actions: nil)
            return
        }
        
        //animate button
        UIView.animate(withDuration: 0.2,
                       animations: {
            self.playPauseOutlet.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.playPauseOutlet.transform = CGAffineTransform.identity
            }
        })
        
        ///don't let volume fall to zero
        if myVolume! <= 0 {
            myVolume = defaults.float(forKey: "masterVolume")
            volumeSlider.value = myVolume!
            MPVolumeView.setVolume(myVolume!)
        }
        
        
       //this does not work correctly, it keeps any setting on ALL tracks
//            print("delay1 ", delay1)
//         if delay1 == true {
//            print("load Delay button On")
//            delay1 = false
//            musicPlayer!.pause()
//            delayTimeLabel.alpha = 1
//            delayTime?.text = defaults.string(forKey: text2b)
//            print("load delayTimeSaved ",delayTime?.text as Any)
//            xyz = Int((delayTime?.text)!) ?? 0
//            print("load xyz ", xyz)
//            
//            delayTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(delayTimeShow), userInfo: nil, repeats: true)
//           // return
//        }
        
        //Play song in loop until next track is pressed
//        if loop1 == true{
//            print("Loop button On")
//            loop1 = false
//            //musicPlayer!.repeatMode = MPMusicRepeatMode.one
//            var showTrackNumbers: Bool
//            showTrackNumbers = defaults.bool(forKey: "showTrackNumbers")
//            let currentItem = musicPlayer?.nowPlayingItem as MPMediaItem?
//            let songTitle = currentItem!.value(forProperty: MPMediaItemPropertyTitle) as! NSString
//            
//            //If track Numbers is turned On
//            if showTrackNumbers == true{
//                let songNumber = musicPlayer!.indexOfNowPlayingItem
//                let str2 = String(songNumber + 1)
//                print ("str2 " , str2)
//                songTitleLabel.text = str2 + " " + " \(String(describing: songTitle))"
//            }
//            else{
//                songTitleLabel.text = "\(String(describing: songTitle))"
//            }
//
//            //Only show first 30 characters of Song Title
//            let text = songTitleLabel.text
//            let resultPrefix = text!.prefix(30)
//            
//            songTitleLabel.adjustsFontSizeToFitWidth = true
//            songTitleLabel.minimumScaleFactor = 0.5
//            songTitleLabel.numberOfLines = 0
//            songTitleLabel.text = String(resultPrefix)
//            
//            musicPlayer!.play()
//            musicPlayer!.repeatMode = MPMusicRepeatMode.one
//            playPauseOutlet.setBackgroundImage(UIImage(systemName: "pause.fill")!, for: .normal)
//            playPauseOutlet.setBackgroundImage(UIImage(systemName: "pause.fill")!, for: .normal)
//            playPauseOutlet.tintColor = .green
//            songTitleLabel.textColor = .green
//        }
        
        // MARK: - PLAY/PAUSE SWITCH ON
        let playPauseSwitch = defaults.bool(forKey: "playPauseSwitch")
        if playPauseSwitch == true{
            
            if musicPlayer!.playbackState == MPMusicPlaybackState.playing {
                
                if seconds <= 6{
                    NSLog("seconds play/pause button", seconds)
                    return
                }
                
                playPauseOutlet.setBackgroundImage(UIImage(systemName:
                                                            "play.fill")!, for: .normal)
                playPauseOutlet.tintColor = .red
                songTitleLabel.textColor = .red
                
                segmentSelection = defaults.integer (forKey: "segment")
                //print("segment " ,  segmentSelection)
                if segmentSelection == 0{
                    fadeStarted = true
                    changeVolumeSlowly()
                }
                if segmentSelection == 1{
                    fadeStarted = true
                    changeVolumeSlowly1()
                }
                if segmentSelection == 2{
                    fadeStarted = true
                    changeVolumeSlowly2()
                }
                return
            }
        }
        
        if musicPlayer!.playbackState == MPMusicPlaybackState.playing {
            // PAUSE MUSIC
            musicPlayer!.pause()
            songTimer.invalidate()
            playPauseOutlet.setBackgroundImage(UIImage(systemName:
                                                        "play.fill")!, for: .normal)
            playPauseOutlet.tintColor = .yellow
            songTitleLabel.textColor = .yellow
        } else {
            let currentItem =  musicPlayer?.nowPlayingItem
            
            if currentItem != nil {
                myVolume = defaults.float(forKey: "masterVolume")
                volumeSlider.value = myVolume!
                MPVolumeView.setVolume(myVolume!)
                
                musicPlayer!.play()
                playPauseOutlet.setBackgroundImage(UIImage(systemName: "pause.fill")!, for: .normal)
                playPauseOutlet.tintColor = .green
                songTitleLabel.textColor = .green
                
                currentSongNumber = musicPlayer!.indexOfNowPlayingItem
                print("show track label   current playing ", currentSongNumber)
                
                //setup up to account for songs starting at zero to match start track time
                let addOne = +1
                currentSongNumber = currentSongNumber + addOne
                print("show track label new current song number ", currentSongNumber)
                
                startTrackLabel = defaults.integer(forKey:"showTrackLabel");
                print("show track label saved ", startTrackLabel as Any)
                
                if showcountdownSwitch == true && currentSongNumber == startTrackLabel{
                    self.myClockCountdown?.setValue(UIColor.green, forKeyPath: "textColor")
                    updateCountDownTimeProgress()
                }
            }
        }
        
        songTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSongProgress), userInfo: nil, repeats: true)
    }
    
    // MARK: - PREVIOUS SONG
    @IBAction func prevButt(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2,
                       animations: {
            self.previousButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.previousButton.transform = CGAffineTransform.identity
            }
        })
        
        playPauseOutlet.setBackgroundImage(UIImage(systemName:
                                                    "play.fill")!, for: .normal)
        playPauseOutlet.tintColor = .yellow
        songTitleLabel.textColor = .yellow
        musicPlayer!.skipToPreviousItem()
    }
    
    // MARK: - NEXT SONG
    @IBAction func nextButt(_ sender: AnyObject) {
       // saveCurrentVolume()
       // saveMasterVolume()
        
        UIView.animate(withDuration: 0.2,
                       animations: {
            self.nextButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.nextButton.transform = CGAffineTransform.identity
            }
        })
        
        //songTitleLabel.alpha = 1

        let playPauseSwitch = true
        
        if playPauseSwitch == true{
            
            if musicPlayer!.playbackState == MPMusicPlaybackState.playing {
                if seconds <= 6{
                    print("seconds next button ", seconds)
                    return
                }

                playPauseOutlet.setBackgroundImage(UIImage(systemName:
                                                            "play.fill")!, for: .normal)
                
                playPauseOutlet.tintColor = .red
                songTitleLabel.textColor = .red
                
                segmentSelection = defaults.integer (forKey: "segment")
                //print("segment " ,  segmentSelection)
                if segmentSelection == 0{
                    fadeStarted = true
                    changeVolumeSlowly()
                }
                if segmentSelection == 1{
                    fadeStarted = true
                    changeVolumeSlowly1()
                }
                if segmentSelection == 2{
                    fadeStarted = true
                    changeVolumeSlowly2()
                }
                return
            }

            musicPlayer!.skipToNextItem()
            
            if songTitleLabel.alpha == 0 {
                perform(#selector(addTitleAlpha), with: nil, afterDelay: 0.1)
            }
        }
    }
    
    @objc func addTitleAlpha() {
        //used to prevent long song titles from jumping full screen and back for a second
        songTitleLabel.alpha = 1
    }
    
    // MARK: - Device Orientation
    func getOrientation(){
        if  iPhoneDevice == true{
            if UIDevice.current.orientation.isLandscape {
                print("Orientation Landscape")
                timeRemainingLabel?.alpha = 1
                timeRemaining2?.alpha = 0
            }
            if UIDevice.current.orientation.isPortrait {
                print("Orientation Portrait")
                timeRemainingLabel?.alpha = 0
                timeRemaining2?.alpha = 1
            }
        }
        //iPad orientation
        if iPhoneDevice == false{
            timeRemainingLabel?.alpha = 1
            timeRemaining2?.alpha = 0
        }
    }
    
    // MARK: - FADE OPTIONS
//    func saveCurrentVolume(){
//        print("my volume save ", volumeSlider.value)
//        defaults.set(volumeSlider.value, forKey: "myVolumeSlider")
    
 //   defaults.set(volume, value(forKey: "myVolume"))
    
//        myVolume = defaults.float(forKey: "masterVolume")
//        MPVolumeView.setVolume(myVolume!)
//        currentVolume = myVolume!
//        print("my volume before fadeout")
//        print("my volume save ", currentVolume)
//    }
    
    @objc func changeVolumeSlowly(){
        songTitleLabel.alpha = 1
        volumeSlider.value = volumeSlider!.value - 0.1
        print("\(volumeSlider.value)")
        
        myVolume = volumeSlider.value
        MPVolumeView.setVolume(volumeSlider.value)
        
        if volumeSlider.value > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.changeVolumeSlowly()
            }
        }
        if volumeSlider.value == 0 {
            afterFadeOut()
        }
    }
    
    @objc func changeVolumeSlowly1(){
        songTitleLabel.alpha = 1
       volumeSlider!.value = volumeSlider.value - 0.1
       print("\(volumeSlider.value)")
        
        myVolume = volumeSlider.value
        MPVolumeView.setVolume(volumeSlider.value)
        
        if volumeSlider.value > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.changeVolumeSlowly1()
            }
        }
        if volumeSlider.value == 0 {
            afterFadeOut()
        }
    }
    
    @objc func changeVolumeSlowly2(){
        songTitleLabel.alpha = 1
        volumeSlider!.value = volumeSlider.value - 0.1
        print("\(volumeSlider.value)")
        
        myVolume = volumeSlider.value
        MPVolumeView.setVolume(volumeSlider.value)
        
        if volumeSlider.value > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                self?.changeVolumeSlowly2()
            }
        }
        if volumeSlider.value == 0 {
            afterFadeOut()
        }
    }
    
    func afterFadeOut()
    {
//        noFadeSwitch = false //stop play all in settings after fadeout
//        defaults.set(noFadeSwitch, forKey: "noFadeSwitch")
//        loop1 = false
//        print("Loop off ", loop1)
 
        //turn off loop feature after fade
        musicPlayer!.repeatMode = MPMusicRepeatMode.none
        
        
        musicPlayer!.skipToNextItem()
        playPauseOutlet.setBackgroundImage(UIImage(systemName:
                                                    "play.fill")!, for: .normal)
        playPauseOutlet.tintColor = .yellow
        songTitleLabel.textColor = .yellow
        
        volumeSlider.value = defaults.float (forKey: "myVolumeSlider")
        myVolume =  defaults.float(forKey: "masterVolume")
        MPVolumeView.setVolume(myVolume!)
        print ("my volume after fadeout ", myVolume!)
    }
    
    // MARK: - PLAY BUTTON 2 used for delay option
    func playPauseButt2() {
        defaults.set(volumeSlider.value, forKey: "myVolumeSlider")
        musicPlayer!.play()
        playPauseOutlet.setBackgroundImage(UIImage(systemName: "pause.fill")!, for: .normal)
        playPauseOutlet.tintColor = .green
        songTitleLabel.textColor = .green
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.timerRunning = false
        self.countdownTimer.invalidate()
        countdownTimer.invalidate()
        timerRunning = false
        showcountdownSwitch = false
        songTimer .invalidate()
        currentTimeTimer .invalidate()
        batteryStatusTimer .invalidate()
        delayTimer.invalidate()
        // stopTimer()
        showcountdownSwitch = false
    }
}


