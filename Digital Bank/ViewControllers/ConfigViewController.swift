import UIKit

class ConfigViewController: UIViewController {

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
