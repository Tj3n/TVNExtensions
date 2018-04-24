//
//  ChargeObject.swift
//  DemoTest
//
//  Created by Tien Nhat Vu on 4/17/18.
//

import Foundation

public struct ChargeObject: Codable {
    let object: String
    let created: Int
    let refunded: Bool
    let card: Card
    let test: Int
    let amountPaid: String
    let supportLink: URL
    
//    private enum ChargeObjectCodingKey: String, CodingKey {
//        case object = "object"
//        case created = "created"
//        case refunded = "refunded"
//        case card = "card"
//        case test = "test"
//        case amountPaid = "amount_paid"
//        case supportLink = "support_link"
//    }
    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: ChargeObjectCodingKey.self)
//        object = try container.decode(String.self, forKey: .object)
//        created = try container.decode(Int.self, forKey: .created)
//        refunded = try container.decode(Bool.self, forKey: .refunded)
//        test = try container.decode(Int.self, forKey: .test)
//        amountPaid = try container.decode(String.self, forKey: .amountPaid)
//        card = try container.decode(Card.self, forKey: .card)
//        support_link = try container.decode(URL.self, forKey: .support_link)
//    }
}

struct Card: Codable {
    let last4: String
    let type: String
    let country: String
    let expYear: String
    let expMonth: String
    
//    private enum CardCodingKey: String, CodingKey {
//        case last4 = "last4"
//        case type = "type"
//        case country = "country"
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CardCodingKey.self)
//        last4 = try container.decode(String.self, forKey: .last4)
//        type = try container.decode(String.self, forKey: .type)
//        country = try container.decode(String.self, forKey: .country)
//    }
}
