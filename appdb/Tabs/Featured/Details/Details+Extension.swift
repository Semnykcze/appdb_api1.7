//
//  Details+Extension.swift
//  appdb
//
//  Created by ned on 19/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import ObjectMapper

// Details cell template
class DetailsCell: UITableViewCell {
    var type: ItemType = .ios
    var identifier: String { "" }
    var height: CGFloat { 0 }
    func setConstraints() {}
}

extension Details {

    // Returns content type
    var contentType: ItemType {
        if content is App { return .ios }
        if content is CydiaApp { return .cydia }
        if content is Book { return .books }
        if content is OfficialApp { return .official }
        if content is RepoApp { return .repo }
        if content is UserApp { return .user }
        return .ios
    }

    // Set up
    func setUp() {
        // Register cells
        for cell in header { tableView.register(type(of: cell), forCellReuseIdentifier: cell.identifier) }
        for cell in details { tableView.register(type(of: cell), forCellReuseIdentifier: cell.identifier) }
        tableView.register(DetailsDescription.self, forCellReuseIdentifier: "description")
        tableView.register(DetailsChangelog.self, forCellReuseIdentifier: "changelog")
        tableView.register(DetailsReview.self, forCellReuseIdentifier: "review")
        tableView.register(DetailsDownload.self, forCellReuseIdentifier: "download")
        tableView.register(DetailsDownloadUnified.self, forCellReuseIdentifier: "downloadUnified")

        // Initialize 'Share' button
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.share))
        shareButton.isEnabled = false

        if Global.isIpad {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItems = [dismissButton, shareButton]
        } else {
            self.navigationItem.rightBarButtonItems = [shareButton]
        }

        // Hide separator for empty cells
        tableView.tableFooterView = UIView()

        // Register for 3D Touch
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }

        // UI
        tableView.theme_backgroundColor = Color.veryVeryLightGray
        tableView.separatorStyle = .none // Let's use self made separators instead

        // Fix random separator margin issues
        if #available(iOS 9, *) { tableView.cellLayoutMarginsFollowReadableWidth = false }

        // Fix iOS 15 tableview section header padding
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    // Get content dynamically
    func getContent<T>(type: T.Type, universalIdentifier: String, success: @escaping (_ item: T) -> Void) where T: Item {
        API.searchByUniversalIdentifier(type: type, universalIdentifier: universalIdentifier, success: { item in
            success(item)
        }, fail: { [weak self] error in
            guard let self else { return }
            self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error)
        })
    }

    func __getContentDeprecated<T>(type: T.Type, trackid: String, success: @escaping (_ item: T) -> Void) where T: Item {
        API.search(type: type, trackid: trackid, success: { [weak self] items in
            guard let self = self else { return }
            if let item = items.first { success(item) } else { self.showErrorMessage(text: "Not found".localized(), secondaryText: "Couldn't find content with id %@ in our database".localizedFormat(trackid)) }
        }, fail: { error in
            self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error)
        })
    }

    func fetchInfo(type: ItemType, trackid: String) {
        switch type {
        case .ios:
            self.__getContentDeprecated(type: App.self, trackid: trackid, success: { item in
                self.content = item
                self.initializeCells()
                self.state = .done
                self.getLinks()
            })
        case .cydia:
            self.__getContentDeprecated(type: CydiaApp.self, trackid: trackid, success: { item in
                self.content = item
                self.initializeCells()
                self.state = .done
                self.getLinks()
            })
        case .books:
            self.__getContentDeprecated(type: Book.self, trackid: trackid, success: { item in
                self.content = item
                self.initializeCells()
                self.state = .done
                self.getLinks()
            })
        case .official:
            self.getContent(type: OfficialApp.self, universalIdentifier: trackid, success: { item in
                self.content = item
                self.initializeCells()
                self.state = .done
                self.getLinks()
            })

        case .user:
            self.getContent(type: UserApp.self, universalIdentifier: trackid, success: { item in
                self.content = item
                self.initializeCells()
                self.state = .done
                self.getLinks()
            })

        case .repo:
            self.getContent(type: RepoApp.self, universalIdentifier: trackid, success: { item in
                self.content = item
                self.initializeCells()
                self.state = .done
                self.getLinks()
            })
        default:
            break
        }
    }

    // Initialize cells
    func initializeCells() {
        header = [DetailsHeader(type: contentType, content: content, delegate: self)]

        details = [
            // DetailsTweakedNotice(originalTrackId: content.itemOriginalTrackid, originalSection: content.itemOriginalSection, delegate: self),
            DetailsScreenshots(type: contentType, screenshots: content.itemScreenshots, delegate: self),
            DetailsDescription(), // dynamic
            // DetailsChangelog(), // dynamic
            // DetailsRelated(type: contentType, related: content.itemRelatedContent, delegate: self),
            // DetailsInformation(type: contentType, content: content),
            // DetailsDownloadStats(content: content)
            // DetailsDownloadStats(content: content)
            DetailsPublisher("© " + content.itemSeller)
        ]

        switch contentType {
        case .ios: if let app = content as? App {
            details.append(DetailsExternalLink(text: "Developer Apps".localized(), devId: app.artistId.description, devName: app.seller))
            if !app.website.isEmpty { details.append(DetailsExternalLink(text: "Developer Website".localized(), url: content.itemWebsite)) }
            if !app.support.isEmpty { details.append(DetailsExternalLink(text: "Developer Support".localized(), url: content.itemSupport)) }
            if !app.publisher.isEmpty { details.append(DetailsPublisher(app.publisher)) }
            }
        case .cydia: if let app = content as? CydiaApp {
            details.append(DetailsPublisher("© " + app.developer))
            }
        case .books: if let book = content as? Book {
            details.append(DetailsExternalLink(text: "More by this author".localized(), devId: book.artistId.description, devName: book.author))
            if !book.publisher.isEmpty { details.append(DetailsPublisher(book.publisher)) } else if !book.author.isEmpty { details.append(DetailsPublisher("© " + book.author)) }
            }
        default:
            break
        }
        shareButton.isEnabled = true
    }

    // Get links
    func getLinks() {
        API.getLinks(type: contentType, trackid: content.itemId, success: { [weak self] items in
            guard let self = self else { return }

            self.versions = items

            // Ensure latest version is always at the top
            if let latest = self.versions.first(where: {$0.number == self.content.itemVersion}) {
                if let index = self.versions.firstIndex(of: latest) {
                    self.versions.remove(at: index)
                    self.versions.insert(latest, at: 0)
                }
            }

            // Enable links segment
            self.loadedLinks = true
        }, fail: { _ in })
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    // Details/Reviews for details segment
    var itemsForSegmentedControl: [DetailsSelectedSegmentState] {
        switch contentType {
        case .books: if let book = content as? Book {
            if !book.reviews.isEmpty { return [.details, .reviews, .download] }
            return [.details, .download]
        }
        default: break
        }; return [.details, .download]
    }

    // Setting the right estimated height for rows with dynamic content helps with tableview jumping issues
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexForSegment {
        case .details:
            if details[indexPath.row] is DetailsDescription {
                return 145 ~~ 135
            } else if details[indexPath.row] is DetailsChangelog {
                return 115 ~~ 105
            } else {
                return 32
            }
        case .reviews:
            return indexPath.row == content.itemReviews.count ? 32 : 110 ~~ 150
        default:
            return 32
        }
    }

    // Reload data on rotation to update ElasticLabel text
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard self.tableView != nil else { return }
            if self.indexForSegment != .download { self.tableView.reloadData() }
        }, completion: nil)
    }
}

