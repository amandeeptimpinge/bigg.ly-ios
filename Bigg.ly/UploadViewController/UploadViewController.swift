//
//  UploadViewController.swift
//  Bigg.ly
//
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import IQKeyboardManagerSwift
import Alamofire
import Toast_Swift
import Foundation
import UserNotifications
import KDCircularProgress
#if canImport(FoundationNetworking)
import FoundationNetworking
import KDCircularProgress
import SystemConfiguration
#endif
class UploadViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var bigExpandBTN: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var uploadBTN: UIButton!
    @IBOutlet weak var emailToTF: UITextField!
    @IBOutlet weak var yourEmailTF: UITextField!
    @IBOutlet weak var msgTxtView: UITextView!
    @IBOutlet weak var ListView: UIView!


    @IBOutlet weak var sideMenuBTN: UIButton!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var sendBTN: UIButton!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var msgInput: UIImageView!
    @IBOutlet weak var expandBTN: UIButton!
    @IBOutlet weak var filesTblView: UITableView!
    @IBOutlet weak var listViewHeight: NSLayoutConstraint!
    @IBOutlet weak var listViewWidth: NSLayoutConstraint!
    @IBOutlet weak var listViewX: NSLayoutConstraint!
    @IBOutlet weak var listViewY: NSLayoutConstraint!
    @IBOutlet weak var bigListView: UIView!
    @IBOutlet weak var bigListTblView: UITableView!
    private let taskIdentifier = "com.impingesolutions.Bigg-ly.upload"
    @IBOutlet weak var progressView: UIProgressView!
    var fileEXtension: String = ""
    var uploadItemsArr = [Any]()
    var urlArr = [String]()
    lazy var arrayNames = [String]()
    var imageData = Data()
    var initialFrames = CGRect()
    var semaphore = DispatchSemaphore (value: 0)
    var parameters: [[String : Any]] = []
    let boundary = "Boundary-\(UUID().uuidString)"
    var body = ""
    var error: Error? = nil
    var msg = ""
    var isViewExpaned = false
    var dataAdded = false
    var mimeType = ""
    var checked = false
    var arrayProgress = [KDCircularProgress]()
    @IBOutlet weak var successImages: UIImageView!
    @IBOutlet weak var btnDone: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        emailToTF.attributedPlaceholder = NSAttributedString(
            string: "Email To",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        yourEmailTF.attributedPlaceholder = NSAttributedString(
            string: "Email From",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        msgTxtView.text = "Message"
        msgTxtView.textColor = UIColor.white
        
        self.urlArr.removeAll()
        self.sendBTN.layer.cornerRadius = 20
        self.msgInput.layer.cornerRadius = 10
        self.yourEmailTF.layer.cornerRadius = 20
        self.emailToTF.layer.cornerRadius = 20
        self.filesTblView.delegate = self
        self.bigListTblView.delegate = self
        self.filesTblView.dataSource = self
        self.bigListTblView.dataSource = self
        self.ListView.layer.cornerRadius = 15
        self.filesTblView.layer.cornerRadius = 15
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
               if let error = error {
                   print("Error: ", error)
               }
        }
    }
    
    override func viewDidLayoutSubviews() {
        initialFrames = self.ListView.frame
        
    }
    
    func uploadTaskBegin(){
        for param in parameters {
            if param["disabled"] == nil {
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                if param["contentType"] != nil {
                    body += "\r\nContent-Type: \(param["contentType"] as! String)"
                }
                let paramType = param["type"] as! String
                if paramType == "text" {
                    let paramValue = param["value"] as! String
                    body += "\r\n\r\n\(paramValue)\r\n"
                } else {
                    let paramSrc = param["src"] as! String
                    let fileData = (try? NSData(contentsOfFile:paramSrc, options:[]) as Data)!
                    let fileContent = String(data: fileData, encoding: .utf8)!
                    body += "; filename=\"\(paramSrc)\"\r\n"
                        + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
                }
            }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "https://bigg.ly/transfer")!,timeoutInterval: Double.infinity)
        request.addValue("PHPSESSID=imqk0i3f22l3c28plogc1uunq0; XSRF-TOKEN=eyJpdiI6InNRSkpxYUluRjFKUk1mYUJ5MXJaVEE9PSIsInZhbHVlIjoieElOa1JjTXBMY0NmejhOS2VoMkRod1AwaUJVcmxHb1QrZUlDRVF4WXFSN3hPRUwwYlBLcS9LVmdsR0IySXJzVjF3S0JVc0c3R1lORE9uQm1xN3V6TmU4T1h2Q3I3MThrSEdHdGJiZmgramNEMzExRTluTGlYWjc1Zy9yQ2JiL0UiLCJtYWMiOiIwMjRjYTVlOTIzZGFmYTU4NTNlNzJiYWE5ZDNmMzUwNmY1ZTQ4OWRlNjQyNGI0MDY5NDdhZGQ5MDg3MjkyYTdhIiwidGFnIjoiIn0%3D; biggly_session=eyJpdiI6IldWa2hnTEh3OVFsTThHVjRxODEvUEE9PSIsInZhbHVlIjoiaW0wZHVGclF4R3VHTURiaExOSmczSlFPS0dXRUh4djkrcmo1RWJ2ZFpmYjd0OFZURExPcXd1ZXU5SUpZVTlaY2d5R1N1bHRJWFhPQk85T2xFTXNtckRGdzhtL0ZzcnFIOWQyZ2pML3hadEJyeGhXODJqc3V3a2kyOTNieitVTjQiLCJtYWMiOiJmMWIyN2Q3NThmMjdlMTJkYWRmZDUxNjZkZmJlMzkyMTQxZmM3NTUxMzUyNTQ3YmE2MGI4OGE3Mzk4Y2VkYjcwIiwidGFnIjoiIn0%3D", forHTTPHeaderField: "Cookie")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                self.semaphore.signal()
                return
            }
            print(String(data: data, encoding: .utf8)!)
            self.semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
    
    @IBAction func uploadBTNTapped(_ sender: UIButton) {
        let types = [kUTTypePDF, kUTTypeText, kUTTypeSpreadsheet,kUTTypeData,kUTTypeJPEG]
        let importMenu = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        importMenu.allowsMultipleSelection = true
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        present(importMenu, animated: false )
    }
    
    
    //MARK:- Validations
    @IBAction func sendBTNTapped(_ sender: Any) {
        print(parameters)
        print(urlArr)
        if emailToTF.text == "" {
            showAlert(with: "Please enter email_to field")
        }else if yourEmailTF.text == "" {
            showAlert(with: "Please enter email_from field")
        }else if urlArr.count == 0 {
            self.showAlert(with: "Please select file to upload")
        }else if !checked {
            showAlert(with: "Please accept the term and conditions")
        } else {
            guard Connectivity.isConnectedInternet()  else {
                    self.showAlert(with: "Please connect to internet")
                    return
           }
            self.uploadPhoto()
        }
        
//            let error = validateFields()
//                if error != nil {
//                    showAlert(with: "Please enter valid email address")
//                } else {
//
//            if  !checked{
//                showAlert(with: "Please accept the term and conditions")
//            } else {
//            //        if self.urlArr != nil{
//            guard urlArr.count > 0 else
//            {
//                self.showAlert(with: "Please select file to upload")
//                return
//            }
//
//            guard Connectivity.isConnectedInternet()  else {
//                    self.showAlert(with: "Please connect to internet")
//                    return
//            }
//
//            self.uploadPhoto()
//        }
//        }
    }
    
    var backgroundTaskID: UIBackgroundTaskIdentifier?
    func sendDataToServer() {
       // Perform the task on a background queue.
       DispatchQueue.global().async {
          // Request the task assertion and save the ID.
          self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Finish Network Tasks") {
             // End the task if time expires.
             UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
              self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
          }
          // Send the data synchronously.
           self.uploadPhoto()
          // End the task assertion.
          UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
           self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
       }
    }
    
    @IBAction func chckboxtapped(_ sender: UIButton) {
        if checked {
            sender.setImage( UIImage(named:"unchecked.png"), for: .normal)
            checked = false
        } else {
            sender.setImage(UIImage(named:"checked.png"), for: .normal)
            checked = true
        }
    }
    
    func hideTools(){
        self.isViewExpaned = true
        self.mainView.isHidden = true
        self.ListView.isHidden = true
        self.bigListView.isHidden = false
        self.bigListTblView.isHidden = false
        self.uploadBTN.isHidden = true
        self.bigExpandBTN.isHidden = false
        self.expandBTN.isHidden = true
        self.bigListTblView.reloadData()
    }
    
    @IBAction func expandBTNTapped(_ sender: Any) {
        if isViewExpaned == false{
            UIView.animate(withDuration: 5) {
                self.hideTools()
            }
        }else{
            UIView.animate(withDuration: 5) {
                self.isViewExpaned = false
                self.mainView.isHidden = false
                if self.dataAdded == true{
                    self.ListView.isHidden = false
                }else{
                    self.ListView.isHidden = true
                }
                self.bigListView.isHidden = false
                self.uploadBTN.isHidden = false
                self.bigExpandBTN.isHidden = true
                self.expandBTN.isHidden = false
            }
            self.filesTblView.reloadData()
            self.bigListTblView.reloadData()
        }
    }
    
    @IBAction func Done(_ sender: Any) {
        successImages.isHidden = true
        btnDone.isHidden = true
        emailToTF.text = ""
        yourEmailTF.text = ""
        msgTxtView.text = "message"
        ListView.isHidden = true
        checkBox.setImage(UIImage(named:"unchecked.png"), for: .normal)
        checked = false
        arrayNames.removeAll()
        urlArr.removeAll()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        return
    }
    
    func uploadFiles(_ urlPath: [URL]){
    if let url = URL(string: "https://bigg.ly/transfer"){
    var request = URLRequest(url: url)
    let boundary:String = "Boundary-\(UUID().uuidString)"
        
    request.httpMethod = "POST"
    request.timeoutInterval = 10
    request.allHTTPHeaderFields = ["Content-Type": "multipart/form-data; boundary=----\(boundary)"]
    request.addValue("PHPSESSID=imqk0i3f22l3c28plogc1uunq0; XSRF-TOKEN=eyJpdiI6InNRSkpxYUluRjFKUk1mYUJ5MXJaVEE9PSIsInZhbHVlIjoieElOa1JjTXBMY0NmejhOS2VoMkRod1AwaUJVcmxHb1QrZUlDRVF4WXFSN3hPRUwwYlBLcS9LVmdsR0IySXJzVjF3S0JVc0c3R1lORE9uQm1xN3V6TmU4T1h2Q3I3MThrSEdHdGJiZmgramNEMzExRTluTGlYWjc1Zy9yQ2JiL0UiLCJtYWMiOiIwMjRjYTVlOTIzZGFmYTU4NTNlNzJiYWE5ZDNmMzUwNmY1ZTQ4OWRlNjQyNGI0MDY5NDdhZGQ5MDg3MjkyYTdhIiwidGFnIjoiIn0%3D; biggly_session=eyJpdiI6IldWa2hnTEh3OVFsTThHVjRxODEvUEE9PSIsInZhbHVlIjoiaW0wZHVGclF4R3VHTURiaExOSmczSlFPS0dXRUh4djkrcmo1RWJ2ZFpmYjd0OFZURExPcXd1ZXU5SUpZVTlaY2d5R1N1bHRJWFhPQk85T2xFTXNtckRGdzhtL0ZzcnFIOWQyZ2pML3hadEJyeGhXODJqc3V3a2kyOTNieitVTjQiLCJtYWMiOiJmMWIyN2Q3NThmMjdlMTJkYWRmZDUxNjZkZmJlMzkyMTQxZmM3NTUxMzUyNTQ3YmE2MGI4OGE3Mzk4Y2VkYjcwIiwidGFnIjoiIn0%3D", forHTTPHeaderField: "Cookie")
        for path in urlPath{
            do{
                var data2: Data = Data()
                var data: Data = Data()
                data2 = try NSData.init(contentsOf: URL.init(fileURLWithPath: path.path, isDirectory: true)) as Data
                 let dic:[String:Any] = [
                 "email_to":"navdeepr.impinge@gmail.com",
                 "email_from":"lsfl@glal.com",
                 "message":"Loves to move",
                 "uploadagreeterms": true,
                 "backup": false,
                 "file":"defname"
                ]
                
                for (key,value) in dic{
                    data.append("------\(boundary)\r\n")
                    data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    data.append("\(value)\r\n")
                }
                
                data.append("------\(boundary)\r\n")
                //Here you have to change the Content-Type
                data.append("Content-Disposition: form-data; name=\"file1\"; filename=\"YourFileName\"\r\n")
                data.append("Content-Type: application/\(urlPath.first!.mimeType())")
                data.append(data2)
                data.append("\r\n")
                data.append("------\(boundary)--")
                request.httpBody = data
            }catch let e{
                //Your errors
            }
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).sync {
                let session = URLSession.shared
                let task = session.dataTask(with: request, completionHandler: { (dataS, aResponse, error) in
                    if let erros = error{
                        print(erros)
                    }else{
                        do{
                            let responseObj = try JSONSerialization.jsonObject(with: dataS!, options: JSONSerialization.ReadingOptions(rawValue:0)) as! [String:Any]
                            print(responseObj)
                            
                        }catch let e{
                            
                        }
                    }
                }).resume()
                }
            }
        }
    }
        
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    func registerBackgroundTask() {
      backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
        self?.uploadPhoto()
      }
      assert(backgroundTask != .invalid)
    }
    
    func endBackgroundTask(){
      print("Background task ended.")
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
            
    var sessionManager: SessionManager?
    var backgroundSessionManager: SessionManager?
    
    func uploadPhoto(){
        //        guard let dict = bodyDict() else{
        //            self.showAlert(withMessage: "Please input all fields carefuly")
        //            return
        //        }
        //let nsData: Data = self.stringArrayToNSData(array: urlArr) as Data
        let nsData = loadFileFromLocalPath(urlArr[0])
        //            let image = imgVw_Profile.image!
        //            let imgData = image.jpegData(compressionQuality: 0.2)!
        
        
//        let parameters = ["email_to": emailToTF.text!,
//                          "email_from": yourEmailTF.text!,
//                          "message": msgTxtView.text!,
//                          "uploadagreeterms": "true",
//                          "backup": "true"]
        
        let emails = emailToTF.text!
        let parameters = ["email_to":emails,
                          "email_from": "tirhima.aman3@gmail.com",
                          "message": msgTxtView.text!,
                          "uploadagreeterms": "true",
                          "backup": "true"]
        
        print(parameters)
        let NetworkManager = Networking.sharedInstance.backgroundSessionManager
        NetworkManager.upload(multipartFormData: { [self] multipartFormData in
            for file in urlArr{
                let dataFile = loadFileFromLocalPath(file)

                multipartFormData.append(dataFile!, withName: "file[]", fileName: URL(fileURLWithPath: file).lastPathComponent + "[]", mimeType: URL(fileURLWithPath: file).mimeType() ?? "")
            }
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
        to:"https://bigg.ly/transfer")
        { (result) in
            switch result {

            case .success(let upload,_ ,_ ):
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    self.arrayProgress.forEach{
                        $0.angle = 360 * progress.fractionCompleted
                    }
                    
                    self.progressView.progress = Float(progress.fractionCompleted)
                    if progress.fractionCompleted == 1{
                        
                        self.successImages.isHidden = false
                        self.btnDone.isHidden = false
                       // self.showAlert(with: "Upload done! Please check email")
                    }
                })
                
                upload.responseJSON { response in
                    print(response.result.value)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
                if(UserDefaults.standard.value(forKey: "ErrorHandle") != nil){
                    let msg = UserDefaults.standard.value(forKey: "ErrorHandle") as? String
                    print(msg ?? "")
                    DispatchQueue.main.async { [self] in
                        self.view.makeToast(msg)
                    }
                }
                
            }
        }
    }
    
    
    func loadFileFromLocalPath(_ localFilePath: String) ->Data? {
       return try? Data(contentsOf: URL(fileURLWithPath: localFilePath))
    }
    
    func stringArrayToNSData(array: [String]) -> NSData {
        let data = NSMutableData()
        let terminator = [0]
        for string in array {
            if let encodedString = string.data(using: string.smallestEncoding ){
                data.append(encodedString)
                data.append(terminator, length: 1)
            } else {
                NSLog("Cannot encode string \"\(string)\"")
            }
        }
        return data
    }
    
    func validateFields() -> String? {
          // check that all fields are filled in
          if emailToTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&
              yourEmailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""  {
              return "Please fill in all the fielids."
          }
        
         // check if the email is valid
        let cleanedEmail = emailToTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let yourCleanedEmail = yourEmailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
//          if Utilities.isValidEmail(cleanedEmail) == false {
//              // email is not valid
//              showAlert(with: "Please write the proper email format.")
//              return "Please write the proper email format."
//          }
//        if Utilities.isValidEmail(yourCleanedEmail) == false {
//            // email is not valid
//            showAlert(with: "Please write the proper email format.")
//            return "Please write the proper email format."
//        }
         return nil
      }
}

