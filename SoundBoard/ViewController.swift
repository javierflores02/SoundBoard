import UIKit
import AVFoundation

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    
    @IBOutlet weak var volumenSlider: UISlider!
    @IBOutlet weak var tablaGrabaciones: UITableView!
    var grabaciones:[Grabacion] = []
    var reproducirAudio:AVAudioPlayer?
    var indiceReproduccion:IndexPath? = nil
    var estadoReproduccion:String = "inicio"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaGrabaciones.delegate = self
        tablaGrabaciones.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grabaciones.count
    }
    
    @IBAction func volumenChange(_ sender: Any) {
        getVolumen()
    }
    
    func getVolumen(){
        let selectedValue = Float(volumenSlider.value)
        reproducirAudio?.volume = selectedValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let grabacion = grabaciones[indexPath.row]
        cell.textLabel?.text = grabacion.nombre
        cell.imageView?.image = UIImage(named: "reproducir.png")
        cell.detailTextLabel?.text = "Duracion: \(grabacion.duracion ?? "No registrada")"
        return cell
    }

    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            grabaciones = try context.fetch(Grabacion.fetchRequest())
            tablaGrabaciones.reloadData()
        }catch{}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grabacion = grabaciones[indexPath.row]
        if(indiceReproduccion == nil){
            tableView.cellForRow(at: indexPath)!.imageView?.image = UIImage(named: "pausa.png")
            reproducirGrabacion(grabacion,indexPath)
            estadoReproduccion = "play"
        }else{
            if(indiceReproduccion == indexPath){
                if(estadoReproduccion == "play"){
                    reproducirAudio?.stop()
                    tablaGrabaciones.cellForRow(at: indexPath)!.imageView?.image = UIImage(named: "reproducir.png")
                    estadoReproduccion = "stop"
                }else{
                    reproducirAudio?.play()
                    tablaGrabaciones.cellForRow(at: indexPath)!.imageView?.image = UIImage(named: "pausa.png")
                    estadoReproduccion = "play"
                }
            }else{
                if(estadoReproduccion == "play"){
                    reproducirAudio?.stop()
                    tablaGrabaciones.cellForRow(at: indiceReproduccion!)!.imageView?.image = UIImage(named: "reproducir.png")
                }
                tablaGrabaciones.cellForRow(at: indexPath)!.imageView?.image = UIImage(named: "pausa.png")
                reproducirGrabacion(grabacion,indexPath)
                estadoReproduccion = "play"
            }
        }
        indiceReproduccion = indexPath
    }
    
    func reproducirGrabacion(_ grabacion:Grabacion,_ indexPath:IndexPath){
        do{
            reproducirAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
            getVolumen()
            reproducirAudio?.play()
            reproducirAudio?.delegate = self
            
        }catch{}
        tablaGrabaciones.deselectRow(at: indexPath, animated: true)
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        tablaGrabaciones.cellForRow(at: indiceReproduccion!)!.imageView?.image = UIImage(named: "reproducir.png")
        estadoReproduccion = "inicio"
        indiceReproduccion = nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let grabacion = grabaciones[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(grabacion)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do{
                grabaciones = try context.fetch(Grabacion.fetchRequest())
                tablaGrabaciones.reloadData()
            }catch{}
        }
    }
}

