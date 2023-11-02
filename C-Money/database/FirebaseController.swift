//
//  FirebaseController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 22/4/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var authController: Auth
    var database: Firestore
    var currentUser: FirebaseAuth.User?
    
    var recordsRef: CollectionReference?
    var recordRef: CollectionReference?
    
    var savingRef: CollectionReference?
    var savingsRef: CollectionReference?
    
    var progressRef: CollectionReference?
    var progressesRef: CollectionReference?
    
    var records: Records
    var recordList: [Record]
    
    var savings: Savings
    var savingList: [Saving]
    
    var progresses: Progresses
    var progressList: [Progress]
    
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        recordList = [Record]()
        records = Records()
        
        savingList = [Saving]()
        savings = Savings()
        
        progressList = [Progress]()
        progresses = Progresses()

        super.init()
    }
        
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .record || listener.listenerType == .all {
            listener.onRecordChange(change: .update, records: records.record)
        }
        
        if listener.listenerType == .saving || listener.listenerType == .all {
            listener.onSavingChange(change: .update, saving: savings.saving)
        }
        
        if listener.listenerType == .progress || listener.listenerType == .all {
            listener.onProgressChange(change: .update, progress: progresses.progress)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addProgress(progress: Progress) -> Progress {
        do {
            if let progRef = try progressRef?.addDocument(from: progress) {
                progress.id = progRef.documentID
            }
        } catch {
            print("Failed to serialize progress")
        }
        return progress
    }
    
    func addProgresses(email: String) -> Progresses {
        let progresses = Progresses()
        let progressList = [Progress]()
        if let progsRef = progressesRef?.addDocument(data: ["email": email, "userId": currentUser?.uid, "progress": progressList]) {
            progresses.id = progsRef.documentID
        }
        return progresses
    }
    
    func addProgressIntoProgresses(progress: Progress) -> Bool {
        let newProgress = addProgress(progress: progress)
        guard let progressId = newProgress.id, let progressesId = progresses.id else {
            return false
        }
        if let newProgressRef = progressRef?.document(progressId) {
            progressesRef?.document(progressesId).updateData(["progress": FieldValue.arrayUnion([newProgressRef])])
        }
        return true
    }
    
    func addSaving(saving: Saving) -> Saving {
        do {
            if let saveRef = try savingRef?.addDocument(from: saving) {
                saving.id = saveRef.documentID
            }
        }
        catch {
            print("Failed to serialize saving")
        }
        return saving
    }
    
    func addSavings(email: String) -> Savings {
        let savings = Savings()
        let savinglist = [Saving]()
        if let savingsRef = savingsRef?.addDocument(data: ["email": email, "userId": currentUser?.uid, "saving": savinglist]) {
            savings.id = savingsRef.documentID
        }
        return savings
    }
    
    func addSavingIntoSavings(saving: Saving) -> Bool {
        print(savings.saving.count)
        if savings.saving.count > 0 {
            return false
        }
        let newSaving = addSaving(saving: saving)
        
        guard let savingId = newSaving.id, let savingsId = savings.id else {
            return false
        }
        if let newSavingRef = savingRef?.document(savingId) {
            savingsRef?.document(savingsId).updateData(["saving": FieldValue.arrayUnion([newSavingRef])])
        }
        return true
    }
    
    func addRecord(record: Record) -> Record {
        do{
            if let recordRef = try recordRef?.addDocument(from: record) {
                record.id = recordRef.documentID
            }
        }
        catch{
            print("Failed to serialize recor")
        }
        return record
    }
    
    func addRecords(email: String) -> Records {
        let records = Records()
        let recordlist = [Record]()
        if let recordsRef = recordsRef?.addDocument(data: ["email": email, "userId": currentUser?.uid, "record": recordlist]) {
            records.id = recordsRef.documentID
        }
        return records
    }
    
    func addRecordIntoRecords(record: Record) -> Bool {
        
        let newRecord = addRecord(record: record)

        guard let recordId = newRecord.id, let recordsId = records.id else {
            return false
        }
        
        if let newRecordRef = recordRef?.document(recordId) {
            recordsRef?.document(recordsId).updateData(["record": FieldValue.arrayUnion([newRecordRef])])
        }
        return true
    }
    
    func deleteRecord(record: Record) {
        
        if records.record.contains(record), let recordsId = records.id, let recordId = record.id {
            if let removedRecordRef = recordRef?.document(recordId) {
                recordsRef?.document(recordsId).updateData(["record": FieldValue.arrayRemove([removedRecordRef])])
            }
        }
        
        if let recordId = record.id {
            recordRef?.document(recordId).delete()
        }
        
        let index = records.record.firstIndex(of: record)
        records.record.remove(at: index!)
    }
    
    func deleteSaving(saving: Saving) {
        
        if savings.saving.contains(saving), let savingsId = savings.id, let savingId = saving.id {
            if let removedSavingRef = savingRef?.document(savingId) {
                savingsRef?.document(savingsId).updateData(["saving": FieldValue.arrayUnion([removedSavingRef])])
            }
        }
            
        if let savingId = saving.id {
            savingRef?.document(savingId).delete()
        }
        
        savings.saving = [Saving]()
    }
    
    func deleteProgress(progress: Progress) {
        if progresses.progress.contains(progress), let progressesId = progresses.id, let progressId = progress.id {
            if let removedProgressRef = progressRef?.document(progressId) {
                progressesRef?.document(progressesId).updateData(["progress": FieldValue.arrayUnion([removedProgressRef])])
            }
        }
        if let progressId = progress.id {
            progressRef?.document(progressId).delete()
        }
        progresses.progress = [Progress]()
    }
    
    func getRecordById(_ id: String) -> Record? {
        for record in recordList {
            if record.id == id {
                return record
            }
        }
        return nil
    }
    
    func getSavingById(_ id: String) -> Saving? {
        for saving in savingList {
            if saving.id == id {
                return saving
            }
        }
        return nil
    }
    
    func getProgressById(_ id: String) -> Progress? {
        for progress in progressList {
            if progress.id == id {
                return progress
            }
        }
        return nil
    }
    
    func setupRecordListener(completion: @escaping () -> Void) {
        recordRef = database.collection("record")
        recordRef?.addSnapshotListener() {
            (querySnapshot, error) in guard let querySnapshot = querySnapshot else {
                print("Failed to fetch record documents: \(String(describing: error))")
                return
            }
            self.parseRecordSnapshot(snapshot: querySnapshot)
            completion()
        }
        if self.recordsRef == nil {
            self.setupRecordsListener(completion: completion)
        }
        else {
            completion()
        }
    }
    
    func setupRecordsListener(completion: @escaping () -> Void) {
        recordsRef = database.collection("records")
        recordsRef?.whereField("userId", isEqualTo: currentUser?.uid).addSnapshotListener {
            (querySnapshot, error) in guard let querySnapshot = querySnapshot, let recordsSnapshot = querySnapshot.documents.first else {
                print("Failed to fetch records documents: \(String(describing: error))")
                return
            }
            self.parseRecordsSnapshot(snapshot: recordsSnapshot)
            completion()
        }
    }
    
    func setupSavingListener(completion: @escaping () -> Void) {
        savingRef = database.collection("saving")
        savingRef?.addSnapshotListener() {
            (querySnapshot, error) in guard let querySnapshot = querySnapshot else {
                print("Failed to fetch saving documents: \(String(describing: error))")
                return
            }
            self.parseSavingSnapshot(snapshot: querySnapshot)
        }
        if self.savingsRef == nil {
            self.setupSavingsListener(completion: completion)
        }
        else {
            completion()
        }
    }
    
    func setupSavingsListener(completion: @escaping () -> Void) {
        savingsRef = database.collection("savings")
        savingsRef?.whereField("userId", isEqualTo: currentUser?.uid).addSnapshotListener {
            (querySnapshot, error) in guard let querySnapshot = querySnapshot, let savingsSnapshot = querySnapshot.documents.first else {
                print("Failed to fetch savings documents: \(String(describing: error))")
                return
            }
            self.parseSavingsSnapshot(snapshot: savingsSnapshot)
            completion()
        }
    }
    
    func setupProgressListener(completion: @escaping () -> Void) {
        progressRef = database.collection("progress")
        progressRef?.addSnapshotListener(){
            (querySnapshot, error) in guard let querySnapshot = querySnapshot else {
                print("Failed to fetch progress documents: \(String(describing: error))")
                return
            }
            self.parseProgressSnapshot(snapshot: querySnapshot)
        }
        if self.progressesRef == nil{
            self.setupProgressesListener(completion: completion)
        }
        else {
            completion()
        }
    }
    
    func setupProgressesListener(completion: @escaping () -> Void) {
        progressesRef = database.collection("progresses")
        progressesRef?.whereField("userId", isEqualTo: currentUser?.uid).addSnapshotListener {
            (querySnapshot, error) in guard let querySnapshot = querySnapshot, let progressesSnapshot = querySnapshot.documents.first else {
                print("Failed to fetch progresses documents: \(String(describing: error))")
                return
            }
            self.parseProgressesSnapshot(snapshot: progressesSnapshot)
            completion()
        }
    }
    
    func parseRecordSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach{ (change) in
            var parsedRecord: Record?
            do{
                parsedRecord = try change.document.data(as: Record.self)
            } catch {
                print("unable to decode record")
                return
            }
            
            guard let record = parsedRecord else {
                print("document not exist")
                return
            }
            
            if change.type == .added {
                recordList.insert(record, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                recordList[Int(change.oldIndex)] = record
            }
            else if change.type == .removed {
                recordList.remove(at: Int(change.oldIndex))
            }
        }
        
        listeners.invoke{ (listener) in
            if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                listener.onRecordChange(change: .update, records: records.record)
            }
        }
    }
    
    func parseRecordsSnapshot(snapshot: QueryDocumentSnapshot) {
        records = Records()
        records.id = snapshot.documentID
        
        if let recordReferences = snapshot.data()["record"] as? [DocumentReference] {
            for reference in recordReferences {
                if let record = getRecordById(reference.documentID) {
                    records.record.append(record)
                }
            }
        }
    }
    
    func parseSavingSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach{ (change) in
            var parseSaving: Saving?
            
            do{
                parseSaving = try change.document.data(as: Saving.self)
            }catch {
                print("Unable to decode saving")
                return
            }
            
            guard let saving = parseSaving else {
                print("Document doesn't exist")
                return
            }
            
            if change.type == .added {
                savingList.insert(saving, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                savingList[Int(change.oldIndex)] = saving
            }
            else if change.type == .removed {
                savingList.remove(at: Int(change.oldIndex))
            }
        }
        
        listeners.invoke{ (listener) in
            if listener.listenerType == ListenerType.saving || listener.listenerType == ListenerType.all {
                listener.onSavingChange(change: .update, saving: savings.saving)
            }
        }
    }
    
    func parseSavingsSnapshot(snapshot: QueryDocumentSnapshot) {
        savings = Savings()
        savings.id = snapshot.documentID
        
        if let savingReference = snapshot.data()["saving"] as? [DocumentReference] {
            for reference in savingReference {
                if let saving = getSavingById(reference.documentID) {
                    savings.saving.append(saving)
                }
            }
        }
    }
    
    func parseProgressSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach{ (change) in
            var parseProgress: Progress?
            do {
                parseProgress = try change.document.data(as: Progress.self)
            }catch {
                print("unable to decode progress")
                return
            }
            
            guard let progress = parseProgress else {
                print("document doesn't exist")
                return
            }
            
            if change.type == .added {
                progressList.insert(progress, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                progressList[Int(change.oldIndex)] = progress
            }
            else if change.type == .removed {
                progressList.remove(at: Int(change.oldIndex))
            }
        }
        
        listeners.invoke{ (listener) in
            if listener.listenerType == ListenerType.progress || listener.listenerType == ListenerType.all {
                listener.onProgressChange(change: .update, progress: progresses.progress)
            }
        }
    }
    
    func parseProgressesSnapshot(snapshot: QueryDocumentSnapshot) {
        progresses = Progresses()
        progresses.id = snapshot.documentID
        
        if let progressRef = snapshot.data()["progress"] as? [DocumentReference] {
            for reference in progressRef {
                if let progress = getProgressById(reference.documentID) {
                    progresses.progress.append(progress)
                }
            }
        }
    }
    
    func signup(email: String, password: String) {
        Task {
            do {
                let authDataResult = try await authController.createUser(withEmail: email, password: password)
                currentUser = authDataResult.user
            }
            catch {
                print("Error: \(String(describing: error))")
                //fatalError("Firebase Authentication Failed with Error \(String(describing: error))")
                return
            }
            //  Initialise configuration
            self.setupRecordListener(completion: {})
            self.setupRecordsListener(completion: {})
            self.setupSavingListener(completion: {})
            self.setupSavingsListener(completion: {})
            self.setupProgressListener(completion: {})
            self.setupProgressesListener(completion: {})
            
            //  Add the collections for each data in firebase.
            addRecords(email: (currentUser?.email)!)
            addSavings(email: (currentUser?.email)!)
            addProgresses(email: (currentUser?.email)!)
        }
    }
    
    func signout() {
        do {
            try authController.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
