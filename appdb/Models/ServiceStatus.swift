//
//  ServiceStatus.swift
//  appdb
//
//  Created by ned on 05/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import ObjectMapper

struct ServiceStatus: Mappable {

    init?(map: Map) { }

    var name: String = ""
    var isOnline = false
    var data: String?
    var dataInt: Int?
    var dataString: String?

    mutating func mapping(map: Map) {
        name <- map["name"]
        isOnline <- map["is_online"]
        dataInt <- map["data"]
        dataString <- map["data"]
        if dataInt != nil {
            data = String(dataInt!)
        }
        if dataString != nil {
            data = dataString
        }
    }
}
