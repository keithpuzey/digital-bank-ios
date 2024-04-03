//
//  userRegistration.swift
//  Digital Bank
//
//  Created by Keith Puzey on 4/2/24.
//

import UIKit

class userRegistration: UIViewController {


 
    
//    @IBOutlet weak var regPhoneNumber: UITextField!


 

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBOutlet weak var regTitle: UISegmentedControl!
    
    @IBOutlet weak var regGender: UISegmentedControl!
    @IBOutlet weak var regFNameTextField: UITextField!
    
    @IBOutlet weak var regLNameTextField: UITextField!
    
    @IBOutlet weak var regEmailTextField: UITextField!
    
    @IBOutlet weak var regSSNTextField: UITextField!
    
    @IBOutlet weak var regPasswordTextField: UITextField!
    
    @IBOutlet weak var regAddressTextField: UITextField!
    
    @IBOutlet weak var regRegionTextField: UITextField!
    @IBOutlet weak var regLocalTextField: UITextField!
    
    @IBOutlet weak var regPostalCodeTextField: UITextField!
    
    
    @IBOutlet weak var regPhoneTextField: UITextField!
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
       // Validate form before proceeding
        if isFormValid() {
            // Collect data from form fields
            let titleIndex = regTitle.selectedSegmentIndex
            let title = regTitle.titleForSegment(at: titleIndex) ?? ""
            let genderIndex = regGender.selectedSegmentIndex
            let gender = regGender.titleForSegment(at: genderIndex) ?? ""
            
            let firstName = regFNameTextField.text ?? ""
            let lastName = regLNameTextField.text ?? ""
         //   let genderIndex = regMFSegmentedControl.selectedSegmentIndex
          //  let gender = regMFSegmentedControl.titleForSegment(at: genderIndex) ?? ""
          //  let dob = regDOBDatePicker.date
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
            callAPI(title: title, gender: gender, firstName: firstName, lastName: lastName, ssn: ssn, email: email, password: password, address: address, region: region, locality: locality, postalCode: postalCode, phone: phone)
        } else {
            // Display error message or handle invalid form
            print("Please fill in all fields and accept terms.")
        }
    }
    
    // MARK: - Form Validation
    
    func isFormValid() -> Bool {
        // Check if all fields are filled and terms are accepted
        print("Entering is valid funciton")
        return !(regFNameTextField.text?.isEmpty ?? true) &&
               !(regLNameTextField.text?.isEmpty ?? true) &&
               !(regSSNTextField.text?.isEmpty ?? true) &&
               !(regEmailTextField.text?.isEmpty ?? true) &&
               !(regPasswordTextField.text?.isEmpty ?? true) &&
               !(regAddressTextField.text?.isEmpty ?? true) &&
                !(regRegionTextField.text?.isEmpty ?? true) &&
                !(regLocalTextField.text?.isEmpty ?? true) &&
               !(regPostalCodeTextField.text?.isEmpty ?? true)
                    &&
                !(regPhoneTextField.text?.isEmpty ?? true)
        
    }

    // MARK: - API Call




    func callAPI(title: String, gender: String, firstName: String, lastName: String,   ssn: String, email: String, password: String, address: String, region: String, locality: String, postalCode: String, phone: String)
    {
        // Perform your API call here using the collected data
        print("API Call:")
        print("First Name: \(firstName)")
        print("Last Name: \(lastName)")
     //   print("Gender: \(gender)")
     //   print("Date of Birth: \(dob)")
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
    }
    

 }
