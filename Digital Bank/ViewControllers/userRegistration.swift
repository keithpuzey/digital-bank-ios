//
//  userRegistration.swift
//  Digital Bank
//
//  Created by Keith Puzey on 4/2/24.
//

import UIKit

class userRegistration: UIViewController {


    @IBOutlet weak var regFNameTextField: UITextField!
    @IBOutlet weak var regLNameTextField: UITextField!
    

    @IBOutlet weak var regEmailTextField: UITextField!
    
    @IBOutlet weak var regSSNTextField: UITextField!
    
 
    @IBOutlet weak var regAddressTextField: UITextField!
    
    @IBOutlet weak var regPasswordTextField: UITextField!
    
    @IBOutlet weak var  regRegionTextField: UITextField!
    
    @IBOutlet weak var regLocalTextField: UITextField!
    
    @IBOutlet weak var regPostalCodeTextField: UITextField!
    
    @IBOutlet weak var regPhoneNumber: UITextField!

    
    @IBOutlet weak var regMFSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var regDOBDatePicker: UIDatePicker!
 

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - IBActions
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        // Validate form before proceeding
        if isFormValid() {
            // Collect data from form fields
            let firstName = regFNameTextField.text ?? ""
            let lastName = regLNameTextField.text ?? ""
            let genderIndex = regMFSegmentedControl.selectedSegmentIndex
            let gender = regMFSegmentedControl.titleForSegment(at: genderIndex) ?? ""
            let dob = regDOBDatePicker.date
            let ssn = regSSNTextField.text ?? ""
            let email = regEmailTextField.text ?? ""
            let password = regPasswordTextField.text ?? ""
            let address = regAddressTextField.text ?? ""
            let locality = regLocalTextField.text ?? ""
            let postalCode = regPostalCodeTextField.text ?? ""

            // Call API with collected data
            callAPI(firstName: firstName, lastName: lastName, gender: gender, dob: dob, ssn: ssn, email: email, password: password, address: address, locality: locality, postalCode: postalCode)
        } else {
            // Display error message or handle invalid form
            print("Please fill in all fields and accept terms.")
        }
    }
    
    // MARK: - Form Validation
    
    func isFormValid() -> Bool {
        // Check if all fields are filled and terms are accepted
        return !(regFNameTextField.text?.isEmpty ?? true) &&
               !(regLNameTextField.text?.isEmpty ?? true) &&
               !(regSSNTextField.text?.isEmpty ?? true) &&
               !(regEmailTextField.text?.isEmpty ?? true) &&
               !(regPasswordTextField.text?.isEmpty ?? true) &&
               !(regAddressTextField.text?.isEmpty ?? true) &&
               !(regLocalTextField.text?.isEmpty ?? true) &&
               !(regPostalCodeTextField.text?.isEmpty ?? true) 
    }
    
    // MARK: - API Call
    
    func callAPI(firstName: String, lastName: String, gender: String, dob: Date, ssn: String, email: String, password: String, address: String, locality: String, postalCode: String) {
        // Perform your API call here using the collected data
        print("API Call:")
        print("First Name: \(firstName)")
        print("Last Name: \(lastName)")
        print("Gender: \(gender)")
        print("Date of Birth: \(dob)")
        print("SSN: \(ssn)")
        print("Email: \(email)")
        print("Password: \(password)")
        print("Address: \(address)")
        print("Locality: \(locality)")
        print("Postal Code: \(postalCode)")

    }
    
    // Switch value changed event
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        // Handle switch value change here
        if sender.isOn {
            print("Switch is ON")
        } else {
            print("Switch is OFF")
        }
    }}
