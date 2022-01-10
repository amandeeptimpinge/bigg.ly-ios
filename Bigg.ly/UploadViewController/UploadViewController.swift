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
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
class UploadViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var bigExpandBTN: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var uploadBTN: UIButton!
    @IBOutlet weak var emailToTF: UITextField!
    @IBOutlet weak var yourEmailTF: UITextField!
    @IBOutlet weak var sideMenuBTN: UIButton!
    @IBOutlet weak var msgTxtView: UITextView!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var sendBTN: UIButton!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var msgInput: UIImageView!
    @IBOutlet weak var expandBTN: UIButton!
    @IBOutlet weak var filesTblView: UITableView!
    @IBOutlet weak var ListView: UIView!
    @IBOutlet weak var listViewHeight: NSLayoutConstraint!
    @IBOutlet weak var listViewWidth: NSLayoutConstraint!
    @IBOutlet weak var listViewX: NSLayoutConstraint!
    @IBOutlet weak var listViewY: NSLayoutConstraint!
    @IBOutlet weak var bigListView: UIView!
    @IBOutlet weak var bigListTblView: UITableView!
    
    var fileEXtension: String = ""
    var uploadItemsArr = [Any]()
    var urlArr = [String]()
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
    var checked = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let types = [kUTTypePDF, kUTTypeText, kUTTypeSpreadsheet,kUTTypeData,kUTTypeJPEG,]
        let importMenu = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        importMenu.allowsMultipleSelection = true
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        present(importMenu, animated: true)
    }
    
    
    @IBAction func sendBTNTapped(_ sender: Any) {
        print(parameters)
        print(urlArr)
        //        if self.urlArr != nil{
        self.uploadPhoto()
        //        }
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
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        return
    }
    
    func uploadPhoto(){
        //        guard let dict = bodyDict() else{
        //            self.showAlert(withMessage: "Please input all fields carefuly")
        //            return
        //        }
        let nsData: Data = self.stringArrayToNSData(array: urlArr) as Data
        //            let image = imgVw_Profile.image!
        //            let imgData = image.jpegData(compressionQuality: 0.2)!
        
        let parameters = ["email_to": emailToTF.text!,
                          "email_from": yourEmailTF.text!,
                          "message": msgTxtView.text!,
                          "uploadagreeterms": "true",
                          "backup": "true"]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(nsData, withName: "file[]",fileName: "file.\(self.fileEXtension)", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        },
        to:"https://bigg.ly/transfer")
        { (result) in
            switch result {
            
            case .success(let upload,_ ,_ ):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    print(response.result.value)
                    //                    self.msg = response.result.value["msg"]
                    //                       self.showAlert(withMessage: "Member Added Sucessfully")
                    //  self.navigationController?.popViewController(animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    //              let dashboardVC = self.storyboard?.instantiateViewController(identifier: "CommunityMembersVC") as! CommunityMembersVC
                    //                self.navigationController?.pushViewController(dashboardVC, animated: true)
                }
                
            case .failure(let encodingError):
                print(encodingError)
                if(UserDefaults.standard.value(forKey: "ErrorHandle") != nil){
                    let msg = UserDefaults.standard.value(forKey: "ErrorHandle") as? String
                    print(msg ?? "")
                    DispatchQueue.main.async { [self] in
                        self.view.makeToast(msg)
                        //                       self.showAlert(withMessage: msg!)
                    }
                }
                
            }
        }
        
    }
    
    func stringArrayToNSData(array: [String]) -> NSData {
        let data = NSMutableData()
        let terminator = [0]
        for string in array {
            if let encodedString = string.data(using: string.smallestEncoding ){
                data.append(encodedString)
                //                data.append(encodedString, length: 1)
                data.append(terminator, length: 1)
            }
            else {
                NSLog("Cannot encode string \"\(string)\"")
            }
        }
        return data
    }
    
}
extension UploadViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
        //        self.urlArr.removeAll()
        let a = String(describing: myURL)       // "file:////Users/Me/Desktop/Doc.txt"
        //         let b = "\(myURL)"                      // "file:////Users/Me/Desktop/Doc.txt"
        //         let c = myURL.absoluteString            // "file:////Users/Me/Desktop/Doc.txt"
        let d = myURL.path
        
        //         fileName()
        print(urlArr)
        self.urlArr.append(d)
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
                    // let image = UIImage(data: imageData)
                    // self.dataSentToServer = imageData
                    // self.userImageView.image = image
                    // self.userImageView.sizeToFit()
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
            //        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UploadTVC
            cell.titleLBL.text = self.urlArr[indexPath.row]
            //        return cell
        }else if tableView == bigListTblView{
            //            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UploadTVC
            cell.titleLBL.text = self.urlArr[indexPath.row]
            //            return cell
        }
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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

