import CoreLocation
import LyftSDK
import os.log
import UIKit

private let kPresetPosition = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)

class RideTypesViewController: UITableViewController {
    private var rideTypes: [RideType]?
    private var ETAs: [ETA]?
    private var position: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.requestLocation()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rideTypes?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RideTypeCell.reuseIdentifier, for: indexPath)
        guard let rideTypeCell = cell as? RideTypeCell, let rideType = self.rideType(for: indexPath) else {
            return UITableViewCell()
        }

        let eta = self.ETAs?.first { $0.rideKind == rideType.kind }
        rideTypeCell.updateWith(
            iconURL: rideType.imageURL.flatMap { URL(string: $0) },
            title: rideType.displayName,
            seatsText: "Seats \(rideType.numberOfSeats)",
            etaText: eta.map { "\($0.minutes) min" })

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let rideType = self.rideType(for: indexPath) {
            LyftDeepLink.requestRide(kind: rideType.kind, from: self.position)
        }
    }

    private func rideType(for indexPath: IndexPath) -> RideType? {
        if let rideTypes = self.rideTypes, rideTypes.count > indexPath.row {
            return rideTypes[indexPath.row]
        } else {
            return nil
        }
    }

    fileprivate func requestLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.requestLocation()

        case .denied, .restricted:
            let message = "Go to settings to change access and find ride types in your area"
            let controller = UIAlertController(title: "Location access restricted",
                                               message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Use pre-set location", style: .default) { [weak self] _ in
                self?.requestRideTypes(with: kPresetPosition)
            }

            controller.addAction(action)
            self.present(controller, animated: true, completion: nil)

        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        @unknown default:
            if #available(iOS 10.0, *) {
                os_log("Switch is not exhaustive, please add missing cases.")
            } else {
                NSLog("Switch is not exhaustive, please add missing cases.")
            }
        }
    }

    fileprivate func requestRideTypes(with position: CLLocationCoordinate2D) {
        self.position = position
        LyftAPI.rideTypes(at: position) { [weak self] result in
            self?.rideTypes = result.value
            self?.tableView.reloadData()

            if let error = result.error {
                let controller = UIAlertController(title: "Error fetching ride types", message: error.message,
                                                   preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(controller, animated: true, completion: nil)
            }
        }

        LyftAPI.ETAs(to: position) { [weak self] result in
            self?.ETAs = result.value
            self?.tableView.reloadData()
        }
    }
}

class RideTypeCell: UITableViewCell {
    static var reuseIdentifier = "ride_type"

    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var seatsLabel: UILabel!
    @IBOutlet private var etaLabel: UILabel!

    func updateWith(iconURL: URL?, title: String, seatsText: String, etaText: String?) {
        self.iconImageView.image = nil
        self.iconImageView.loadImage(from: iconURL)
        self.titleLabel.text = title
        self.seatsLabel.text = seatsText
        self.etaLabel.text = etaText
    }
}

extension RideTypesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.requestRideTypes(with: location.coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let controller = UIAlertController(title: "Error fetching location", message: nil,
                                           preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
}

private extension UIImageView {
    func loadImage(from url: URL?) {
        guard let url = url else {
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            let image = data.flatMap { UIImage(data: $0) }
            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}
