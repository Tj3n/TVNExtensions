//
//  User.swift
//  RxGithub
//
//  Created by TienVu on 1/23/19.
//  Copyright © 2019 TienVu. All rights reserved.
//

import Foundation

struct User {
    let login: String
    let id: Int
    let nodeID: String
    let avatarURL: String
    let gravatarID: String
    let url, htmlURL, followersURL: String
    let followingURL, gistsURL, starredURL: String
    let subscriptionsURL, organizationsURL, reposURL: String
    let eventsURL: String
    let receivedEventsURL: String
    let type: String
    let siteAdmin: Bool
    let name: String
    let company: NSNull
    let blog, location: String
    let email, hireable: NSNull
    let bio: String
    let publicRepos, publicGists, followers, following: Int
    let createdAt, updatedAt: Date
    let privateGists, totalPrivateRepos, ownedPrivateRepos, diskUsage: Int?
    let collaborators: Int?
    let twoFactorAuthentication: Bool?
    let plan: Plan?
}

struct Plan {
    let name: String
    let space, collaborators, privateRepos: Int
}
