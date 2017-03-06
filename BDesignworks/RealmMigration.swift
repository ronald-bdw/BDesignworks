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
        schemaVersion: 3,
        migrationBlock: { migration, oldSchemaVersion in
    })
}
