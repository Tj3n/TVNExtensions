//
//  Repo.swift
//  RxGithub
//
//  Created by TienVu on 1/23/19.
//  Copyright © 2019 TienVu. All rights reserved.
//

import Foundation

struct Event {
    let id, type: String
    let actor: Actor
    let repo: EventRepo
    let payload: Payload
    let eventsPublic: Bool
    let createdAt: Date
    let org: Actor
}

struct Actor {
    let id: Int
    let login: String
    let displayLogin: String?
    let gravatarID: String
    let url, avatarURL: String
}

struct Payload {
    let action: String
}

struct EventRepo {
    let id: Int
    let name: String
    let url: String
}
