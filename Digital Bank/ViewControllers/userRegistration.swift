//
//  userRegistration.swift
//  Digital Bank
//
//  Created by Keith Puzey on 4/2/24.
//

import UIKit

class userRegistration: UIViewController {


    override func viewDidLoad() {
        
        // Enable secure text entry for password field
        regPasswordTextField.isSecureTextEntry = true
        // Set the date picker mode to date only
        regDobPicker.datePickerMode = .date
        
        // Set locale to enforce MM/DD/YYYY format
        regDobPicker.locale = Locale(identifier: "en_US_POSIX")
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }


    @IBOutlet weak var regTitle: UISegmentedControl!
    
    @IBOutlet weak var regGender: UISegmentedControl!
    @IBOutlet weak var regFNameTextField: UITextField!
    
    @IBOutlet weak var regLNameTextField: UITextField!
    
    @IBOutlet weak var regDobPicker: UIDatePicker!
    @IBOutlet weak var regEmailTextField: UITextField!
    
    @IBOutlet weak var regSSNTextField: UITextField!
    
    @IBOutlet weak var regPasswordTextField: UITextField!
    
    @IBOutlet weak var regAddressTextField: UITextField!
    
    @IBOutlet weak var regRegionTextField: UITextField!
    @IBOutlet weak var regLocalTextField: UITextField!
    
    @IBOutlet weak var regPostalCodeTextField: UITextField!
    
    
    @IBOutlet weak var regPhoneTextField: UITextField!
    
    @IBOutlet weak var regAccept: UISwitch!
    
    
    @IBAction func signUpButtonTapped(_ sender: Any) {

        // Check if the license agreement is accepted
        guard isLicenseAgreementAccepted() else {
            print("Please accept the license agreement.")
            showAlert(title: "Error", message: "Please Accept the License Agreement")
            return
        }

        // Validate form before proceeding
        let validationResult = isFormValid()
        if validationResult.isValid {
            // Collect data from form fields
            let titleIndex = regTitle.selectedSegmentIndex
            let title = regTitle.titleForSegment(at: titleIndex) ?? ""
            let genderIndex = regGender.selectedSegmentIndex
            let gender = regGender.titleForSegment(at: genderIndex) ?? ""
            
            let firstName = regFNameTextField.text ?? ""
            let lastName = regLNameTextField.text ?? ""

            let dob = regDobPicker.date // Get selected date from date picker
            // Format the date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let formattedDOB = dateFormatter.string(from: dob)
            print("Date of Birth: \(formattedDOB)")
            let ssn = regSSNTextField.text ?? ""
            let email = regEmailTextField.text ?? ""
            let password = regPasswordTextField.text ?? ""
            let address = regAddressTextField.text ?? ""
            let region = regRegionTextField.text ?? ""
            let locality = regLocalTextField.text ?? ""
            let postalCode = regPostalCodeTextField.text ?? ""
            let phone = regPhoneTextField.text ?? ""
            
            print("Form is valid")
            
            // Call API with collected data
            callAPI(title: title, gender: gender, firstName: firstName, lastName: lastName, ssn: ssn, email: email, password: password, address: address, region: region, locality: locality, postalCode: postalCode, phone: phone, formattedDOB: formattedDOB )
        } else {
            // Display error message or handle invalid form
            let validationResult = isFormValid()
            showAlert(title: "Form Validation Error", message: "\(validationResult.errorMessage)")
                      
            print("Form is invalid: \(validationResult.errorMessage)")
        }

    }
    
    // MARK: - Form Validation
    
    func isFormValid() -> (isValid: Bool, errorMessage: String) {
          // Check if all fields are filled and terms are accepted
           
          // Check each field for validity
          if regFNameTextField.text?.isEmpty ?? true {
              return (false, "First Name is required")
          }
          if regLNameTextField.text?.isEmpty ?? true {
              return (false, "Last Name is required")
          }
          if regSSNTextField.text?.count != 9 {
              return (false, "SSN must be 9 digits long")
          }
        // Validate email format
        if let email = regEmailTextField.text, !isValidEmail(email) {
            return (false, "Invalid email format")
        }
        if (regPasswordTextField.text?.count ?? 0) < 8 {
            return (false, "Password must be at leat 8 characters and contain at least one uppercase, one lowercase and one special character")
        }
        if !containsUppercaseLowercaseAndSpecialCharacter(regPasswordTextField.text ?? "") {
            return (false, "Password must be at leat 8 characters and contain at least one uppercase, one lowercase and one special character")
        }
        if regAddressTextField.text?.isEmpty ?? true  {
            return (false, "Address is Required")
        }
        if regRegionTextField.text?.isEmpty ?? true  {
            return (false, "Region is Required")
        }
        if regLocalTextField.text?.isEmpty ?? true  {
            return (false, "Locality is Required")
        }
        
        if regPostalCodeTextField.text?.isEmpty ?? true {
            return (false, "Zip code  is required")
        }
        if regPhoneTextField.text?.isEmpty ?? true {
            return (false, "Phone Number is required")
        }
        if let postalCode = regPostalCodeTextField.text, !isNumeric(postalCode) {
            return (false, "Postal code must contain only numbers")
        }
        if let phone = regPhoneTextField.text, !isNumeric(phone) {
            return (false, "Phone number must contain only numbers")
        }
          
          // If all checks pass, return true
          return (true, "")
      }
  
    func containsUppercaseLowercaseAndSpecialCharacter(_ password: String) -> Bool {
        let uppercaseLetterRegEx = ".*[A-Z]+.*"
        let lowercaseLetterRegEx = ".*[a-z]+.*"
        let specialCharacterRegEx = ".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]+.*"
        let passwordLength = password.count

        guard passwordLength >= 8 else {
            return false // Password length must be at least 8 characters
        }

        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegEx)
        let lowercasePredicate = NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegEx)
        let specialCharacterPredicate = NSPredicate(format: "SELF MATCHES %@", specialCharacterRegEx)

        return passwordPredicate.evaluate(with: password) &&
               lowercasePredicate.evaluate(with: password) &&
               specialCharacterPredicate.evaluate(with: password)
    }




    func isNumeric(_ input: String) -> Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: input))
    }
    
        func isValidEmail(_ email: String) -> Bool {
            // Regular expression pattern for email validation
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

            // Create a regular expression object
            guard let regex = try? NSRegularExpression(pattern: emailRegex) else {
                return false
            }

            // Match the regular expression pattern against the email string
            let matches = regex.matches(in: email, range: NSRange(location: 0, length: email.utf16.count))
            return !matches.isEmpty
        }
    
    
    func isLicenseAgreementAccepted() -> Bool {
        // Check if the license agreement switch is turned on
        return regAccept.isOn
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - API Call




    func callAPI(title: String, gender: String, firstName: String, lastName: String,   ssn: String, email: String, password: String, address: String, region: String, locality: String, postalCode: String, phone: String, formattedDOB: String )
    {
        // Perform your API call here using the collected data
        print("API Call:")
        print("First Name: \(firstName)")
        print("Last Name: \(lastName)")

        print("SSN: \(ssn)")
        print("Email: \(email)")
        print("Password: \(password)")
        print("Address: \(address)")
        print("Region: \(region)")
        print("Locality: \(locality)")
        print("Postal Code: \(postalCode)")
        print("Phone: \(phone)")
        print("Title: \(title)")
        print("Gender: \(gender)")
        print("Date of Birth: \(formattedDOB)")    }
    

 }
