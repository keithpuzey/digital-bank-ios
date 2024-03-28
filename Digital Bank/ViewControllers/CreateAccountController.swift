//
//  CreateAccountController.swift
//  Digital Bank App
//
//  Created by Keith Puzey on 21/08/21.
//
import UIKit
import Alamofire

class MyViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    let titlePickerValues = ["Mr.", "Mrs.", "Ms."]
    let genderPickerValues = ["M", "F"]
    
    var selectedTitle: String?
    var selectedGender: String?
    
    
    
    @IBOutlet weak var regTitlePicker: UIPickerView!
    
    @IBOutlet weak var regdob: UIDatePicker!
    
    
    @IBOutlet weak var regGenderPicker: UIPickerView!
   
    

    @IBOutlet weak var regFirstNameTextField: UITextField!
    @IBOutlet weak var regLastNameTextField: UITextField!
    @IBOutlet weak var regEmailAddressTextField: UITextField!
    @IBOutlet weak var regPasswordTextField: UITextField!
    @IBOutlet weak var regAddressTextField: UITextField!
    @IBOutlet weak var regRegionTextField: UITextField!
    @IBOutlet weak var regLocalityTextField: UITextField!
    @IBOutlet weak var regPostCodeTextField: UITextField!
    @IBOutlet weak var regPhoneNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        regTitlePicker.dataSource = self
        regTitlePicker.delegate = self
        regGenderPicker.dataSource = self
        regGenderPicker.delegate = self
    }

    
    // MARK: - IBActions
    
    @IBAction func regSubmitButtonTapped(_ sender: UIButton) {
        // Make your REST call using the form details
        if let title = selectedTitle, let gender = selectedGender {
            let firstName = regFirstNameTextField.text ?? ""
            let lastName = regLastNameTextField.text ?? ""
            let emailAddress = regEmailAddressTextField.text ?? ""
            let password = regPasswordTextField.text ?? ""
            let address = regAddressTextField.text ?? ""
            let region = regRegionTextField.text ?? ""
            let locality = regLocalityTextField.text ?? ""
            let postCode = regPostCodeTextField.text ?? ""
            let phoneNumber = regPhoneNumberTextField.text ?? ""
            
            // Make your REST call here, using form details
            print("Title: \(title), Gender: \(gender)")
            print("First Name: \(firstName), Last Name: \(lastName)")
            print("Email Address: \(emailAddress), Password: \(password)")
            print("Address: \(address), Region: \(region)")
            print("Locality: \(locality), Post Code: \(postCode)")
            print("Phone Number: \(phoneNumber)")
            
            // Reset form or perform any necessary actions after making the REST call
        } else {
            print("Please select title and gender.")
            // Display an alert or handle the case where title or gender is not selected
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Display one column in the picker
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == regTitlePicker {
            return titlePickerValues.count
        } else {
            return genderPickerValues.count
        }
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == regTitlePicker {
            return titlePickerValues[row] // Display each value in the title picker
        } else {
            return genderPickerValues[row] // Display each value in the gender picker
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == regTitlePicker {
            selectedTitle = titlePickerValues[row]
        } else {
            selectedGender = genderPickerValues[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let regTitlePicker = UILabel ()
        regTitlePicker.font = UIFont.systemFont(ofSize: 12)
        regTitlePicker.textAlignment = .center
        regTitlePicker.text = "Test"
        return regTitlePicker
    }
    }

