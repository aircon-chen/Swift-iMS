//
//  ViewController.swift
//  iMS
//
//  Created by Chen Hsin Hsuan on 2015/5/21.
//  Copyright (c) 2015年 AirconTW. All rights reserved.
//

import UIKit
import AVFoundation
@preconcurrency import GoogleMobileAds

@MainActor
let path = Bundle.main.path(forResource: "clefList", ofType: "plist")

@MainActor
let clefDict = NSDictionary(contentsOfFile: path!)

let G_CLEF = "G-Clef"
let F_CLEF = "F-Clef"
let MIX_CLEF = "Mix-Clef"

@MainActor
class ViewController: SuperViewController, GADFullScreenContentDelegate {

    @IBOutlet weak var clefButton: UIButton!
    @IBOutlet weak var rightAnswerLabel: UILabel!
    @IBOutlet weak var wrongAnswerLabel: UILabel!
    @IBOutlet weak var musicNoteImageView: UIImageView!
    
    var correctCount = 0    // 正確數
    var errorCount = 0      // 錯誤數
    var noteDict = clefDict?.object(forKey: G_CLEF) as! NSDictionary  // 預設Ｇ譜號
    var musicNoteKeyArray = Array<String>()
    var musicNote: String?
    var soundPath: String!
    var audioPlayer: AVAudioPlayer?
    
    // Google Ads SDK 尚未完全支援 Swift 6 並發，使用 nonisolated(unsafe) 來避免編譯錯誤
    // 由於 GADInterstitialAd.load 的 completion handler 保證在主線程執行，所以實際使用是安全的
    nonisolated(unsafe) var interstitial: GADInterstitialAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMusicNote()
        
