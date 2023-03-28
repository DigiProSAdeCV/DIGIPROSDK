import UIKit
import AVFoundation
import AudioToolbox
import Eureka
import WebKit

protocol AudioOptions: AnyObject {
    func didCancel()
}

class AudioRecorderViewController:  UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, TypedRowControllerType {
    
    public weak var delegate: AudioOptions?
    
    lazy var superView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var titleController : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
        label.text = "Grabación de Audio"
        return label
    }()
    
    lazy var lblMessage : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
        label.text = "Iniciar"
        return label
    }()
    
    lazy var duration : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
        label.text = "Duración"
        return label
    }()
    
    lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
        label.text = "00:00.00"
        return label
    }()
    
    lazy var audioVisualizationView : AudioVisualizationView = {
        let view = AudioVisualizationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var textInfo : UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    lazy var btnOkCheck: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 20
        button.setImage(UIImage(named: "check_full", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        return button
    }()
    
    lazy var recordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.setImage(UIImage(named: "ic_playVid", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        button.backgroundColor = UIColor(hexFromString: self.atributos?.coloraudio ?? "#1E88E5")
        return button
    }()
    
    lazy var btnCerrar: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Cnstnt.Color.red2
        button.layer.cornerRadius = button.frame.height / 2
        button.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        return button
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.translatesAutoresizingMaskIntoConstraints = false
        return activity
    }()
    
    // PUBLIC
    public let guid = ConfigurationManager.shared.utilities.guid()
    public var path = ""
    public var timeRecord : String = ""
    private var averagePower: Float = 0.0
    
    /// The row that pushed or presented this controller
    public var row: RowOf<String>!
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    public var atributos: Atributos_audio?
    
    // PRIVATE
    var statusBarStyle: UIStatusBarStyle = .default
    var effect = UIVisualEffect.self
    
    var isRecord = false
    var timeTimer: Timer?
    var milliseconds: Int = 0
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var outputURL: URL?
    var arrayPlayer: [String] = []
    var stringURL: String = ""
    var timeString: String = ""
    let imagePicker = UIImagePickerController()
    
    let settings = [AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC), AVSampleRateKey: NSNumber(value: 48000), AVNumberOfChannelsKey: NSNumber(value: 2)]
    
    deinit{
        atributos = nil
        timeTimer = nil
        recorder = nil
        player = nil
        outputURL = nil
        arrayPlayer = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.gray
        
        let url = Bundle.main.url(forResource: "waveform", withExtension: "gif")
        let data = try! Data(contentsOf: url!)
        //self.waveEffect.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: ""))
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        self.textInfo.text = self.atributos?.leyendaaudio ?? ""
        
        self.btnOkCheck.isHidden = true
        
        audioVisualizationView = AudioVisualizationView(frame: CGRect(x: 20, y: 80, width: view.frame.size.width - 40, height: 30))
        self.audioVisualizationView.meteringLevelBarWidth = 2.0
        self.audioVisualizationView.meteringLevelBarInterItem = 1.0
        self.audioVisualizationView.meteringLevelBarCornerRadius = 0.0
        self.audioVisualizationView.meteringLevelBarSingleStick = true
        self.audioVisualizationView.gradientStartColor = .white
        self.audioVisualizationView.gradientEndColor = .black
        self.audioVisualizationView.isHidden = true
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(superView)
        superView.addSubview(titleController)
        superView.addSubview(audioVisualizationView)
        superView.addSubview(textInfo)
        superView.addSubview(duration)
        superView.addSubview(timeLabel)
        superView.addSubview(lblMessage)
        superView.addSubview(btnOkCheck)
        superView.addSubview(recordButton)
        superView.addSubview(btnCerrar)
        superView.addSubview(activityIndicatorView)
        
        // We need to set a dummy audio file
        self.timeLabel.text = "00:00.00"
        if FCFileManager.existsItem(atPath: "dummy.aac"){
            FCFileManager.removeItem(atPath: "dummy.aac")
        }
        FCFileManager.createFile(atPath: "dummy.aac", overwrite: true)
        outputURL = FCFileManager.urlForItem(atPath: "dummy.aac")
        
        try! recorder = AVAudioRecorder(url: outputURL!, settings: settings)
        recorder!.delegate = self
        recorder!.prepareToRecord()
        
        activityIndicatorView.isHidden = true
        btnCerrar.layer.cornerRadius = btnCerrar.frame.height / 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        audioVisualizationView.isHidden = true
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            NSLog("Error: \(error)")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopRecording(sender:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        btnCerrar.addTarget(self, action: #selector(closeView), for: UIControl.Event.allEvents)
        recordButton.addTarget(self, action: #selector(toggleRecord(_:)), for: UIControl.Event.touchUpInside)
        btnOkCheck.addTarget(self, action: #selector(saveAction(_:)), for: UIControl.Event.touchUpInside)
    }
    
    // MARK: Constraints
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            superView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            superView.heightAnchor.constraint(equalToConstant: 280),
            superView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            superView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            btnCerrar.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -1),
            btnCerrar.widthAnchor.constraint(equalToConstant: 50),
            btnCerrar.heightAnchor.constraint(equalToConstant: 50),
            btnCerrar.topAnchor.constraint(equalTo: superView.topAnchor, constant: -25),
            
            titleController.topAnchor.constraint(equalTo: superView.topAnchor, constant: 20),
            titleController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleController.heightAnchor.constraint(equalToConstant: 30),
            
            btnOkCheck.widthAnchor.constraint(equalToConstant: 50),
            btnOkCheck.heightAnchor.constraint(equalToConstant: 50),
            btnOkCheck.topAnchor.constraint(equalTo: audioVisualizationView.bottomAnchor, constant: 10),
            btnOkCheck.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            recordButton.widthAnchor.constraint(equalToConstant: 50),
            recordButton.heightAnchor.constraint(equalToConstant: 50),
            recordButton.topAnchor.constraint(equalTo: btnOkCheck.bottomAnchor, constant: 10),
            recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            textInfo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textInfo.topAnchor.constraint(equalTo: audioVisualizationView.bottomAnchor, constant: 20),
            textInfo.trailingAnchor.constraint(equalTo: btnOkCheck.leadingAnchor, constant: -15),
            textInfo.heightAnchor.constraint(equalToConstant: 100),
            
            duration.topAnchor.constraint(equalTo: textInfo.bottomAnchor, constant: 10),
            duration.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            
            timeLabel.topAnchor.constraint(equalTo: textInfo.bottomAnchor, constant: 10),
            timeLabel.leadingAnchor.constraint(equalTo: duration.trailingAnchor, constant: 5),
            
            lblMessage.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 10),
            lblMessage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -23),
            
            activityIndicatorView.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: superView.centerYAnchor),
        ])
    }
    
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    
    // Ponerlo a un didDismiss del componente
    @objc func cancelAction(_ sender: Any) {
        recorder!.stop()
        cleanup()
        self.updateControls()
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        self.onDismissCallback?(self)
        
    }
    
    @objc func closeView() {
        DispatchQueue.main.async {
            self.activityIndicatorView.isHidden = false
            self.activityIndicatorView.startAnimating()
            if let navController = self.navigationController {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
                navController.popViewController(animated: true)
            }
            self.onDismissCallback?(self)
        }
        delegate?.didCancel()
    }
    
    @objc func closeAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.activityIndicatorView.isHidden = false
            self.activityIndicatorView.startAnimating()
        }
        DispatchQueue.global(qos: .background).async {
            if self.isRecord {
                self.recorder!.stop()
                self.cleanup()
                self.path = "\(ConfigurationManager.shared.guid)_\(self.row.tag ?? "0")_1_\(self.guid).ane"
                
                let data = FCFileManager.readFileAtPath(asData: "dummy.aac")
                guard let data = data else {
                    print("Data invalida")
                    return
                }
                let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(data as NSData, self.path)
                FCFileManager.removeItem(atPath: "dummy.aac")
                DispatchQueue.main.async {
                    self.timeRecord = self.timeLabel.text ?? ""
                    if let navController = self.navigationController {
                        self.activityIndicatorView.stopAnimating()
                        self.activityIndicatorView.isHidden = true
                        navController.popViewController(animated: true)
                    }
                    self.onDismissCallback?(self)
                }
            } else {
            // We do not need to reset the audio file only stop the recorder
                DispatchQueue.main.async {
                    if let navController = self.navigationController {
                        self.activityIndicatorView.stopAnimating()
                        self.activityIndicatorView.isHidden = true
                        navController.popViewController(animated: true)
                    }
                    self.onDismissCallback?(self)
                }
            }
            
        }
    }
    
    @objc func saveAction(_ sender: UIButton) {
        cleanup()
        self.path = "\(ConfigurationManager.shared.guid)_\(row.tag ?? "0")_1_\(guid).ane"
        let data = FCFileManager.readFileAtPath(asData: "dummy.aac")
        let _ = ConfigurationManager.shared.utilities.saveAnexoToFolder(data! as NSData, self.path)
        FCFileManager.removeItem(atPath: "dummy.aac")
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        self.onDismissCallback?(self)
    }
    
    @objc func toggleRecord(_ sender: UIButton) {
        timeTimer?.invalidate()
        if recorder!.isRecording {
            
            recorder!.stop()
            
            self.stringURL = self.recorder!.url.absoluteString
            self.arrayPlayer.append(self.stringURL)
            
        } else {
            milliseconds = 0
            timeLabel.text = "00:00.00"
            
            timeTimer = Timer.scheduledTimer(timeInterval: 0.0174, target: self, selector: #selector(updateTimeLabel(timer:)), userInfo: nil, repeats: true)
            
            recorder!.deleteRecording()
            recorder!.isMeteringEnabled = true
            recorder!.record()
            
            audioVisualizationView.isHidden = false
            self.audioVisualizationView.isHidden = false
            self.audioVisualizationView.audioVisualizationMode = .write
            
            OperationQueue().addOperation({[weak self] in
                repeat {
                    self?.recorder!.updateMeters()
                    self?.averagePower = (self?.recorder!.averagePower(forChannel: 0))!
                    
                    
                    self?.performSelector(onMainThread: #selector(self?.updateVisualization), with: self, waitUntilDone: false)
                    Thread.sleep(forTimeInterval: 0.05)//20 FPS
                }
                while (self!.recorder!.isRecording)
            })
            
        }
        
        updateControls()
    }
    
    @objc private func updateVisualization() {
        let dB = Double(self.averagePower)
        let power = Float(exp(((dB))/20))
        
        self.audioVisualizationView.add(meteringLevel: power)
    }
    
    @objc func stopRecording(sender: AnyObject) {
        if recorder!.isRecording {
            toggleRecord(sender as! UIButton)
        }
    }
    
    func cleanup() {
        timeTimer?.invalidate()
        if recorder!.isRecording {
            recorder!.stop()
            
            recorder!.deleteRecording()
            
        }
        if let player = player {
            
            player.stop()
            self.player = nil
        }
    }
    
    func updateControls() {
        
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.recordButton.layer.cornerRadius = self.recordButton.frame.height/2
            self.recordButton.backgroundColor = self.recorder!.isRecording ? Cnstnt.Color.red2 : UIColor(hexFromString: self.atributos?.coloraudio ?? "#1E88E5")
            if self.recorder!.isRecording {
                self.audioVisualizationView.isHidden = false
                self.audioVisualizationView.reset()
                self.recordButton.setImage(UIImage(named: "ic_stopVid", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
                self.lblMessage.text = "Detener"
                self.isRecord = true
                self.recordButton.addTarget(self, action: #selector(self.closeAction(_:)), for: UIControl.Event.touchUpInside)
                
            } else {
                self.audioVisualizationView.stop()
                self.recordButton.setImage(UIImage(named: "ic_playVid", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
                self.lblMessage.text = "Iniciar"
            }
        }
        if let _ = player {
            recordButton.isEnabled = false
        } else {
            recordButton.isEnabled = true
        }
    }
    
    // MARK: Time Label
    @objc func updateTimeLabel(timer: Timer) {
        self.milliseconds += 1
        let milli = (milliseconds % 60) + 38
        let sec = (milliseconds / 60) % 60
        let min = milliseconds / 3600
        self.timeLabel.text = NSString(format: "%02d:%02d.%02d", min, sec, milli) as String
        self.timeString = NSString(format: "%02d:%02d.%02d", min, sec, milli) as String
        
    }
    
    // MARK: Playback Delegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
        updateControls()
    }
    
}
