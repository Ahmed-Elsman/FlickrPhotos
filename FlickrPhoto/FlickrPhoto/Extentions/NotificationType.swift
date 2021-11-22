//
//  NotificationType.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 22/11/2021.
//

import Foundation

protocol NotificationType {
    var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: NotificationType {
    var name: Notification.Name {
        return Notification.Name(rawValue)
    }
}

enum Notifications {
    enum Reachability: String, NotificationType {
        case connected
        case notConnected
    }
}
