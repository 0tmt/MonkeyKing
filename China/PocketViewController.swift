//
//  PocketViewController.swift
//  China
//
//  Created by catch on 15/11/25.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit
import MonkeyKing

let pocketAppID = "48363-344532f670a052acff492a25"

class PocketViewController: UIViewController {

    let account = MonkeyKing.Account.Pocket(appID: pocketAppID)
    var accessToken: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        MonkeyKing.registerAccount(account)
    }

    // Save URL to Pocket
    @IBAction func saveButtonAction(sender: UIButton) {

        guard let accessToken = accessToken else {
            return
        }

        let addAPI = "https://getpocket.com/v3/add"
        let parameters = [
            "url": "http://tips.producter.io",
            "title": "Producter",
            "consumer_key": pocketAppID,
            "access_token": accessToken
        ]

        SimpleNetworking.sharedInstance.request(NSURL(string: addAPI)!, method: .POST, parameters: parameters) { (dict, response, error) -> Void in
            print(dict)
        }

        // More API
        // https://getpocket.com/developer/docs/v3/add
    }

    @IBAction func OAuth(sender: UIButton) {

        guard let startIndex = pocketAppID.rangeOfString("-")?.startIndex else {
            return
        }

        let prefix = pocketAppID.substringToIndex(startIndex)
        let requestAPI = "https://getpocket.com/v3/oauth/request"
        let redirectURLString = "pocketapp\(prefix):authorizationFinished"

        let parameters = [
            "consumer_key": pocketAppID,
            "redirect_uri": redirectURLString
        ]

        print("S1: fetch requestToken")

        SimpleNetworking.sharedInstance.request(NSURL(string: requestAPI)!, method: .POST, parameters: parameters) { [weak self] (dict, response, error) -> Void in

            guard let strongSelf = self, requestToken = dict?["code"] as? String else {
                return
            }

            print("S2: OAuth by requestToken")

            MonkeyKing.OAuth(strongSelf.account, requestToken: requestToken) { (dictionary, response, error) -> Void in
    
                let accessTokenAPI = "https://getpocket.com/v3/oauth/authorize"
                let parameters = [
                    "consumer_key": pocketAppID,
                    "code": requestToken
                ]

                print("S3: fetch OAuth state")

                SimpleNetworking.sharedInstance.request(NSURL(string: accessTokenAPI)!, method: .POST, parameters: parameters) { (JSON, response, error) -> Void in

                    print("S4: OAuth completion")

                    print("JSON: \(JSON)")

                    // If the HTTP status of the response is 200, then the request completed successfully.
                    print("response: \(response)")

                    strongSelf.accessToken = JSON?["access_token"] as? String

                }
            }

            // More details
            // Pocket Authentication API Documentation: https://getpocket.com/developer/docs/authentication

        }
    }

}
