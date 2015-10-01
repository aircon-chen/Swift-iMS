//
//  ViewController.swift
//  iMS
//
//  Created by Chen Hsin Hsuan on 2015/5/21.
//  Copyright (c) 2015年 AirconTW. All rights reserved.
//

import UIKit
import Spring
import AVFoundation
import GoogleMobileAds;

let path = NSBundle.mainBundle().pathForResource("clefList", ofType: "plist")
let clefDict = NSDictionary(contentsOfFile: path!)

let G_CLEF = "G-Clef"
let F_CLEF = "F-Clef"
let MIX_CLEF = "Mix-Clef"

class ViewController: SuperViewController, GADInterstitialDelegate {

    @IBOutlet weak var clefButton: SpringButton!
    @IBOutlet weak var rightAnswerLabel: SpringLabel!
    @IBOutlet weak var wrongAnswerLabel: SpringLabel!
    @IBOutlet weak var musicNoteImageView: SpringImageView!
    
    var correctCount = 0    //正確數
    var errorCount = 0      //錯誤數
    var noteDict = clefDict?.objectForKey(G_CLEF) as! NSDictionary  // 預設Ｇ譜號
    var musicNoteKeyArray = Array<String>()
    var musicNote:String?

    var interstitial:GADInterstitial!

    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        createMusicNote()

        
        //廣告宣告
        self.interstitial = createAndLoadInterstitial()
    }

    
    
    @IBAction func keyBoardTouchDown(sender: SpringButton) {
        
        var path:String!
        path = noteDict.valueForKey(musicNote!) as! String
        
        let index = Int((musicNote!as NSString).substringFromIndex(1))

        
        if self.clefButton.titleLabel == G_CLEF {
            if(index == 1){
                path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)3", ofType:"mp3")

            }else if(index > 15){
                path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)6", ofType:"mp3")
            }else if(index > 8){
                path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)5", ofType:"mp3")
            }else{
                path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)4", ofType:"mp3")
            }

        }else if self.clefButton.titleLabel == F_CLEF {

            if(index == 1){
                path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)4", ofType:"mp3")
            }else if(index > 15){
                path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)1", ofType:"mp3")
            }else if(index > 8){
                path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)2", ofType:"mp3")
            }else{
                path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)3", ofType:"mp3")
            }
   
        }else if self.clefButton.titleLabel == MIX_CLEF {
            
            let clef = (musicNote!as NSString).substringWithRange(NSMakeRange(0, 1))
            if clef == "G"{
                if(index == 1){
                    path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)3", ofType:"mp3")
                }else if(index > 15){
                    path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)6", ofType:"mp3")
                }else if(index > 8){
                    path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)5", ofType:"mp3")
                }else{
                    path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)4", ofType:"mp3")
                }

            }else{
                if(index == 1){
                    path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)4", ofType:"mp3")
                }else if(index > 15){
                    path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)1", ofType:"mp3")
                }else if(index > 8){
                    path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)2", ofType:"mp3")
                }else{
                    path = NSBundle.mainBundle().pathForResource("\(sender.titleLabel!.text!.lowercaseString)3", ofType:"mp3")
                }

            }
        
        }
        
        playSound(path!)
    }
    
    //MARK:按下鋼琴按鍵
    @IBAction func keyBoardPressed(sender: SpringButton) {
    
//        var path:String?
        let answer = noteDict.valueForKey(musicNote!) as! String
        if sender.titleLabel!.text == answer {
            //            path = NSBundle.mainBundle().pathForResource("crrect_answer1", ofType:"mp3")
            
            self.correctCount++
            
            rightAnswerLabel.animation = "pop"
            rightAnswerLabel.scaleX = 1.5
            rightAnswerLabel.scaleY = 1.5
            updateRightAnswerLabel()
             rightAnswerLabel.animate()
            

            createMusicNote()
        }else{

//            path = NSBundle.mainBundle().pathForResource("blip1", ofType:"mp3")
            
            
            self.errorCount++
            
        
            if self.errorCount % 10 == 0 {
                showAd()
            }
            
            
            
            wrongAnswerLabel.animation = "pop"
            wrongAnswerLabel.scaleX = 1.5
            wrongAnswerLabel.scaleY = 1.5
            updateWrongAnswerLabel()
            wrongAnswerLabel.animate()
        }
        
//                playSound(path!)
    }
    
    
    //MARK:切換譜號
    @IBAction func clefButtonPressed(sender: SpringButton) {
        
        if self.clefButton.titleLabel?.text == G_CLEF {
            self.clefButton.setTitle(F_CLEF, forState:  UIControlState.Normal)
        }else if self.clefButton.titleLabel?.text == F_CLEF {
            self.clefButton.setTitle(MIX_CLEF, forState: UIControlState.Normal)
        }else if self.clefButton.titleLabel?.text == MIX_CLEF {
            self.clefButton.setTitle(G_CLEF, forState: UIControlState.Normal)
        }
        changeClef()
    }
    
    //MARK:更新成績Label
    func updateResultLabel(){
        updateRightAnswerLabel()
        updateWrongAnswerLabel()
    }
    
    func updateRightAnswerLabel(){
        rightAnswerLabel.text = String(correctCount)
    }
    
    func updateWrongAnswerLabel(){
        wrongAnswerLabel.text = String(errorCount)
    }
    
    //MARK:切換譜號
    func changeClef(){
        
        let path = NSBundle.mainBundle().pathForResource("blackout_dulcimer1", ofType:"mp3")
        playSound(path!)
        
        //成績歸零
        correctCount = 0
        errorCount = 0
        updateResultLabel()
        
        
        self.clefButton.animation = "swing"
        self.clefButton.scaleX = 1.5
        self.clefButton.scaleY = 1.5
        self.clefButton.duration = 3
        self.clefButton.animate()
        
        
        
        noteDict = clefDict?.objectForKey(self.clefButton.titleLabel!.text!) as! NSDictionary
        createMusicNote()
    }
    
    //MARK:變換音樂符號
    func createMusicNote(){
        updateResultLabel()
        let randomNumber =  Int(arc4random()) % noteDict.count
        musicNoteKeyArray = noteDict.allKeys as! Array<String>
        musicNote = musicNoteKeyArray[randomNumber]


        musicNoteImageView.animation = "fadeIn"
        musicNoteImageView.image = UIImage(named: "\(musicNote!)")

        musicNoteImageView.animate()

//        print("clef:\(musicNote!)")
    }

    
    func playSound(path:String){
        let fileURL = NSURL(fileURLWithPath: path)
        let audioPlayer: AVAudioPlayer? = try? AVAudioPlayer(contentsOfURL: fileURL)
        if let audioPlayer = audioPlayer {
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }

    }
    
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let theInterstitial = GADInterstitial(adUnitID: "ca-app-pub-5200673733349176/8483398845")
        theInterstitial.delegate = self
        let request = GADRequest()
        request.testDevices = ["2077ef9a63d2b398840261c8221a0c9b"]
        theInterstitial.loadRequest(request)
        return theInterstitial
    }
    
    func showAd(){
        if (self.interstitial.isReady) {
            self.interstitial.presentFromRootViewController(self)
        }
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        self.interstitial = createAndLoadInterstitial()
    }

}

