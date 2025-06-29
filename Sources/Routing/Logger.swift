//
//  Logger.swift
//  Routing
//
//  Created by ned on 02/07/25.
//

import Foundation
import os.log

public enum RoutingLogger {
    private static let subsystem = "com.routing"

    public static let router = Logger(subsystem: subsystem, category: "router")
    public static let deepLinking = Logger(subsystem: subsystem, category: "deepLinking")
    public static let stateRestoration = Logger(subsystem: subsystem, category: "stateRestoration")
}
