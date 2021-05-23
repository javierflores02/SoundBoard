import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var duracionTextField: UITextField!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    
    var counter = 0
    var timer = Timer()
    
    func configurarGrabacion() {
        do {
            // Creacion de sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)

            // Creacion de direccion para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!

            // Impresion de la ruta en la que se graban los archivos
            print("**")
            print(audioURL!)
            print("**")

            // Creacion opciones para el grabador de audio
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?

            // Creacion del objeto para grabacion de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()

        } catch let error as NSError {
            print(error)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }
    
    func segundosFormato (_ seconds : Int) -> (String, String, String) {
        let segundos:String = String(format: "%02d",seconds / 3600)
        let minutos:String = String(format: "%02d",(seconds % 3600) / 60)
        let horas:String = String(format: "%02d",(seconds % 3600) % 60)
      return (segundos, minutos, horas)
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            // Detener grabacion
            grabarAudio?.stop()
            
            // Cambiar texto del botòn grabar
            grabarButton.setTitle("Grabar", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            timer.invalidate() // just in case this button is tapped multiple times

            // start the timer
            
        } else {
            // Empezar a grabar
            grabarAudio?.record()
            counter = 0
            // Cambiar texto del botòn grabar a detener
            grabarButton.setTitle("Detener", for: .normal)
            reproducirButton.isEnabled = false
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        }catch {}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.duracion = duracionTextField.text
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }

    // called every time interval from the timer
    @objc func timerAction() {
        counter += 1
        let (h,m,s) = segundosFormato(counter)
        duracionTextField.text = "\(h):\(m):\(s)"
    }
}
