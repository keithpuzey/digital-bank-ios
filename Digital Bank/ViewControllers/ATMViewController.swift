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

        // Request location authorization
        locationManager.requestWhenInUseAuthorization()

        // Set up CLLocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        // By default, GPS Locator is on
        GPSLocatior.isOn = true
        IPLocator.isOn = false
        ATMSearch.isOn = false
        
        // Add actions for switch value changes
        GPSLocatior.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        IPLocator.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        ATMSearch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }

    
    
    @IBAction func LocationButton(_ sender: UIButton) {
        if GPSLocatior.isOn {
            print("GPS Clicked")
            handleAtmLocationGPSClick()
        } else if IPLocator.isOn {
           getIpAddress()
        } else if ATMSearch.isOn {
            showCustomRequestDialog()
            
        }
    }


    
    @objc func switchValueChanged(sender: UISwitch) {
        // If a switch is turned on, turn off the others
        if sender.isOn {
            if sender == GPSLocatior {
                self.LocationOutput.text = " "
                IPLocator.isOn = false
                ATMSearch.isOn = false
            } else if sender == IPLocator {
                self.LocationOutput.text = " "
                GPSLocatior.isOn = false
                ATMSearch.isOn = false
            } else if sender == ATMSearch {
                self.LocationOutput.text = " "
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
        print("in the handle ATM click function")
        // Remove previous CLLocationManager delegate
        locationManager.delegate = nil
        
        // Request location updates
        locationManager.delegate = self
        print("in the handle ATM click function2")
        locationManager.startUpdatingLocation()
 
    }


    private func handleAtmLocationNetworkClick() {
        // Placeholder for handling network location click
    }

    private func handleSearchByZipCodeClick() {
        // Placeholder for handling search by zip code click
    }

    private func processgpsApiResponse2(response: String) {
        guard let data = response.data(using: .utf8) else {
            handleError(errorMessage: "Invalid response data")
            return
        }
        
        do {
            // Parse JSON data
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
         
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
            //     isUpdatingLocation = false
                
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


    private func handleError(errorMessage: String) {
        // Placeholder for handling errors
    }

    private func showCustomRequestDialog() {
        let alertController = UIAlertController(title: "Enter Zip Code", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Zip Code"
            textField.keyboardType = .numberPad
        }

        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
            guard let textField = alertController?.textFields?.first, let zipCode = textField.text else { return }
            self.performCustomRequest(zipCode)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func performCustomRequest(_ zipCode: String) {
        let apiUrl = AppConst.MockUrl + "zip?zipcode=" + zipCode

        guard let url = URL(string: apiUrl) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                if (400..<500).contains(statusCode) {
                    DispatchQueue.main.async {
                        let errorMessage = statusCode == 404 ? "Zip Code Not found" : "Service Unavailable"
                        let alertController = UIAlertController(title: "Mock Service Response Code", message: "\(errorMessage):\n\nResponse Code = \(statusCode)", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }

                } else if (200..<300).contains(statusCode), let data = data {
                    // Handle successful response
                    do {
                        guard let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                              let atms = responseJSON["atms"] as? [[String: Any]] else {
                            print("Invalid JSON format")
                            return
                        }
                        print("Number of ATM objects: \(atms.count)")
                        var formattedResponse = ""

                        for atm in atms {
                            if let atmLocation = atm["atmLocation"] as? [String: Any],
                               let address = atmLocation["address"] as? [String: Any],
                               let name = atmLocation["name"] as? String,
                               let locationDescription = atmLocation["locationDescription"] as? String,
                               let street = address["street"] as? String,
                               let city = address["city"] as? String,
                               let country = address["country"] as? String,
                               let postalCode = address["postalCode"] as? String {
                                
                                // Build formatted information for this ATM location
                                let zipFormattedInfo =
                                    "ATM Location: " + "\n" +
                                    "Name:             " + name + "\n" +
                                    "Description:   " + locationDescription + "\n" +
                                    "Street :             " + street + "\n" +
                                    "City:                  " + city + "\n" +
                                    "Country:          " + country + "\n" +
                                    "Zip Code:        " + postalCode + "\n\n"

                                // Append the formatted information to the formattedResponse variable
                                formattedResponse += zipFormattedInfo
                            }
                        }

                        // Use the formatted response as needed, such as displaying in UI or logging
                        print("Formatted Response: \(formattedResponse)")
                        DispatchQueue.main.async {
                            self.LocationOutput.text = formattedResponse
                        }
                        
                        
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
        }.resume()
    }
    
func getIpAddress() {
            // URL for the IP address API
            let ipApiUrl = "https://api.seeip.org/jsonip"

            // Perform network request on a separate thread
            DispatchQueue.global().async {
                if let url = URL(string: ipApiUrl) {
                    do {
                        let data = try Data(contentsOf: url)
                        let ipAddress = try JSONDecoder().decode(IpAddress.self, from: data).ip

                        // Call the function to get details for IP address
                    
                        print("IP Address: \(ipAddress)")
                        
                        self.getDetailsForIpAddress(ipAddress)
                    } catch {
                        self.handleError(errorMessage: error.localizedDescription)
                    }
                } else {
                    self.handleError(errorMessage: "Invalid URL")
                }
            }
        }

    func getDetailsForIpAddress(_ ipAddress: String) {
        // URL for the second API
        let secondApiUrl = AppConst.MockUrl + "ip?ip=" + ipAddress
        print("Second API URL: \(secondApiUrl)")
        // Update UI on the main thread
        DispatchQueue.main.async {
            self.LocationOutput.text = ipAddress
        }
        
        // Perform the second network request on a background thread
        DispatchQueue.global().async {
            guard let url = URL(string: secondApiUrl) else {
                self.handleError(errorMessage: "Invalid URL")
                return
            }

            do {
                let data = try Data(contentsOf: url)
                print("Second API Response: \(String(data: data, encoding: .utf8) ?? "")")
                self.processSecondApiResponse(data)

            } catch {
                print("Error fetching data from second API: \(error.localizedDescription)")
                self.handleError(errorMessage: error.localizedDescription)
            }
        }
    }

    func processSecondApiResponse(_ data: Data) {
        do {
            guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                self.handleError(errorMessage: "Error parsing second API response")
                return
            }

            guard let country = jsonResponse["country"] as? String,
                  let postcode = jsonResponse["zip"] as? String,
                  let state = jsonResponse["region"] as? String,
                  let lat = jsonResponse["lat"] as? Double, // Change to Double
                  let lon = jsonResponse["lon"] as? Double else { // Change to Double
                self.handleError(errorMessage: "Error extracting relevant information from second API response")
                return
            }

            // Third request to another API using the latitude and longitude

            let gpsApiUrl = AppConst.MockUrl + "gps?type=atm&lat=" + String(lat) + "&lon=" + String(lon)
            print("\(gpsApiUrl)")
            guard let gpsUrl = URL(string: gpsApiUrl) else {
                self.handleError(errorMessage: "Invalid GPS API URL")
                return
            }

            // Create a URLSession instance
            let session = URLSession.shared

            // Create a data task with the GPS URL
            let task = session.dataTask(with: gpsUrl) { (data, response, error) in
                // Check for errors
                if let error = error {
                    self.handleError(errorMessage: error.localizedDescription)
                    return
                }

                // Check for response and data
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data else {
                    self.handleError(errorMessage: "Invalid response or data")
                    return
                }

                // Process the GPS API response with the extracted information
                self.processGPSApiResponse(data, country: country, postcode: postcode, state: state, lat: String(lat), lon: String(lon))
            }

            // Start the data task
            task.resume()
        } catch {
            self.handleError(errorMessage: error.localizedDescription)
        }
    }

    func processGPSApiResponse(_ data: Data, country: String, postcode: String, state: String, lat: String, lon: String) {
        do {
            guard let gpsJsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let gpsaddressObject = gpsJsonResponse["address"] as? [String: Any],
                  let gpscountry = gpsaddressObject["country"] as? String,
                  let gpspostcode = gpsaddressObject["postcode"] as? String,
                  let gpsstate = gpsaddressObject["state"] as? String,
                  let gpsroad = gpsaddressObject["road"] as? String else {
                self.handleError(errorMessage: "Error parsing GPS response")
                return
            }

                let formattedInfo =
                    "Road:      \(gpsroad) \n" +
                    "State:     \(gpsstate)\n" +
                    "Postcode:  \(gpspostcode)\n" +
                    "Country:   \(gpscountry)\n"
                  

                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.LocationOutput.text = formattedInfo
                }

        } catch
        {
            self.handleError(errorMessage: error.localizedDescription)
        }
    }


    }

    // Model for decoding JSON response
    struct IpAddress: Decodable {
        let ip: String
    }
    


// MARK: - CLLocationManagerDelegate

extension ATMViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
  
        // Check if a location update is already in progress
        print("Received locations: \(locations)")
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
            //    self.isUpdatingLocation = false
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
                

            } catch {
                DispatchQueue.main.async {
                    self.handleError(errorMessage: error.localizedDescription)
                }
            }
        }.resume()

    }
    
}


