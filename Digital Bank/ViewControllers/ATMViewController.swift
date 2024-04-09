import UIKit
import CoreLocation

class ATMViewController: UIViewController {

    @IBOutlet weak var GPSLocatior: UISwitch!
    @IBOutlet weak var IPLocator: UISwitch!
    @IBOutlet weak var ATMSearch: UISwitch!
  
    @IBOutlet weak var LocationOutputView: UIView!
    @IBOutlet weak var crash: UILabel!
    
   
    @IBOutlet weak var outputIPAddress: UILabel!
    // Location manager instance
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var outputLabel: UILabel!
    
    @IBOutlet weak var outputIcon: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
       
        // By default, GPS Locator is on
        GPSLocatior.isOn = true
        IPLocator.isOn = false
        ATMSearch.isOn = false
  

        LocationOutputView!.backgroundColor = UIColor.white
        LocationOutputView!.layer.cornerRadius = 25
        LocationOutputView!.layer.shadowColor = UIColor.black.cgColor
        LocationOutputView!.layer.shadowOpacity = 0.5
        LocationOutputView!.layer.shadowOffset = CGSize(width: 0, height: 2)
        LocationOutputView!.layer.shadowRadius = 4
 
        
        // Add actions for switch value changes
        GPSLocatior.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        IPLocator.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        ATMSearch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }

    
    
    @IBAction func LocationButton(_ sender: UIButton) {
        if GPSLocatior.isOn {
            print("GPS Clicked")
            outputLabel.text = "ATM Location - GPS"
            outputIcon.image = UIImage(systemName: "mappin.and.ellipse")

            // Request GPS location
               locationManager.requestLocation()
            
        } else if IPLocator.isOn {
           getIpAddress()
            outputLabel.text = "ATM Location - Network"
            outputIcon.image = UIImage(systemName: "scope")
            
        } else if ATMSearch.isOn {
            outputLabel.text = "ATM Location - Mock Service"
            outputIcon.image = UIImage(systemName: "magnifyingglass.circle.fill")?.withRenderingMode(.alwaysTemplate)

            showCustomRequestDialog()
            
        }
    }

   
    @objc func switchValueChanged(sender: UISwitch) {
        // If a switch is turned on, turn off the others
        if sender.isOn {
            if sender == GPSLocatior {
    
                DispatchQueue.main.async {
                    for subview in self.LocationOutputView.subviews {
                        subview.removeFromSuperview()
                    }
                }
                IPLocator.isOn = false
                ATMSearch.isOn = false
                self.outputIPAddress.text = " "
                outputLabel.text = ""
                outputIcon.image = UIImage(named: "scope")
                
            } else if sender == IPLocator {
      
                DispatchQueue.main.async {
                    for subview in self.LocationOutputView.subviews {
                        subview.removeFromSuperview()
                    }
                }
                GPSLocatior.isOn = false
                ATMSearch.isOn = false
                self.outputIPAddress.text = " "
                outputLabel.text = ""
                outputIcon.image = UIImage(named: "scope")
                
            } else if sender == ATMSearch {
  
                DispatchQueue.main.async {
                    for subview in self.LocationOutputView.subviews {
                        subview.removeFromSuperview()
                    }
                }
                GPSLocatior.isOn = false
                outputLabel.text = ""
                self.outputIPAddress.text = " "
                outputIcon.image = UIImage(named: "scope")
                IPLocator.isOn = false
            }
        }
    }

    @IBAction func Logout(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
  

    
    

    private func callAPI(with apiUrl: String) {
        guard let url = URL(string: apiUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("Error: \(error)")
                self.handleError(errorMessage: error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode),
                  let data = data else {
                self.handleError(errorMessage: "Invalid response or data")
                return
            }
            
            // Process API response directly here
            self.processGPSApiResponse(data: data)
        }.resume()
    }
    
    func handleNorthPoleLocation() {
        
        print("North Pole Selected")
        self.crash.text = ""
    }


    func updateLocationOutputView(formattedInfo: String) {
        // Create account summary view if it doesn't exist
        if LocationOutputView == nil {
            LocationOutputView = UIView()
            LocationOutputView!.backgroundColor = UIColor.white
            LocationOutputView!.layer.cornerRadius = 25
            LocationOutputView!.layer.shadowColor = UIColor.black.cgColor
            LocationOutputView!.layer.shadowOpacity = 0.5
            LocationOutputView!.layer.shadowOffset = CGSize(width: 0, height: 2)
            LocationOutputView!.layer.shadowRadius = 4

            // Add account summary view to the view hierarchy
            self.view.addSubview(LocationOutputView)
        } else {
            // Remove existing subviews (labels) from account summary view
            LocationOutputView!.subviews.forEach { $0.removeFromSuperview() }
        }

        // Create and configure label for formatted information
        let formattedInfoLabel = UILabel()
        formattedInfoLabel.textColor = UIColor.black
        formattedInfoLabel.font = UIFont.systemFont(ofSize: 14) // Adjust font size
        formattedInfoLabel.numberOfLines = 0
        formattedInfoLabel.text = formattedInfo // Use the provided formatted information

        // Add the formatted information label to the account summary view
        LocationOutputView!.addSubview(formattedInfoLabel)
        // Define padding values
        let topPadding: CGFloat = 20
        let horizontalPadding: CGFloat = 20

        // Calculate label width
        let labelWidth = LocationOutputView!.bounds.width - 2 * horizontalPadding

        // Calculate label size based on the width and maximum height
        let labelSize = formattedInfoLabel.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude))

        // Set the frame for the label with padding
        formattedInfoLabel.frame = CGRect(x: horizontalPadding, y: topPadding, width: labelWidth, height: labelSize.height)

        // Set text alignment to left
        formattedInfoLabel.textAlignment = .left

    }
    
    
    
    
    
    func processGPSApiResponse(data: Data) {
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

            let formattedInfo = "\n" +
                "    Road:      \(gpsroad) \n   " +
                "    State:     \(gpsstate)\n   " +
                "    Postcode:  \(gpspostcode)\n    " +
                "    Country:   \(gpscountry)\n    " +
            " \n"
          
            // Update UI on the main thread
            DispatchQueue.main.async {
      
                self.updateLocationOutputView(formattedInfo: formattedInfo)
            }

        } catch {
            self.handleError(errorMessage: error.localizedDescription)
        }
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
                    " \n \n "
                    "Road:       \(road) \n " +
                    "City:       \(city) \n " +
                    "County:     \(state) \n " +
                    "PostCode: \(postcode) \n " +
                    "Country:   \(country) \n "
                    """

  
                
                // Update UI to display formatted address
                DispatchQueue.main.async {
             
                    self.updateLocationOutputView(formattedInfo: formattedAddress)
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
                        
                            self.updateLocationOutputView(formattedInfo: formattedResponse)
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
        self.outputIPAddress.text = ipAddress
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

                // Process API response
                 self.processGPSApiResponse(data, country: country, postcode: postcode, state: state, lat: String(lat), lon: String(lon))
             }.resume()
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
                 //   self.LocationOutput.text = formattedInfo
                //    DispatchQueue.main.async {
                        self.updateLocationOutputView(formattedInfo:    formattedInfo)
                //    }
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
        // If location is updated successfully
        guard let location = locations.first else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Call API with the obtained coordinates
        let apiUrl = AppConst.MockUrl + "gps?type=atm&lat=\(latitude)&lon=\(longitude)"
        callAPI(with: apiUrl)
        
        // Check if the location corresponds to the North Pole
         if latitude > 89.9 || latitude < -89.9 {
             // Call your specific function here for the North Pole location
             handleNorthPoleLocation()
         }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle location error
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                print("Location error: Location unknown")
                self.handleError(errorMessage: "Unable to determine location. Please ensure that location services are enabled and try again.")
            default:
                print("Location error: \(clError.localizedDescription)")
                self.handleError(errorMessage: clError.localizedDescription)
            }
        } else {
            print("Location error: \(error.localizedDescription)")
            self.handleError(errorMessage: error.localizedDescription)
        }
    }

}

    



