//
//  Item+Properties.swift
//  appdb
//
//  Created by ned on 02/10/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

//
// Content Properties
//
extension Item {

    var itemId: String {
        if let app = self as? App { return app.id.description }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.id.description }
        if let book = self as? Book { return book.id.description }
        if let officialApp = self as? OfficialApp { return officialApp.universalIdentifier }
        if let userApp = self as? UserApp { return userApp.universalIdentifier }
        if let repoApp = self as? RepoApp { return repoApp.universalIdentifier }
        return ""
    }

    var itemType: ItemType {
        if self is App { return .ios }
        if self is CydiaApp { return .cydia }
        if self is Book { return .books }
        if self is OfficialApp { return .official }
        if self is UserApp { return .user }
        if self is RepoApp { return .repo }
        return .__deprecated
    }

    var itemUniversalIdentifier: String {
        if let officialApp = self as? OfficialApp { return officialApp.id.description }
        if let userApp = self as? UserApp { return userApp.id.description }
        if let repoApp = self as? RepoApp { return repoApp.id.description }
        return ""
    }

    var itemName: String {
        if let app = self as? App { return app.name.decoded }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.name.decoded }
        if let book = self as? Book { return book.name.decoded }
        if let officialApp = self as? OfficialApp { return officialApp.name.decoded }
        if let userApp = self as? UserApp { return userApp.name.decoded }
        if let repoApp = self as? RepoApp { return repoApp.name.decoded }
        return ""
    }

    var itemVersion: String {
        if let app = self as? App { return app.version }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.version }
        if let officialApp = self as? OfficialApp { return officialApp.version }
        if let userApp = self as? UserApp { return userApp.version }
        if let repoApp = self as? RepoApp { return repoApp.version }
        return ""
    }

    var itemBundleId: String {
        if let app = self as? App { return app.bundleId }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.bundleId }
        return ""
    }

    var itemScreenshots: [Screenshot] {
        if let app = self as? App {
            if app.screenshotsIpad.isEmpty { return Array(app.screenshotsIphone) }
            if app.screenshotsIphone.isEmpty { return Array(app.screenshotsIpad) }
            return Array((app.screenshotsIpad ~~ app.screenshotsIphone))
        }
        if let cydiaApp = self as? CydiaApp {
            if cydiaApp.screenshotsIpad.isEmpty { return Array(cydiaApp.screenshotsIphone) }
            if cydiaApp.screenshotsIphone.isEmpty { return Array(cydiaApp.screenshotsIpad) }
            return Array((cydiaApp.screenshotsIpad ~~ cydiaApp.screenshotsIphone))
        }
        return []
    }

    var itemScreenshotsIphone: [Screenshot] {
        if let app = self as? App { return Array(app.screenshotsIphone) }
        if let cydiaApp = self as? CydiaApp { return Array(cydiaApp.screenshotsIphone) }
        return []
    }

    var itemScreenshotsIpad: [Screenshot] {
        if let app = self as? App { return Array(app.screenshotsIpad) }
        if let cydiaApp = self as? CydiaApp { return Array(cydiaApp.screenshotsIpad) }
        return []
    }

    var itemCydiaCategoryId: String {
        if let cydiaApp = self as? CydiaApp { return cydiaApp.categoryId.description }
        return ""
    }

    var itemRelatedContent: [RelatedContent] {
        if let book = self as? Book { return Array(book.relatedBooks) }
        return []
    }

    var itemDescription: String {
        if let app = self as? App { return app.description_ }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.description_ }
        if let book = self as? Book { return book.description_ }
        if let officialApp = self as? OfficialApp { return officialApp.description_ }
        if let userApp = self as? UserApp { return userApp.description_ }
        if let repoApp = self as? RepoApp { return repoApp.description_ }
        return ""
    }

    var itemChangelog: String {
        if let app = self as? App { return app.whatsnew }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.whatsnew }
        return ""
    }

    var itemUpdatedDate: String {
        if let app = self as? App { return app.published }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.updated }
        return ""
    }

    var itemOriginalTrackid: String {
        if let cydiaApp = self as? CydiaApp { return cydiaApp.originalTrackid.description }
        return ""
    }

    var itemOriginalSection: String {
        if let cydiaApp = self as? CydiaApp { return cydiaApp.originalSection }
        return ""
    }

    var itemReviews: [Review] {
        if let book = self as? Book { return Array(book.reviews) }
        return []
    }

    var itemWebsite: String {
        if let app = self as? App { return app.website }
        return ""
    }

    var itemSupport: String {
        if let app = self as? App { return app.support }
        return ""
    }

    var itemSeller: String {
        if let app = self as? App { return app.seller }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.developer }
        if let book = self as? Book { return book.author }
        if let officialApp = self as? OfficialApp { return officialApp.developer }
        if let userApp = self as? UserApp { return userApp.developer }
        if let repoApp = self as? RepoApp { return repoApp.developer }
        return ""
    }

    var itemIconUrl: String {
        if let app = self as? App { return app.image }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.image }
        if let book = self as? Book { return book.image }
        if let officialApp = self as? OfficialApp { return officialApp.icon }
        return ""
    }

    var itemFirstScreenshotUrl: String {
        itemScreenshots.first?.image ?? ""
    }

    var itemFirstTwoScreenshotsUrls: [String] {
        guard itemScreenshots.count > 1 else { return [] }
        return [itemScreenshots[0].image, itemScreenshots[1].image]
    }

    var itemFirstThreeScreenshotsUrls: [String] {
        guard itemScreenshots.count > 2 else { return [] }
        return [itemScreenshots[0].image, itemScreenshots[1].image, itemScreenshots[2].image]
    }

    var itemIsTweaked: Bool {
        if let cydiaApp = self as? CydiaApp { return cydiaApp.isTweaked }
        return false
    }

    var itemHasStars: Bool {
        if let app = self as? App { return !app.numberOfStars.isZero && !app.numberOfRating.isEmpty }
        if let book = self as? Book { return !book.numberOfStars.isZero && !book.numberOfRating.isEmpty }
        return false
    }

    var itemNumberOfStars: Double {
        if let app = self as? App { return app.numberOfStars }
        if let book = self as? Book { return book.numberOfStars }
        return 0
    }

    var itemRating: String {
        if let app = self as? App { return app.numberOfRating }
        if let book = self as? Book { return book.numberOfRating }
        return ""
    }

    var downloadsDay: String {
        if let app = self as? App { return app.clicksDay.description }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.clicksDay.description }
        if let book = self as? Book { return book.clicksDay.description }
        return "-"
    }
    var downloadsWeek: String {
        if let app = self as? App { return app.clicksWeek.description }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.clicksWeek.description }
        if let book = self as? Book { return book.clicksWeek.description }
        return "-"
    }
    var downloadsMonth: String {
        if let app = self as? App { return app.clicksMonth.description }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.clicksMonth.description }
        if let book = self as? Book { return book.clicksMonth.description }
        return "-"
    }
    var downloadsYear: String {
        if let app = self as? App { return app.clicksYear.description }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.clicksYear.description }
        if let book = self as? Book { return book.clicksYear.description }
        return "-"
    }
    var downloadsAll: String {
        if let app = self as? App { return app.clicksAll.description }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.clicksAll.description }
        if let book = self as? Book { return book.clicksAll.description }
        return "-"
    }
}
