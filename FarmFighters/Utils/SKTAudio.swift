//
//  SKTAudio.swift
//  FarmFighters
//
//  Created by Rania Pryanka Arazi on 25/06/24.
//


private let SKTAudioInstance = SKTAudio()
import AVFoundation

class SKTAudio{
    var bgMusic: AVAudioPlayer?
    
    
    static let keyMusic = "keyMusic"

    static var musicEnabled: Bool = {
        return !UserDefaults.standard.bool(forKey: keyMusic)
    } () {
        didSet {
            let value = !musicEnabled
            UserDefaults.standard.set(value, forKey: keyMusic)

        }
    }
    
    static func sharedInstance() -> SKTAudio {
        return SKTAudioInstance
    }
    
    func playBGMusic(_ fileNamed: String, volume: Float = 0.5) {
        
        if !SKTAudio.musicEnabled {
            return
        }
        
        
        guard let url = Bundle.main.url(forResource: fileNamed, withExtension: nil) else {
            return
        }
        
        do {
            bgMusic = try AVAudioPlayer(contentsOf: url)
        }
        catch let error as NSError {
            bgMusic = nil
        }
        
        if let bgMusic = bgMusic {
            bgMusic.numberOfLoops = -1
            bgMusic.prepareToPlay()
            bgMusic.volume = volume
            bgMusic.play()
        }
    }
}
