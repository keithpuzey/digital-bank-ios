import UIKit
import CoreLocation

class ATMViewController: UIViewController {

    @IBOutlet weak var GPSLocatior: UISwitch!
    @IBOutlet weak var IPLocator: UISwitch!
    @IBOutlet weak var ATMSearch: UISwitch!

    
    @IBOutlet weak var LocationOutput: UILabel!
    
    var isUpdatingLocation = false // Flag to track whether a location update is in progress

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
        // If location update is already in progress, return
        if isUpdatingLocation {
            return
        }
        
        // Set the flag to true to indicate that a location update is in progress
        isUpdatingLocation = true
        
        // Remove previous CLLocationManager delegate
        locationManager.delegate = nil
        
        // Request location updates
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }


    private func handleAtmLocationNetworkClick() {
        // Placeholder for handling network location click
    }

    private func handleSearchByZipCodeClick() {
        // Placeholder for handling search by zip code click
    }

    private func processgpsApiResponse(response: String) {
        guard let data = response.data(using: .utf8) else {
            handleError(errorMessage: "Invalid response data")
            return
        }
        
        do {
            // Parse JSON data
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            print("start processing2")
            print("JSON: \(json)")

            // Check if "address" key exists and is a dictionary
            guard let address = json?["address"] as? [String: Any] else {
                handleError(errorMessage: "Address not found or is not in the expected format")
                return
            }



            //Extract address components
            if let road = address["road"] as? String,
               let city = address["city"] as? String,
               let state = address["state"] as? String,
               let postcode = address["postcode"] as? String,
               let country = address["country"] as? String {
                DispatchQueue.main.async {
        
                }
                let formattedAddress = """
                    Road: \(road)
                    City: \(city)
                    County: \(state)
                    PostCode: \(postcode)
                    Country: \(country)
                    """

                
                      // Set the flag to true to indicate that a location update is in progress
                 isUpdatingLocation = false
                
                // Update UI to display formatted address
                DispatchQueue.main.async {
                    self.LocationOutput.text = formattedAddress
                }
            } else {
                handleError(errorMessage: "Address components not found")
            }
        } catch {
            handleError(errorMessage: "Error parsing JSON: \(error.localizedDescription)")
        }
    }



    private func processIpAddressResponse(response: String) {
        // Placeholder for processing IP address API response
    }

    private func showCustomRequestDialog() {
        // Placeholder for showing custom request dialog
    }

    private func performCustomRequest(userInput: String) {
        // Placeholder for performing custom request
    }

    private func handleError(errorMessage: String) {
        // Placeholder for handling errors
    }
}

// MARK: - CLLocationManagerDelegate

extension ATMViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Check if a location update is already in progress
        guard isUpdatingLocation, let location = locations.last else {
            return
        }

        // Process the location update
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let apiUrl =  AppConst.MockUrl + "gps?type=atm&lat=\(latitude)&lon=\(longitude)" // Replace with your actual API URL
        print("\(apiUrl)") // Log the API URL for debugging
        
        // Set the flag to false to prevent handling subsequent location updates
        isUpdatingLocation = false
        
        // Perform network request using URLSession
        URLSession.shared.dataTask(with: URL(string: apiUrl)!) { data, response, error in
            defer {
                // Reset the flag to indicate that location update is completed
                self.isUpdatingLocation = false
            }
            
            // Check for errors
            if let error = error {
                DispatchQueue.main.async {
                    self.handleError(errorMessage: error.localizedDescription)
                }
                return
            }

            // Check for valid response and data
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                DispatchQueue.main.async {
                    self.handleError(errorMessage: "Invalid response")
                }
                return
            }

            // Parse the response data
            do {
                let responseString = String(data: data, encoding: .utf8)
                print("\(responseString ?? "No response")") // Log the API response for debugging
                
                DispatchQueue.main.async {
                    
                    self.processgpsApiResponse(response: responseString ?? "")
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleError(errorMessage: error.localizedDescription)
                }
            }
        }.resume()

    }
}


