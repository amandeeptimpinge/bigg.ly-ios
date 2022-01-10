////
////  UploadVM.swift
////  Bigg.ly
////
////
//
//import Foundation
//#if canImport(FoundationNetworking)
//import FoundationNetworking
//#endif
//
//var semaphore = DispatchSemaphore (value: 0)
//
//let parameters = [
//    [
//        "key": "file[]",
//        "src": "/Users/souravnarula/Downloads/Artboard 1 2.png",
//        "type": "file"
//    ],
//    [
//        "key": "file[]",
//        "src": "/Users/souravnarula/Downloads/Artboard 1.png",
//        "type": "file"
//    ],
//    [
//        "key": "email_to",
//        "value": "email_address@ai.net",
//        "type": "text"
//    ],
//    [
//        "key": "email_from",
//        "value": "email_address@ai.net",
//        "type": "text"
//    ],
//    [
//        "key": "message",
//        "value": "This is a CLI test",
//        "type": "text"
//    ],
//    [
//        "key": "uploadagreeterms",
//        "value": "true",
//        "type": "text"
//    ],
//    [
//        "key": "backup",
//        "value": "true",
//        "type": "text"
//    ]] as [[String : Any]]
//
//let boundary = "Boundary-\(UUID().uuidString)"
//var body = ""
//var error: Error? = nil
//for param in parameters {
//    if param["disabled"] == nil {
//        let paramName = param["key"]!
//        body += "--\(boundary)\r\n"
//        body += "Content-Disposition:form-data; name=\"\(paramName)\""
//        if param["contentType"] != nil {
//            body += "\r\nContent-Type: \(param["contentType"] as! String)"
//        }
//        let paramType = param["type"] as! String
//        if paramType == "text" {
//            let paramValue = param["value"] as! String
//            body += "\r\n\r\n\(paramValue)\r\n"
//        } else {
//            let paramSrc = param["src"] as! String
//            let fileData = try NSData(contentsOfFile:paramSrc, options:[]) as Data
//            let fileContent = String(data: fileData, encoding: .utf8)!
//            body += "; filename=\"\(paramSrc)\"\r\n"
//                + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
//        }
//    }
//}
//body += "--\(boundary)--\r\n";
//let postData = body.data(using: .utf8)
//
//var request = URLRequest(url: URL(string: "https://bigg.ly/transfer")!,timeoutInterval: Double.infinity)
//request.addValue("PHPSESSID=imqk0i3f22l3c28plogc1uunq0; XSRF-TOKEN=eyJpdiI6InNRSkpxYUluRjFKUk1mYUJ5MXJaVEE9PSIsInZhbHVlIjoieElOa1JjTXBMY0NmejhOS2VoMkRod1AwaUJVcmxHb1QrZUlDRVF4WXFSN3hPRUwwYlBLcS9LVmdsR0IySXJzVjF3S0JVc0c3R1lORE9uQm1xN3V6TmU4T1h2Q3I3MThrSEdHdGJiZmgramNEMzExRTluTGlYWjc1Zy9yQ2JiL0UiLCJtYWMiOiIwMjRjYTVlOTIzZGFmYTU4NTNlNzJiYWE5ZDNmMzUwNmY1ZTQ4OWRlNjQyNGI0MDY5NDdhZGQ5MDg3MjkyYTdhIiwidGFnIjoiIn0%3D; biggly_session=eyJpdiI6IldWa2hnTEh3OVFsTThHVjRxODEvUEE9PSIsInZhbHVlIjoiaW0wZHVGclF4R3VHTURiaExOSmczSlFPS0dXRUh4djkrcmo1RWJ2ZFpmYjd0OFZURExPcXd1ZXU5SUpZVTlaY2d5R1N1bHRJWFhPQk85T2xFTXNtckRGdzhtL0ZzcnFIOWQyZ2pML3hadEJyeGhXODJqc3V3a2kyOTNieitVTjQiLCJtYWMiOiJmMWIyN2Q3NThmMjdlMTJkYWRmZDUxNjZkZmJlMzkyMTQxZmM3NTUxMzUyNTQ3YmE2MGI4OGE3Mzk4Y2VkYjcwIiwidGFnIjoiIn0%3D", forHTTPHeaderField: "Cookie")
//request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//request.httpMethod = "POST"
//request.httpBody = postData
//
//let task = URLSession.shared.dataTask(with: request) { data, response, error in
//    guard let data = data else {
//        print(String(describing: error))
//        semaphore.signal()
//        return
//    }
//    print(String(data: data, encoding: .utf8)!)
//    semaphore.signal()
//}
//
//task.resume()
//semaphore.wait()

