//
//  GoalSettingViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 21.08.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

import Foundation
import Firebase

class GoalViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var subGoals: [Goal] = []

    private var db = Firestore.firestore()
    private var uid: String

    init() {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            fatalError("No logged-in user found. GoalViewModel requires a user.")
        }
        self.uid = currentUID

        fetchGoals()
    }

    // MARK: - Parent Goals
    func fetchGoals() {
        db.collection("users")
            .document(uid)
            .collection("goals")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No goals found: \(error?.localizedDescription ?? "")")
                    return
                }
                self.goals = documents.compactMap { try? $0.data(as: Goal.self) }
            }
    }

    func addGoal(_ goal: Goal) {
        do {
            _ = try db.collection("users")
                .document(uid)
                .collection("goals")
                .addDocument(from: goal)
        } catch {
            print("Error adding goal: \(error.localizedDescription)")
        }
    }

    func toggleCompletion(_ goal: Goal) {
        guard let id = goal.id else { return }
        db.collection("users")
            .document(uid)
            .collection("goals")
            .document(id)
            .updateData([
                "isCompleted": !goal.isCompleted,
                "completedAt": goal.isCompleted ? nil : Date()
            ])
    }

    func updateProgress(_ goal: Goal) {
        guard let id = goal.id else { return }
        db.collection("users")
            .document(uid)
            .collection("goals")
            .document(id)
            .updateData([
                "currentValue": goal.currentValue
            ])
    }

    // MARK: - Sub-Goals
    func fetchSubGoals(for parentGoal: Goal) {
        guard let parentId = parentGoal.id else { return }
        db.collection("users")
            .document(uid)
            .collection("goals")
            .document(parentId)
            .collection("subgoals")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No sub-goals found: \(error?.localizedDescription ?? "")")
                    return
                }
                self.subGoals = documents.compactMap { try? $0.data(as: Goal.self) }
            }
    }

    func addSubGoal(_ subGoal: Goal, to parentGoal: Goal) {
        guard let parentId = parentGoal.id else { return }
        do {
            _ = try db.collection("users")
                .document(uid)
                .collection("goals")
                .document(parentId)
                .collection("subgoals")
                .addDocument(from: subGoal)
        } catch {
            print("Error adding sub-goal: \(error.localizedDescription)")
        }
    }

    func toggleSubGoalCompletion(_ subGoal: Goal, parentGoal: Goal) {
        guard let parentId = parentGoal.id, let subGoalId = subGoal.id else { return }
        db.collection("users")
            .document(uid)
            .collection("goals")
            .document(parentId)
            .collection("subgoals")
            .document(subGoalId)
            .updateData([
                "isCompleted": !subGoal.isCompleted,
                "completedAt": subGoal.isCompleted ? nil : Date()
            ])
    }

    func updateSubGoalProgress(_ subGoal: Goal, parentGoal: Goal) {
        guard let parentId = parentGoal.id, let subGoalId = subGoal.id else { return }
        db.collection("users")
            .document(uid)
            .collection("goals")
            .document(parentId)
            .collection("subgoals")
            .document(subGoalId)
            .updateData([
                "currentValue": subGoal.currentValue
            ])
    }
}

struct Goal: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String?
    var targetValue: Double?
    var currentValue: Double
    var isAchievable: Bool
    var category: String?
    var deadline: Date?
    var createdAt: Date
    var completedAt: Date?
    var isCompleted: Bool
    var parentId: String?
}
