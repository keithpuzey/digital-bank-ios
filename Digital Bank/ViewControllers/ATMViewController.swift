import UIKit
import CoreLocation

class ATMViewController: UIViewController {

    @IBOutlet weak var GPSLocatior: UISwitch!
    @IBOutlet weak var IPLocator: UISwitch!
    @IBOutlet weak var ATMSearch: UISwitch!
    @IBOutlet weak var LocationOutput: UILabel!
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // By default, GPS Locator is on
        GPSLocatior.isOn = true
        IPLocator.isOn = false
        ATMSearch.isOn = false
        
        // Add actions for switch value changes
        GPSLocatior.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        IPLocator.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        ATMSearch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        // Initialize location manager
         locationManager.delegate = self
         locationManager.requestWhenInUseAuthorization()
        
    }
    @IBAction func LocationButton(_ sender: UIButton) {
        if GPSLocatior.isOn {
            handleAtmLocationGPSClick()
        } else if IPLocator.isOn {
            handleAtmLocationNetworkClick()
        } else if ATMSearch.isOn {
            handleSearchByZipCodeClick()
        }
    }
    
    @objc func switchValueChanged(sender: UISwitch) {
        // If a switch is turned on, turn off the others
        if sender.isOn {
            if sender == GPSLocatior {
                IPLocator.isOn = false
                ATMSearch.isOn = false
            } else if sender == IPLocator {
                GPSLocatior.isOn = false
                ATMSearch.isOn = false
            } else if sender == ATMSearch {
                GPSLocatior.isOn = false
                IPLocator.isOn = false
            }
        }
    }

    @IBAction func Logout(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
  
    
    private func handleAtmLocationGPSClick() {
        // Request location updates
        locationManager.startUpdatingLocation()
    }

    private func handleAtmLocationNetworkClick() {
    //    getIpAddress()
    }

    private func handleSearchByZipCodeClick() {
    //   showCustomRequestDialog()
    }

    private func getLocationAndMakeRequest() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // This line is necessary to prompt for permission
        locationManager.startUpdatingLocation()
    }

    private func processgpsApiResponse(response: String) {
        // Process GPS API response
        // Implement this method based on your requirements
    }

    private func processIpAddressResponse(response: String) {
        // Process IP address API response
        // Implement this method based on your requirements
    }

    private func showCustomRequestDialog() {
        // Show custom request dialog for zip code search
        // Implement this method based on your requirements
    }

    private func performCustomRequest(userInput: String) {
        // Perform custom request with user input (zip code)
        // Implement this method based on your requirements
    }

    private func handleError(errorMessage: String) {
        // Handle errors
        // Implement this method based on your requirements
    }
}

// MARK: - CLLocationManagerDelegate

extension ATMViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let apiUrl = AppConst.MockUrl + "gps?type=atm&lat=\(latitude)&lon=\(longitude)"

        // Perform network request on a separate thread
        DispatchQueue.global().async {
            if let url = URL(string: apiUrl) {
                do {
                    let data = try Data(contentsOf: url)
                    let responseString = String(data: data, encoding: .utf8)
                    DispatchQueue.main.async {
                        self.processgpsApiResponse(response: responseString ?? "")
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.handleError(errorMessage: error.localizedDescription)
                    }
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle location manager errors
        handleError(errorMessage: error.localizedDescription)
    }
}