// MARK: - iOS 13 Context Menus

@available(iOS 13.0, *)
extension Details {

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        guard let cell = tableView.cellForRow(at: indexPath) as? DetailsRelated else { return nil }

        guard let index = cell.collectionView.indexPathForItem(at: self.view.convert(point, to: cell.collectionView)) else { return nil }
        guard cell.relatedContent.indices.contains(index.row) else { return nil }

        let indexPathsIdentifiers: [IndexPath] = [indexPath, index]

        return UIContextMenuConfiguration(identifier: indexPathsIdentifiers as NSCopying, previewProvider: { Details(type: self.contentType, trackid: cell.relatedContent[index.row].id) })
    }

    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let viewController = animator.previewViewController {
                self.show(viewController, sender: self)
            }
        }
    }

    override func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard let ids = configuration.identifier as? [IndexPath] else { return nil }
        guard ids.indices.contains(0), ids.indices.contains(1) else { return nil }
        let firstIndex = ids[0], secondIndex = ids[1]

        guard let cell = tableView.cellForRow(at: firstIndex) as? DetailsRelated else { return nil }
        guard cell.relatedContent.indices.contains(secondIndex.row) else { return nil }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        if let collectionViewCell = cell.collectionView.cellForItem(at: secondIndex) {
            return UITargetedPreview(view: collectionViewCell.contentView, parameters: parameters)
        }

        return nil
    }
}

// MARK: - 3D Touch Peek and Pop on icons

extension Details: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) as? DetailsRelated else { return nil }

        guard let index = cell.collectionView.indexPathForItem(at: self.view.convert(location, to: cell.collectionView)) else { return nil }
        guard cell.relatedContent.indices.contains(index.row) else { return nil }

        if let collectionViewCell = cell.collectionView.cellForItem(at: index) as? FeaturedApp {
            let iconRect = tableView.convert(collectionViewCell.icon.frame, from: collectionViewCell.icon.superview!)
            if #available(iOS 9.0, *) { previewingContext.sourceRect = iconRect }
        } else if let collectionViewCell = cell.collectionView.cellForItem(at: index) as? FeaturedBook {
            let coverRect = tableView.convert(collectionViewCell.cover.frame, from: collectionViewCell.cover.superview!)
            if #available(iOS 9.0, *) { previewingContext.sourceRect = coverRect }
        } else {
            return nil
        }

        let detailsViewController = Details(type: contentType, trackid: cell.relatedContent[index.row].id)
        return detailsViewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
