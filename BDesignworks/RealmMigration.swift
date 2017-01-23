//
//  RealmMigration.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 23/01/2017.
//  Copyright © 2017 Flatstack. All rights reserved.
//

import Foundation

func ConfigureRealmMigrations() {
    Realm.Configuration.defaultConfiguration = Realm.Configuration(
        schemaVersion: 1,
        migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
    })
}
