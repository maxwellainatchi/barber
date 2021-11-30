//
//  BackgroundScheduledLoadState.swift
//  barber
//
//  Created by Maxwell Ainatchi on 11/30/21.
//  Copyright © 2021 Max Ainatchi, Inc. All rights reserved.
//

import Foundation

class BackgroundScheduledLoadState<T>: LoadState<T> {
    private lazy var scheduler: NSBackgroundActivityScheduler = {
        let scheduler = NSBackgroundActivityScheduler(identifier: "me.ainatchi.max.Barber")
        scheduler.repeats = true
        let range = (self.intervalRange.upperBound - self.intervalRange.lowerBound) / 2
        scheduler.interval = self.intervalRange.lowerBound + range
        scheduler.tolerance = range
        return scheduler
    }()

    private var lastUpdateTime: Date?

    var intervalRange: ClosedRange<TimeInterval>

    init(interval: ClosedRange<TimeInterval>, load: @escaping (() async throws -> T)) {
        self.intervalRange = interval
        super.init(load: load)
    }

    deinit {
        self.scheduler.invalidate()
    }

    func schedule() {
        self.scheduler.schedule { completion in
            Task { [weak self] in
                guard let self = self else {
                    completion(.deferred)
                    return
                }
                self.refreshIfNeeded()
                if self.scheduler.shouldDefer {
                    completion(.deferred)
                } else {
                    completion(.finished)
                }
            }
        }
    }

    override func reloadAsync(force: Bool) async {
        print("reloading")
        await super.reloadAsync(force: force)
        print("reloaded")
        self.lastUpdateTime = Date()
    }

    func refreshIfNeeded() {
        print("refreshing, last update time", self.lastUpdateTime?.description ?? "none")
        if let lastUpdateTime = self.lastUpdateTime {
            print("time since last update", lastUpdateTime.timeIntervalSinceNow)
        }
        guard let lastUpdateTime = self.lastUpdateTime, abs(lastUpdateTime.timeIntervalSinceNow) >= self.intervalRange.upperBound else {
            print("no refresh needed.")
            return
        }
        self.reload(force: true)
    }
}
