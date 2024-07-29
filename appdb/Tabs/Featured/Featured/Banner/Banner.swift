//
//  Banner.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit

import TelemetryClient

extension Banner: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as? BannerImage else { return UICollectionViewCell() }
        let banner = banners[indexPath.row % banners.count]
        cell.image.image = UIImage(named: banner)
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        banners.count// * multiplier // simulate infinite scroll
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pauseTimer()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setTimerIfNeeded()

        // Update current index to the correct one
        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        currentIndex = indexPath.row
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch banners[indexPath.row % banners.count] {
        case "tweaked_apps_banner": UIApplication.shared.open(URL(string: "appdb-ios://?tab=custom_apps")!)
        case "unc0ver_banner": UIApplication.shared.open(URL(string: "appdb-ios://?trackid=1900000487&type=cydia")!)
        case "delta_banner": UIApplication.shared.open(URL(string: "appdb-ios://?trackid=1900000176&type=cydia")!)
        default: break
        }
        TelemetryManager.send(Global.Telemetry.clickedBanner.rawValue)
    }
}

class Banner: UIView {

    let multiplier: Int = 2
    var collectionView: UICollectionView!

    var banners: [String] {
        var banners = ["main_banner"/*, "tweaked_apps_banner", "unc0ver_banner", "delta_banner"*/]
        if Global.isRtl { banners = [banners.first!] + banners.dropFirst().reversed() }
        return banners
    }

    static let height: CGFloat = {
        let w = Double(UIScreen.main.bounds.width)
        let h = Double(UIScreen.main.bounds.height)
        let screenWidth: Double = min(w, h)
        return (230 ~~ CGFloat(screenWidth / 2.517 + 2))
    }()

    // Timer to scroll automatically
    private var slideshowTimer: Timer?

    // Keeps track of the current element's index
    private var currentIndex: Int = 0

    var slideshowInterval = 0.0 {
        didSet {
            self.slideshowTimer?.invalidate()
            self.slideshowTimer = nil
        }
    }

    convenience init() {
        self.init(frame: .zero)

        backgroundColor = .clear

        let layout = LNZInfiniteCollectionViewLayout()
        layout.itemSize = CGSize(width: Banner.height * 2.517, height: Banner.height)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(BannerImage.self, forCellWithReuseIdentifier: "image")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.alwaysBounceVertical = false

        collectionView.theme_backgroundColor = Color.tableViewBackgroundColor
        addSubview(collectionView)

        // Add constraints
        constrain(collectionView) { collectionView in
            collectionView.top ~== collectionView.superview!.top
            collectionView.leading ~== collectionView.superview!.leading
            collectionView.trailing ~== collectionView.superview!.trailing
            collectionView.height ~== Banner.height
        }

        slideshowInterval = 4.5
    }

    // Set up timer if needed
    open func setTimerIfNeeded() {
        if slideshowInterval > 0 && slideshowTimer == nil {
            // slideshowTimer = Timer.scheduledTimer(timeInterval: slideshowInterval, target: self, selector: #selector(self.slideshowTick(_:)), userInfo: nil, repeats: true)
        }
    }

    // Increase current index & scroll
    @objc func slideshowTick(_ timer: Timer) {
        currentIndex += 1
        if currentIndex == banners.count * multiplier { currentIndex = 0 }
        let bannerWidth: CGFloat = Banner.height * 2.517
        let newX: CGFloat = Global.isRtl ?
            collectionView.contentOffset.x - bannerWidth :
            collectionView.contentOffset.x + bannerWidth
        let newPoint = CGPoint(x: newX, y: collectionView.contentOffset.y)
        collectionView.setContentOffset(newPoint, animated: true)
    }

    // Invalidate timer
    open func pauseTimer() {
        slideshowTimer?.invalidate()
        slideshowTimer = nil
    }
}
