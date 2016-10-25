import CoreLocation
import UIKit
import LyftSDK

class ViewController: UIViewController {

    @IBOutlet weak var sampleLyftButton: LyftButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let pickup = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
        let destination = CLLocationCoordinate2D(latitude: 37.7794703, longitude: -122.4233223)

        self.sampleLyftButton.configure(pickup: pickup, destination: destination)
        self.sampleLyftButton.style = .hotPink
    }
}