extension UploadViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
        let a = String(describing: myURL)       // "file:////Users/Me/Desktop/Doc.txt"
      
        let d = myURL.path
        
        //fileName()
        print(urlArr)
        //self.urlArr.append(d)
        urls.forEach{urlArr.append($0.path)}
        urls.forEach{arrayNames.append($0.lastPathComponent)}
        print(urlArr)
        if urlArr.count > 0{
            self.dataAdded = true
        }else{
            self.dataAdded = false
        }
        
        self.mimeType = myURL.mimeType()
        let getFileExtension =  URL(fileURLWithPath: d).pathExtension
        print("import result getFileExtension: \(getFileExtension)")
        
        self.fileEXtension = getFileExtension
        
        guard let imageURL = urls.first else { return  }
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            do{
                self.imageData = try Data(contentsOf: imageURL)
                DispatchQueue.main.async {
                    print("Entered queue")
                    self.filesTblView.reloadData()
                    self.bigListTblView.reloadData()
                    self.ListView.isHidden = false
                    print(self.urlArr)
                }
            }catch{
                print("Unable to load data: \(error)")
            }
        }
    }
}

extension UploadViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == filesTblView{
            return self.urlArr.count
        }  else if tableView == bigListView{
            return self.urlArr.count
        }
        return self.urlArr.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UploadTVC
        if tableView == filesTblView{
            //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UploadTVC
            cell.titleLBL.text = self.arrayNames[indexPath.row]
            arrayProgress.append(cell.progressView)
            cell.buttonCross.tag = indexPath.row
            cell.buttonCross.addTarget(self, action: #selector(actionCross(sender:)), for: .touchUpInside)
            cell.progressView.startAngle = 0
         
        }else if tableView == bigListTblView{
            cell.titleLBL.text = self.arrayNames[indexPath.row]
        }
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
   @objc func actionCross(sender: UIButton){
        arrayNames.remove(at: sender.tag)
        urlArr.remove(at: sender.tag)
       
       guard urlArr.count != 0 else {
           ListView.isHidden = true
           return
       }
       filesTblView.reloadData()
   }
}
extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    var containsImage: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeImage)
    }
    var containsAudio: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeAudio)
    }
    var containsVideo: Bool {
        let mimeType = self.mimeType()
        guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeMovie)
    }
}

extension UploadViewController: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

class Networking {
    static let sharedInstance = Networking()
    public var sessionManager: Alamofire.SessionManager // most of your web service clients will call through sessionManager
    public var backgroundSessionManager: Alamofire.SessionManager // your web services you intend to keep running when the system backgrounds your app will use this
    private init() {
        self.sessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
        self.backgroundSessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: "com.youApp.identifier.backgroundtransfer"))
    }
}

extension UIViewController{
    func showAlert(with message: String){
        let alert = UIAlertController(title: "Bigg.ly", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UploadViewController :UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Message"  {
            textView.text = nil
            textView.textColor =  UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Message"
            textView.textColor = UIColor.white
        }
    }
}
