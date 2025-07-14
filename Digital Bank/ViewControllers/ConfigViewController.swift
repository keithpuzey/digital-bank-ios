import UIKit
import StoreKit

class ConfigViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var BaseURLConfig: UITextField!
    @IBOutlet weak var MockURLConfig: UITextField!
    
    var baseurl: String = ""
    var MockUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        baseurl = AppConst.baseurl
        MockUrl = AppConst.MockUrl
        BaseURLConfig.text = baseurl
        MockURLConfig.text = MockUrl
        
        // Set the delegate for text fields
        BaseURLConfig.delegate = self
        MockURLConfig.delegate = self
    }
    
    // Dismiss the keyboard when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Dismiss the keyboard when the screen is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func ConfigApply(_ sender: UIButton) {
        if let baseURLText = BaseURLConfig.text {
            baseurl = baseURLText
        }
        if let MockURLConfigText = MockURLConfig.text {
            MockUrl = MockURLConfigText
        }
        
        // Update the values in the constant struct manually
        AppConst.baseurl = baseurl
        AppConst.MockUrl = MockUrl
        
        // Update the text fields with the new values
        BaseURLConfig.text = AppConst.baseurl
        MockURLConfig.text = AppConst.MockUrl
        
        print(BaseURLConfig!)
    }
}
