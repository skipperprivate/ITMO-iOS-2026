import UIKit
import SwiftData

class ViewController: UIViewController {

    let modelContext: ModelContext
    
    let textField = UITextField()
    let addButton = UIButton(type: .system)
    let tableView = UITableView()
    let nameField = UITextField()

    var notes: [Note] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6
        title = "Notes"
        
        setupNameField()
        setupTextField()
        setupAddButton()
        setupTableView()
        
        loadUsername()
        loadNotes()
    }
    
    func setupNameField() {
        nameField.placeholder = "Enter username"
        nameField.borderStyle = .roundedRect

        nameField.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nameField)

        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),

            nameField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),

            nameField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            )
        ])

        nameField.addTarget(
            self,
            action: #selector(saveUsername),
            for: .editingChanged
        )
    }
    
    func setupTextField() {
        textField.placeholder = "Enter note"
        textField.borderStyle = .roundedRect

        textField.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(textField)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(
                equalTo: nameField.bottomAnchor,
                constant: 20
            ),

            textField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),

            textField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            )
        ])
    }
    
    func setupAddButton() {
        addButton.setTitle("Add", for: .normal)

        addButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(addButton)

        addButton.addTarget(
            self,
            action: #selector(addNote),
            for: .touchUpInside
        )

        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(
                equalTo: textField.bottomAnchor,
                constant: 20
            ),

            addButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])
    }
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: addButton.bottomAnchor,
                constant: 20
            ),

            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }
    
    func loadNotes() {
        let descriptor = FetchDescriptor<Note>()

        do {
            notes = try modelContext.fetch(descriptor)
            tableView.reloadData()
        } catch {
            print("Ошибка загрузки заметок")
        }
    }
    
    func loadUsername() {
        nameField.text = UserDefaults.standard.string(
            forKey: "username"
        )
    }
    
    @objc func addNote() {
        guard let text = textField.text,
              !text.isEmpty else {
            return
        }

        let note = Note(text: text)

        modelContext.insert(note)

        try? modelContext.save()

        textField.text = ""
        
        loadNotes()
    }
    
    @objc func saveUsername() {
        UserDefaults.standard.set(
            nameField.text,
            forKey: "username"
        )
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return notes.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = UITableViewCell(
            style: .default,
            reuseIdentifier: nil
        )

        let note = notes[indexPath.row]

        cell.textLabel?.text = note.text

        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {

        if editingStyle == .delete {

            let note = notes[indexPath.row]

            modelContext.delete(note)

            try? modelContext.save()

            loadNotes()
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(
                at: indexPath,
                animated: true
            )
        let note = notes[indexPath.row]

        let alert = UIAlertController(
            title: "Edit note",
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.text = note.text
        }

        let saveAction = UIAlertAction(
            title: "Save",
            style: .default
        ) { _ in

            guard let newText = alert.textFields?.first?.text,
                  !newText.isEmpty else {
                return
            }

            note.text = newText

            try? self.modelContext.save()

            self.loadNotes()
        }

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
