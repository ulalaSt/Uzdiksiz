//
//  GoalSettingPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 21.08.2025.
//

import SwiftUI

import SwiftUI

struct GoalSettingPage: View {
    @ObservedObject var viewModel: GoalViewModel
    
    // Coordinator Callbacks
    var onGoalSelected: ((Goal) -> Void)?
    var onGoalAdded: ((Goal) -> Void)?

    @State private var showingAddGoal = false

    var body: some View {
        List {
            ForEach(viewModel.goals) { goal in
                Button(action: {
                    onGoalSelected?(goal)
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(goal.title).font(.headline)
                            if let category = goal.category {
                                Text(category).font(.subheadline).foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(goal.isCompleted ? .green : .gray)
                    }
                }
            }
        }
        .navigationTitle("Goals")
        .toolbar {
            Button(action: { showingAddGoal = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalPage { newGoal in
                viewModel.addGoal(newGoal)
                onGoalAdded?(newGoal)
            }
        }
    }
}

struct AddGoalPage: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (Goal) -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var targetValue = ""
    @State private var category = ""
    @State private var deadline = Date()
    @State private var isAchievable = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Target Value", text: $targetValue).keyboardType(.decimalPad)
                    TextField("Category", text: $category)
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    Toggle("Achievable", isOn: $isAchievable)
                }
            }
            .navigationTitle("Add Goal")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let goal = Goal(
                            title: title,
                            description: description.isEmpty ? nil : description,
                            targetValue: Double(targetValue),
                            currentValue: 0,
                            isAchievable: isAchievable,
                            category: category.isEmpty ? nil : category,
                            deadline: deadline,
                            createdAt: Date(),
                            completedAt: nil,
                            isCompleted: false
                        )
                        onSave(goal)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct SubGoalFormPage: View {
    @Environment(\.dismiss) var dismiss
    @State var title: String = ""
    @State var description: String = ""
    @State var targetValue: String = ""
    @State var deadline: Date = Date()
    @State var isAchievable: Bool = true
    var category: String?

    var onSave: ((Goal) -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sub-Goal Info")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Target Value", text: $targetValue)
                        .keyboardType(.decimalPad)
                    Toggle("Achievable", isOn: $isAchievable)
                    if let category = category {
                        Text("Category: \(category)")
                    }
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Sub-Goal")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    let goal = Goal(
                        title: title,
                        description: description.isEmpty ? nil : description,
                        targetValue: Double(targetValue),
                        currentValue: 0,
                        isAchievable: isAchievable,
                        category: category,
                        deadline: deadline,
                        createdAt: Date(),
                        completedAt: nil,
                        isCompleted: false,
                        parentId: nil
                    )
                    onSave?(goal)
                    dismiss()
                }
            )
        }
    }
}

struct GoalDetailPage: View {
    @State var goal: Goal
    @ObservedObject var viewModel: GoalViewModel
    var onSubGoalTap: (Goal) -> Void
    @State private var showingAddSubGoal = false

    var body: some View {
        ScrollView {
            VStack {
                Text(goal.title)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                if let description = goal.description {
                    Text(description)
                        .font(.body)
                        .padding()
                }

                if let category = goal.category {
                    HStack {
                        Text("Category:").bold()
                        Text(category)
                    }
                }

                if let target = goal.targetValue {
                    VStack {
                        Text("Progress: \(Int(goal.currentValue))/\(Int(target))")
                        Slider(
                            value: $goal.currentValue,
                            in: 0...target,
                            step: 1
                        )
                        .accentColor(.blue)
                        .padding()
                    }
                }

                if let deadline = goal.deadline {
                    HStack {
                        Text("Deadline:").bold()
                        Text(deadline, style: .date)
                    }
                }

                HStack {
                    Text("Achievable:").bold()
                    Text(goal.isAchievable ? "Yes" : "No")
                }

                HStack {
                    Text("Status:").bold()
                    Text(goal.isCompleted ? "Completed" : "In Progress")
                }

                Spacer()

                Button(action: {
                    goal.isCompleted.toggle()
                    goal.completedAt = goal.isCompleted ? Date() : nil
                    viewModel.toggleCompletion(goal)
                }) {
                    Text(goal.isCompleted ? "Mark as Incomplete" : "Mark as Completed")
                        .foregroundColor(.white)
                        .padding()
                        .background(goal.isCompleted ? Color.orange : Color.green)
                        .cornerRadius(10)
                }

                // Save progress button
                Button(action: {
                    viewModel.updateProgress(goal)
                }) {
                    Text("Save Progress")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }


                Divider()
                HStack {
                    Text("Sub-Goals").font(.headline)
                    Spacer()
                    Button(action: {
                        showingAddSubGoal = true
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.title)
                    }
                }
                .padding()

                LazyVStack(spacing: 8) {
                    ForEach(viewModel.subGoals) { subGoal in
                        HStack {
                            Text(subGoal.title)
                            Spacer()
                            if subGoal.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSubGoalTap(subGoal)
                        }
                        .padding(.horizontal)
                    }
                }
            }

        }
        .onAppear {
            viewModel.fetchSubGoals(for: goal)
        }
        .sheet(isPresented: $showingAddSubGoal) {
            SubGoalFormPage(category: goal.category) { subGoal in
                var newSubGoal = subGoal
                newSubGoal.parentId = goal.id
                viewModel.addSubGoal(newSubGoal, to: goal)
                viewModel.fetchSubGoals(for: goal)
            }
        }
        .padding()
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)

    }
}
