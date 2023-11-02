//
//  DatabaseProtocol.swift
//  C-Money
//
//  Created by Dongzheng Wu on 21/4/2023.
//

import Foundation
import Firebase


enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case record
    case records //     This is the container for all the records, each user has one "records"
    case saving
    case savings //     This is the container for all the savings, each user has one "savings"
    case progress
    case progresses //  This is the container for all the progresses, each user has one "progresses"
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onRecordChange(change: DatabaseChange, records: [Record])
    func onSavingChange(change: DatabaseChange, saving: [Saving])
    func onProgressChange(change: DatabaseChange, progress: [Progress])
}

protocol DatabaseProtocol: AnyObject {
    var authController: Auth {get set}
    var recordRef: CollectionReference? {get set}
    var savingRef: CollectionReference? {get set}
    var progressRef: CollectionReference? {get set}
    var currentUser: FirebaseAuth.User? {get set}
        
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func setupRecordListener(completion: @escaping () -> Void)
    func setupRecordsListener(completion: @escaping () -> Void)
    func setupSavingListener(completion: @escaping () -> Void)
    func setupSavingsListener(completion: @escaping () -> Void)
    func setupProgressListener(completion: @escaping () -> Void)
    func setupProgressesListener(completion: @escaping () -> Void)
    
    func addRecord(record: Record) -> Record
    func addRecords(email: String) -> Records
    func addRecordIntoRecords(record: Record) -> Bool
    func deleteRecord(record: Record)
    
    func addSaving(saving: Saving) -> Saving
    func addSavings(email: String) -> Savings
    func addSavingIntoSavings(saving: Saving) -> Bool
    func deleteSaving(saving:Saving)
    
    func addProgress(progress: Progress) -> Progress
    func addProgresses(email: String) -> Progresses
    func addProgressIntoProgresses(progress: Progress) -> Bool
    func deleteProgress(progress: Progress)
    
    func signup(email: String, password: String)
    func signout()
}
