//
//  AudioScrubberVC.swift
//  CustomAudioTrimmer
//
//  Created by Ahmad's MacMini on 25/11/22.
//

import UIKit

class AudioScrubberVC: UIViewController {
    
    @IBOutlet var trimmerView: AAudioTrimmerView!
    @IBOutlet var viewBottom: UIView!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var lblSelectedSec: UILabel!
    
    var tempVideoPath = ""
    var exportSession : AVAssetExportSession?
    
    var strTrimmedAudioURL = ""
    
    var asset : AVAsset?
    var isPlaying = false
    var restartOnPlay = false
    var player : AVPlayer?
    var playerItem : AVPlayerItem?
    var playerLayer : AVPlayerLayer?
    var playbackTimeCheckerTimer : Timer?
    var videoPlaybackPosition : CGFloat = 0
    
    var startTime : CGFloat = 0
    var stopTime : CGFloat = 0
    var selectedDuration : Int = 22
    
    @IBOutlet var lblCurrentTime: UILabel!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var lblTotalTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        lblSelectedSec.text = "\(selectedDuration)sec is selected"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupUI()
    }
    
    func setupUI(){
        
        viewBottom.layer.cornerRadius = 10
        
        let url = Bundle.main.url(forResource: "Aadat", withExtension: "mp3")
        
        tempVideoPath = url?.path ?? ""
        let audioAsset = AVAsset(url: url!)
        
        self.asset = audioAsset
        
        let audioDurationSeconds = CMTimeGetSeconds(audioAsset.duration);
        let minutes = Int((audioDurationSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(audioDurationSeconds.truncatingRemainder(dividingBy: 60))
        
        lblTotalTime.text = String(format: "/ %02i:%02i", minutes, seconds)
        
        let item = AVPlayerItem(asset: self.asset!)
        
        
        self.player = AVPlayer(playerItem: item)
        self.playerLayer = AVPlayerLayer(layer: self.player!)
        self.playerLayer?.contentsGravity = .resizeAspect;
        self.player?.actionAtItemEnd = .none;
        
        self.btnPlay.addTarget(self, action: #selector(self.audioPlayPauseAction), for: .touchUpInside)
        
        self.videoPlaybackPosition = 0;
        
        
        // set properties for trimmer view
        self.trimmerView.themeColor = .lightGray
        self.trimmerView.asset = self.asset
        self.trimmerView.showsRulerView = false
        self.trimmerView.rulerLabelInterval = 15
        self.trimmerView.maxLength = CGFloat(selectedDuration)
        self.trimmerView.trackerColor = .black
        self.trimmerView.delegate = self
        
        // important: reset subviews
        self.trimmerView.resetSubviews()
        
        
        self.btnCancel.addTarget(self, action: #selector(self.dismissView), for: .touchUpInside)
        self.btnDone.addTarget(self, action: #selector(self.trimAudio), for: .touchUpInside)
    }
    
    func deleteTempFile()
    {
        let url = URL(fileURLWithPath: self.tempVideoPath)
        let fm = FileManager.default
        let exist = fm.fileExists(atPath: url.path)
        
        //        let err : Error?
        if (exist) {
            
            do{
                try! fm.removeItem(at: url)
                print("file deleted");
            }catch{
                print("file remove error");
            }
            
        } else {
            print("no file by that name");
        }
    }
    
    @objc func dismissView()
    {
        
        if (self.isPlaying) {
            self.player?.pause()
            self.stopPlaybackTimeChecker()
        }
        
        self.dismiss(animated: true)
    }
    
    @objc func trimAudio()
    {
        
        if (self.isPlaying) {
            self.player?.pause()
            self.stopPlaybackTimeChecker()
        }
        
        let furl = URL(fileURLWithPath: self.tempVideoPath)
        
        //        let start = CMTime(seconds: self.startTime, preferredTimescale: self.asset?.duration.timescale ?? CMTimeScale())
        //        let duration = CMTime(seconds: self.stopTime - self.startTime, preferredTimescale: self.asset?.duration.timescale ?? CMTimeScale())
        //
        //        let range = CMTimeRange(start: start,duration: duration)
        //
        self.trimAudioNew(sourceURL: furl, startTime: self.startTime, stopTime: self.startTime + CGFloat(self.selectedDuration)) { outputURL in
            print("Audio URL is:: \(outputURL)")
            
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Downloaded path", message: "\(outputURL)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            }
           
            
        } failure: { failure in
            print("trimming failed: \(failure?.description)")
        }
        
    }
    
    @objc func savedImage(_ im:UIImage, error:Error?, context:UnsafeMutableRawPointer?) {
        if let err = error {
            print(err)
            return
        }
        print("success")
    }
    
    //MARK: crop the Audio which you select portion
    func trimAudioNew(sourceURL: URL, startTime: Double, stopTime: Double, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        /// Asset
        ///
        let asset = AVAsset(url: sourceURL)
        //        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        //        print("video length: \(length) seconds")
        
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith:asset)
        
        if compatiblePresets.contains(AVAssetExportPresetMediumQuality) {
            
            //Create Directory path for Save
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            var outputURL = documentDirectory.appendingPathComponent("TrimAudio")
            do {
                try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                var newSourceURL = sourceURL
                newSourceURL.deletePathExtension()
                outputURL = outputURL.appendingPathComponent("\(newSourceURL.lastPathComponent).m4a")
            }catch let error {
                failure(error.localizedDescription)
            }
            
            //Remove existing file
            self.deleteFile(outputURL)
            
            //export the audio to as per your requirement conversion
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else{return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.m4a
            
            let range: CMTimeRange = CMTimeRangeFromTimeToTime(start: CMTimeMakeWithSeconds(startTime, preferredTimescale: asset.duration.timescale), end: CMTimeMakeWithSeconds(stopTime, preferredTimescale: asset.duration.timescale))
            exportSession.timeRange = range
            
            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed:
                    success(outputURL)
                    
                case .failed:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                    
                case .cancelled:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                    
                default:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                }
            })
        }
    }
    
    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
    
    @objc func audioPlayPauseAction()
    {
        if (self.isPlaying) {
            self.player?.pause()
            self.stopPlaybackTimeChecker()
        }else {
            if (restartOnPlay){
                self.seekVideoToPos(pos: self.startTime);
                self.trimmerView.seek(toTime: self.startTime)
                restartOnPlay = false;
            }
            self.player?.play()
            self.startPlaybackTimeChecker()
        }
        self.isPlaying = !self.isPlaying;
        self.trimmerView.hideTracker(!self.isPlaying)
    }
    
    func startPlaybackTimeChecker()
    {
        self.stopPlaybackTimeChecker()
        
        self.playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onPlaybackTimeCheckerTimer), userInfo: nil, repeats: true)
        
    }
    
    func stopPlaybackTimeChecker()
    {
        if ((self.playbackTimeCheckerTimer) != nil) {
            self.playbackTimeCheckerTimer?.invalidate()
            self.playbackTimeCheckerTimer = nil;
        }
    }
    
    //MARK: - PlaybackTimeCheckerTimer
    
    @objc func onPlaybackTimeCheckerTimer()
    {
        guard let curTime = self.player?.currentTime() else { return }
        var seconds = CMTimeGetSeconds(curTime)
        if (seconds < 0){
            seconds = 0; // this happens! dont know why.
        }
        self.videoPlaybackPosition = seconds;
        
        self.trimmerView.seek(toTime: seconds)
        
        if (self.videoPlaybackPosition >= self.stopTime) {
            self.videoPlaybackPosition = self.startTime;
            self.seekVideoToPos(pos: self.startTime)
            self.trimmerView.seek(toTime: self.startTime)
        }
    }
    
    func seekVideoToPos(pos:CGFloat)
    {
        self.videoPlaybackPosition = pos;
        let time = CMTime(seconds: self.videoPlaybackPosition, preferredTimescale: self.player?.currentTime().timescale ?? CMTimeScale())
        
        //NSLog(@"seekVideoToPos time:%.2f", CMTimeGetSeconds(time));
        self.player?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { bool in
            
        })
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension AudioScrubberVC: AAudioTrimmerDelegate{
    
    func audioTrimmerView(_ trimmerView: AAudioTrimmerView, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
        
        restartOnPlay = true;
        self.player?.pause()
        self.isPlaying = false;
        self.stopPlaybackTimeChecker()
        
        self.trimmerView.hideTracker(true)
        
        if (startTime != self.startTime) {
            //then it moved the left position, we should rearrange the bar
            self.seekVideoToPos(pos: startTime)
        }
        else{ // right has changed
            self.seekVideoToPos(pos: endTime)
        }
        self.startTime = startTime;
        self.stopTime = endTime;
        
        let minutes = Int((startTime.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(startTime.truncatingRemainder(dividingBy: 60))
        
        lblCurrentTime.text = String(format: "%02i:%02i", minutes, seconds)
        //tapOnVideoLayer()
        
        
    }
    
    func audioTrimmerViewDidEndEditing(_ trimmerView: AAudioTrimmerView) {
        audioPlayPauseAction()
    }
}