        // 廣告宣告
        loadInterstitial()
    }
    
    // MARK: - Keyboard Actions
    
    @IBAction func keyBoardTouchDown(_ sender: UIButton) {
        guard let musicNote = musicNote else { return }
        self.soundPath = noteDict.value(forKey: musicNote) as? String
        
        let index = Int((musicNote as NSString).substring(from: 1))!
        
        guard let buttonText = sender.titleLabel?.text?.lowercased() else { return }
        
        if self.clefButton.titleLabel?.text == G_CLEF {
            if index == 1 {
                soundPath = Bundle.main.path(forResource: "\(buttonText)3", ofType: "mp3")!
            } else if index > 15 {
                soundPath = Bundle.main.path(forResource: "\(buttonText)6", ofType: "mp3")!
            } else if index > 8 {
                soundPath = Bundle.main.path(forResource: "\(buttonText)5", ofType: "mp3")!
            } else {
                soundPath = Bundle.main.path(forResource: "\(buttonText)4", ofType: "mp3")!
            }
        } else if self.clefButton.titleLabel?.text == F_CLEF {
            if index == 1 {
                soundPath = Bundle.main.path(forResource: "\(buttonText)4", ofType: "mp3")!
            } else if index > 15 {
                soundPath = Bundle.main.path(forResource: "\(buttonText)1", ofType: "mp3")!
            } else if index > 8 {
                soundPath = Bundle.main.path(forResource: "\(buttonText)2", ofType: "mp3")!
            } else {
                soundPath = Bundle.main.path(forResource: "\(buttonText)3", ofType: "mp3")!
            }
        } else if self.clefButton.titleLabel?.text == MIX_CLEF {
            let clef = (musicNote as NSString).substring(with: NSMakeRange(0, 1))
            if clef == "G" {
                if index == 1 {
                    soundPath = Bundle.main.path(forResource: "\(buttonText)3", ofType: "mp3")!
                } else if index > 15 {
                    soundPath = Bundle.main.path(forResource: "\(buttonText)6", ofType: "mp3")!
                } else if index > 8 {
                    soundPath = Bundle.main.path(forResource: "\(buttonText)5", ofType: "mp3")!
                } else {
                    soundPath = Bundle.main.path(forResource: "\(buttonText)4", ofType: "mp3")!
                }
            } else {
                if index == 1 {
                    soundPath = Bundle.main.path(forResource: "\(buttonText)4", ofType: "mp3")!
                } else if index > 15 {
                    soundPath = Bundle.main.path(forResource: "\(buttonText)1", ofType: "mp3")!
                } else if index > 8 {
                    soundPath = Bundle.main.path(forResource: "\(buttonText)2", ofType: "mp3")!
                } else {
                    soundPath = Bundle.main.path(forResource: "\(buttonText)3", ofType: "mp3")!
                }
            }
        }
        
        playSound(self.soundPath)
    }
    
    // MARK: - 按下鋼琴按鍵
    @IBAction func keyBoardPressed(_ sender: UIButton) {
        guard let musicNote = musicNote else { return }
        let answer = noteDict.value(forKey: musicNote) as! String
        
        if sender.titleLabel!.text == answer {
            self.correctCount += 1
            
            updateRightAnswerLabel()
            rightAnswerLabel.performSpringAnimation(
                animation: "pop",
                scaleX: 1.5,
                scaleY: 1.5
            )
            
            createMusicNote()
        } else {
            self.errorCount += 1
            
            if self.errorCount % 10 == 0 {
                showAd()
            }
            
            updateWrongAnswerLabel()
            wrongAnswerLabel.performSpringAnimation(
                animation: "pop",
                scaleX: 1.5,
                scaleY: 1.5
            )
        }
    }
    
    // MARK: - 切換譜號
    @IBAction func clefButtonPressed(_ sender: UIButton) {
        if self.clefButton.titleLabel?.text == G_CLEF {
            self.clefButton.setTitle(F_CLEF, for: .normal)
        } else if self.clefButton.titleLabel?.text == F_CLEF {
            self.clefButton.setTitle(MIX_CLEF, for: .normal)
        } else if self.clefButton.titleLabel?.text == MIX_CLEF {
            self.clefButton.setTitle(G_CLEF, for: .normal)
        }
        changeClef()
    }
    
    // MARK: - 更新成績 Label
    func updateResultLabel() {
        updateRightAnswerLabel()
        updateWrongAnswerLabel()
    }
    
    func updateRightAnswerLabel() {
        rightAnswerLabel.text = String(correctCount)
    }
    
    func updateWrongAnswerLabel() {
        wrongAnswerLabel.text = String(errorCount)
    }
    
    // MARK: - 切換譜號
    func changeClef() {
        self.soundPath = Bundle.main.path(forResource: "blackout_dulcimer1", ofType: "mp3")
        playSound(self.soundPath)
        
        // 成績歸零
        correctCount = 0
        errorCount = 0
        updateResultLabel()
        
        clefButton.performSpringAnimation(
            animation: "swing",
            duration: 3.0,
            scaleX: 1.5,
            scaleY: 1.5
        )
        
        noteDict = clefDict?.object(forKey: self.clefButton.titleLabel!.text!) as! NSDictionary
        createMusicNote()
    }
    
    // MARK: - 變換音樂符號
    func createMusicNote() {
        updateResultLabel()
        let randomNumber = Int.random(in: 0..<noteDict.count)
        musicNoteKeyArray = noteDict.allKeys as! Array<String>
        musicNote = musicNoteKeyArray[randomNumber]
        
        musicNoteImageView.image = UIImage(named: "\(musicNote!)")
        musicNoteImageView.performSpringAnimation(animation: "fadeIn")
    }

    // MARK: - Audio Player
    func playSound(_ path: String) {
        let fileURL = URL(fileURLWithPath: path)
        self.audioPlayer = try? AVAudioPlayer(contentsOf: fileURL)
        if let audioPlayer = self.audioPlayer {
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
    // MARK: - Google Ads
    func loadInterstitial() {
        print("🔄 開始加載插頁式廣告...")
        let request = GADRequest()
        
        // 根據編譯配置自動選擇廣告 ID
        #if DEBUG
        let adUnitID = "ca-app-pub-3940256099942544/4411468910" // 測試廣告 ID
        print("📱 使用測試廣告 ID (Debug Mode)")
        #else
        let adUnitID = "ca-app-pub-5200673733349176/8483398845" // 正式廣告 ID
        print("📱 使用正式廣告 ID (Release Mode)")
        #endif
        
        GADInterstitialAd.load(
            withAdUnitID: adUnitID,
            request: request
        ) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                print("❌ 廣告加載失敗: \(error.localizedDescription)")
                return
            }
            print("✅ 廣告加載成功！")
            // interstitial 已標記為 nonisolated(unsafe)，可以安全地在此處賦值
            // Google Ads SDK 保證 completion handler 在主線程執行
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
    }
    
    func showAd() {
        print("📢 嘗試顯示廣告... (錯誤次數: \(errorCount))")
        if let interstitial = self.interstitial {
            print("✅ 廣告已就緒，準備顯示")
            interstitial.present(fromRootViewController: self)
        } else {
            print("⚠️ 廣告尚未就緒，開始重新加載")
            loadInterstitial()
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("✅ 廣告已關閉")
        Task { @MainActor in
            loadInterstitial()
        }
    }
    
    nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ 廣告顯示失敗: \(error.localizedDescription)")
        Task { @MainActor in
            loadInterstitial()
        }
    }
    
    nonisolated func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("📱 廣告即將顯示")
    }
    
    nonisolated func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("👁️ 廣告曝光已記錄")
    }
}

