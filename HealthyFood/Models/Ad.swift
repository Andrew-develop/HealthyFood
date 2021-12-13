//
//  Ad.swift
//  HealthyFood
//
//  Created by Sergio Ramos on 25.06.2021.
//

import Foundation

struct Ad : Codable, Equatable {
    let name : String
    let desc : String?
    let price : Int
    let phone : String
    let adId : String
}
