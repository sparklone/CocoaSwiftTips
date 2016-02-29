

import UIKit

class NetworkDelegate: NSObject, NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate {
    var url = ""
    @objc func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print(totalBytesWritten)
    }
    
    @objc func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        print("done")
    }
    
    @objc func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        print("\(url) {")
        let gmailCount = session.configuration.HTTPCookieStorage?.cookiesForURL(NSURL(string: "https://google.ru")!)?.count
        print("google cookies Count: \(gmailCount)")
        let yandexCount = session.configuration.HTTPCookieStorage?.cookiesForURL(NSURL(string: "https://ya.ru")!)?.count
        print("yandex cookies Count: \(yandexCount)")
        print("all cookies count: \(session.configuration.HTTPCookieStorage?.cookies?.count)")
        print("}")
    }
}

func createTask(cookieStorage: NSHTTPCookieStorage?, url: String) -> NSURLSessionDataTask {
    let delegate = NetworkDelegate()
    delegate.url = url
    let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    if let cookieStorage = cookieStorage {
        config.HTTPCookieStorage = cookieStorage
    }
    let session = NSURLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    
    let request = NSURLRequest(URL: NSURL(string: url)!)
    let task = session.dataTaskWithRequest(request)
    return task
}

func openPages(cookieStorage: NSHTTPCookieStorage?, sleepTime: Int) {
    let googleTask = createTask(cookieStorage, url: "https://ya.ru")
    googleTask.resume()
    sleep(UInt32(sleepTime))
    let yandexTask = createTask(cookieStorage, url: "https://google.ru")
    yandexTask.resume()
    sleep(UInt32(sleepTime))
}

let sleepTime = 2

//используем приватное хранилище cookies, но расшариваем его между разными сессиями
//работает начиная с iOS 9
print("-- shared ephemeral cookies storage --")
let testConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
openPages(testConfig.HTTPCookieStorage, sleepTime: sleepTime)
print("")

//используем для каждой сессии свое приватное хранилище cookies
print("-- defalut ephemeral cookies storage --")
openPages(nil, sleepTime: sleepTime)
print("")

//используем для каждой сессии свое приватное хранилище cookies
print("-- custom shared cookies storage --")
let customCookiesStorage = NSHTTPCookieStorage()
openPages(customCookiesStorage, sleepTime: sleepTime)
print("")

