import XCTest

let app = XCUIApplication()

class SimplenoteUISmokeTestsLogin: XCTestCase {

    let testDataInvalidEmail = "user@gmail."
    let testDataNotExistingEmail = "nevergonnagiveyouup@gmail.com"
    let testDataInvalidPassword = "ABC"
    let testDataNotExistingPassword = "ABCD"

    override class func setUp() {
        app.launch()
    }

    override func setUpWithError() throws {
        continueAfterFailure = true
        Alert.closeAny()
        EmailLogin.close()
        let _ = attemptLogOut()
    }

    func testLogInWithNoEmailNoPassword() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: "", password: "")

        Assert.labelExists(labelText: Text.LoginEmailInvalid)
        Assert.labelExists(labelText: Text.LoginPasswordShort)
    }

    func testLogInWithNoEmail() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: "", password: testDataExistingPassword)

        Assert.labelExists(labelText: Text.LoginEmailInvalid)
        Assert.labelAbsent(labelText: Text.LoginPasswordShort)
    }

    func testLogInWithInvalidEmail() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: testDataInvalidEmail, password: testDataExistingPassword)

        Assert.labelExists(labelText: Text.LoginEmailInvalid)
        Assert.labelAbsent(labelText: Text.LoginPasswordShort)
    }

    func testLogInWithNoPassword() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: "")

        Assert.labelAbsent(labelText: Text.LoginEmailInvalid)
        Assert.labelExists(labelText: Text.LoginPasswordShort)
    }

    func testLogInWithTooShortPassword() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataInvalidPassword)

        Assert.labelAbsent(labelText: Text.LoginEmailInvalid)
        Assert.labelExists(labelText: Text.LoginPasswordShort)
    }

    func testLogInWithExistingEmailIncorrectPassword() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataNotExistingPassword)
        Assert.alertExistsAndClose(headingText: Text.AlertHeadingSorry, content: Text.AlertContentLoginFailed, buttonText: UID.Button.Accept)
    }

    func testLogInWithCorrectCredentials() throws {
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        AllNotesAssert.screenShown()
    }

    func testLogOut() throws {
        // Step 1
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        AllNotesAssert.screenShown()

        // Step 2
        _ = logOut()
        Assert.signUpLogInScreenShown()
    }
}

class SimplenoteUISmokeTestsNoteEditor: XCTestCase {

    let usualLinkText = "https://simplenote.com/"
    let complexLinkPreviewText = "Simplenote"
    let complexLinkRawText = "[Simplenote](https://simplenote.com/)"
    let webViewTexts = [String](
        arrayLiteral: "Simplenote",
        "The simplest way to keep notes",
        "All your notes, synced on all your devices. Get Simplenote now for iOS, Android, Mac, Windows, Linux, or in your browser.",
        "Sign up now")

    override class func setUp() {
        app.launch()
        getToAllNotes()
        let _ = attemptLogOut()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        AllNotes.waitForLoad()
    }

    override func setUpWithError() throws {
        continueAfterFailure = true
        getToAllNotes()
        AllNotes.clearAllNotes()
        Trash.empty()
        AllNotes.open()
    }

    func testCanPreviewMarkdownBySwiping() throws {

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: complexLinkRawText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: complexLinkRawText)

        // Step 3
        NoteEditor.swipeToPreview()
        PreviewAssert.previewShown()
        PreviewAssert.staticTextWithExactValueShownOnce(value: complexLinkPreviewText)
        //PreviewAssert.wholeTextShown(text: complexLinkPreviewText)
    }

    func testCanFlipToEditMode() throws {

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: complexLinkRawText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: complexLinkRawText)

        // Step 3
        NoteEditor.swipeToPreview()
        PreviewAssert.previewShown()
        PreviewAssert.staticTextWithExactValueShownOnce(value: complexLinkPreviewText)
        //PreviewAssert.wholeTextShown(text: complexLinkPreviewText)

        // Step 4
        Preview.leavePreviewViaBackButton()
        NoteEditor.setFocus()
        NoteEditorAssert.editorShown()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: complexLinkRawText)
    }

    func testUsingInsertChecklistInsertsChecklist() throws {
        let noteTextInitial = "Inserting checkbox with a button",
            noteNameInitial = noteTextInitial,
            noteTextWithCheckbox = " " + noteTextInitial,
            noteNameWithCheckbox = "- [ ]" + noteTextWithCheckbox

        trackTest()

        trackStep()
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: noteTextInitial)
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: noteNameInitial)

        trackStep()
        AllNotes.openNote(noteName: noteNameInitial)
        NoteEditor.markdownEnable()
        NoteEditorAssert.textViewWithExactValueShownOnce(value: noteTextInitial)

        trackStep()
        NoteEditor.swipeToPreview()
        PreviewAssert.staticTextWithExactValueShownOnce(value: noteTextInitial)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 0, expectedEmptyBoxesNumber: 0)

        trackStep()
        Preview.leavePreviewViaBackButton()
        NoteEditor.setFocus()
        NoteEditor.insertChecklist()
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: noteNameWithCheckbox)
        AllNotesAssert.noteAbsent(noteName: noteNameInitial)

        trackStep()
        AllNotes.openNote(noteName: noteNameWithCheckbox)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: noteTextWithCheckbox)

        trackStep()
        NoteEditor.swipeToPreview()
        PreviewAssert.staticTextWithExactValueShownOnce(value: noteNameInitial)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 0, expectedEmptyBoxesNumber: 1)
    }

	func testUndoUndoesTheLastEdit() throws {
		let editorText = "ABCD"

		// Step 1
		AllNotes.addNoteTap()
		NoteEditorAssert.editorShown()

		// Step 2
		NoteEditor.clearAndEnterText(enteredValue: editorText)
		NoteEditorAssert.textViewWithExactValueShownOnce(value: editorText)

		// Step 3
		NoteEditor.undo()
		NoteEditorAssert.textViewWithExactValueNotShown(value: editorText)
		NoteEditorAssert.textViewWithExactValueShownOnce(value: "ABC")
	}

	func testAddedURLIsLinkified() throws {

		// Step 1
		AllNotes.addNoteTap()
		NoteEditorAssert.editorShown()

		// Step 2
		NoteEditor.markdownEnable()
		NoteEditor.clearAndEnterText(enteredValue: usualLinkText)
		NoteEditorAssert.textViewWithExactValueShownOnce(value: usualLinkText)

		// Step 3
		NoteEditor.leaveEditor()
		AllNotesAssert.noteExists(noteName: usualLinkText)

		// Step 4
		AllNotes.openNote(noteName: usualLinkText)
		NoteEditorAssert.linkifiedURL(containerText: usualLinkText, linkifiedText: usualLinkText)
	}

	func testLongTappingOnLinkOpensLinkInNewWindow() throws {

		// Step 1
		AllNotes.addNoteTap()
		NoteEditorAssert.editorShown()

		// Step 2
		NoteEditor.markdownEnable()
		NoteEditor.clearAndEnterText(enteredValue: usualLinkText)
		NoteEditorAssert.textViewWithExactValueShownOnce(value: usualLinkText)

		// Step 3
		NoteEditor.leaveEditor()
		AllNotesAssert.noteExists(noteName: usualLinkText)

		// Step 4
		AllNotes.openNote(noteName: usualLinkText)
		//NoteEditorAssert.editorText(text: usualURL)
		NoteEditorAssert.linkifiedURL(containerText: usualLinkText, linkifiedText: usualLinkText)

		// Step 5
		NoteEditor.pressLink(containerText: usualLinkText, linkifiedText: usualLinkText)
		for text in webViewTexts {
			WebViewAssert.textShownOnScreen(textToFind: text)
		}
	}

    func testTappingOnLinkInPreviewOpensLinkInNewWindow() throws {

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: usualLinkText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: usualLinkText)

        // Step 3
        NoteEditor.swipeToPreview()
        PreviewAssert.linkShown(linkText: usualLinkText)

        // Step 4
        Preview.tapLink(linkText: usualLinkText)
        for text in webViewTexts {
            WebViewAssert.textShownOnScreen(textToFind: text)
        }
    }

    func testCreateCheckedItem() throws {
        let checklistText = "Checked Item"
        let completeText = "- [x]" + checklistText

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: completeText)

        // Step 3
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: completeText)

        // Step 4
        AllNotes.openNote(noteName: completeText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: checklistText)
        NoteEditorAssert.checkboxForTextShownOnce(text: checklistText)

        // Step 5
        NoteEditor.swipeToPreview()
        //PreviewAssert.substringShown(text: checklistText)
        PreviewAssert.staticTextWithExactLabelShownOnce(label: checklistText)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 1, expectedEmptyBoxesNumber: 0)
    }

    func testCreateUncheckedItem() throws {
		let checklistText = "Unchecked Item"
        let completeText = "- [ ]" + checklistText

        // Step 1
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        // Step 2
        NoteEditor.markdownEnable()
        NoteEditor.clearAndEnterText(enteredValue: completeText)

        // Step 3
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: completeText)

        // Step 4
        AllNotes.openNote(noteName: completeText)
        NoteEditorAssert.textViewWithExactValueShownOnce(value: checklistText)
        NoteEditorAssert.checkboxForTextShownOnce(text: checklistText)

        // Step 5
        NoteEditor.swipeToPreview()
        //PreviewAssert.substringShown(text: checklistText)
        PreviewAssert.staticTextWithExactLabelShownOnce(label: checklistText)
        PreviewAssert.boxesStates(expectedCheckedBoxesNumber: 0, expectedEmptyBoxesNumber: 1)
    }

    func testBulletedLists() throws {
        let noteTitle = "Bulleted Lists"
        let noteContent = "\n\nMinuses:\n\n- Minus1\nMinus2\nMinus3" +
            "\n\nPluses:\n\n+ Plus1\nPlus2\nPlus3" +
            "\n\nAsterisks:\n\n* Asterisk1\nAsterisk2\nAsterisk3"

        trackTest()

        trackStep()
        AllNotes.addNoteTap()
        NoteEditorAssert.editorShown()

        trackStep()
        NoteEditor.clearAndEnterText(enteredValue: noteTitle + noteContent)
        NoteEditor.leaveEditor()
        AllNotesAssert.noteExists(noteName: noteTitle)

        trackStep()
        AllNotes.openNote(noteName: noteTitle)
        NoteEditorAssert.textViewWithExactLabelsShownOnce(labels: ["- Minus1", "- Minus2", "- Minus3"])
        NoteEditorAssert.textViewWithExactLabelsShownOnce(labels: ["+ Plus1", "+ Plus2", "+ Plus3"])
        NoteEditorAssert.textViewWithExactLabelsShownOnce(labels: ["* Asterisk1", "* Asterisk2", "* Asterisk3"])

        trackStep()
        NoteEditor.markdownEnable()
        NoteEditor.swipeToPreview()
        PreviewAssert.staticTextWithExactValuesShownOnce(values: ["• Minus1", "• Minus2", "• Minus3"])
        PreviewAssert.staticTextWithExactValuesShownOnce(values: ["• Plus1", "• Plus2", "• Plus3"])
        PreviewAssert.staticTextWithExactValuesShownOnce(values: ["• Asterisk1", "• Asterisk2", "• Asterisk3"])
    }
}

class SimplenoteUISmokeTestsTrash: XCTestCase {

    override class func setUp() {
        app.launch()
        let _ = attemptLogOut()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        AllNotes.waitForLoad()
    }

    override func setUpWithError() throws {
        continueAfterFailure = true
        AllNotes.clearAllNotes()
        Trash.empty()
        AllNotes.open()
    }

    func testCanViewTrashedNotes() throws {
        let noteOneName = "CanView"
        let noteTwoName = "Trashed"
        let noteThreeName = "Notes"
        let noteNamesArray = [noteOneName, noteTwoName, noteThreeName]

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        AllNotes.open()
        AllNotes.createNotes(names: noteNamesArray)
        AllNotesAssert.notesExist(names: noteNamesArray)
        AllNotesAssert.notesNumber(expectedNotesNumber: 3)

        // Step 3
        AllNotes.trashNote(noteName: noteOneName)
        AllNotesAssert.noteAbsent(noteName: noteOneName)
        AllNotesAssert.noteExists(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 2)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteOneName)
        TrashAssert.notesNumber(expectedNotesNumber: 1)
    }

    func testCanDeleteNoteForeverIndividually() throws {
        let noteOneName = "CanDelete"
        let noteTwoName = "Note"
        let noteThreeName = "Forever"
        let noteNamesArray = [noteOneName, noteTwoName, noteThreeName]

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        AllNotes.open()
        AllNotes.createNotes(names: noteNamesArray)
        AllNotesAssert.notesExist(names: noteNamesArray)
        AllNotesAssert.notesNumber(expectedNotesNumber: 3)

		// Step 3
		AllNotes.trashNote(noteName: noteOneName)
		AllNotes.trashNote(noteName: noteTwoName)
		AllNotesAssert.noteAbsent(noteName: noteOneName)
		AllNotesAssert.noteAbsent(noteName: noteTwoName)
		AllNotesAssert.noteExists(noteName: noteThreeName)
		AllNotesAssert.notesNumber(expectedNotesNumber: 1)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteOneName)
        TrashAssert.noteExists(noteName: noteTwoName)
        TrashAssert.notesNumber(expectedNotesNumber: 2)

        //Step 5
        Trash.deleteNote(noteName: noteOneName)
        TrashAssert.noteAbsent(noteName: noteOneName)
        TrashAssert.noteExists(noteName: noteTwoName)
        TrashAssert.notesNumber(expectedNotesNumber: 1)

        // Step 6
        AllNotes.open()
        AllNotesAssert.noteAbsent(noteName: noteOneName)
        AllNotesAssert.noteAbsent(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 1)
    }

    func testCanDeleteNotesForeverViaEmpty() throws {
        let noteOneName = "CanDelete"
        let noteTwoName = "Note"
        let noteThreeName = "Forever"
        let noteNamesArray = [noteOneName, noteTwoName, noteThreeName]

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        AllNotes.open()
        AllNotes.createNotes(names: noteNamesArray)
        AllNotesAssert.notesExist(names: noteNamesArray)
        AllNotesAssert.notesNumber(expectedNotesNumber: 3)

        // Step 3
        AllNotes.trashNote(noteName: noteOneName)
        AllNotes.trashNote(noteName: noteTwoName)
        AllNotesAssert.noteAbsent(noteName: noteOneName)
        AllNotesAssert.noteAbsent(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 1)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteOneName)
        TrashAssert.noteExists(noteName: noteTwoName)
        TrashAssert.notesNumber(expectedNotesNumber: 2)

        //Step 5
        Trash.empty()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 6
        AllNotes.open()
        AllNotesAssert.noteAbsent(noteName: noteOneName)
        AllNotesAssert.noteAbsent(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 1)
    }

    func testCanRestoreNote() throws {
        let noteOneName = "CanRestore"
        let noteTwoName = "Trashed"
        let noteThreeName = "Notes"
        let noteNamesArray = [noteOneName, noteTwoName, noteThreeName]

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        AllNotes.open()
        AllNotes.createNotes(names: noteNamesArray)
        AllNotesAssert.notesExist(names: noteNamesArray)
        AllNotesAssert.notesNumber(expectedNotesNumber: 3)

        // Step 3
        AllNotes.trashNote(noteName: noteOneName)
        AllNotesAssert.noteAbsent(noteName: noteOneName)
        AllNotesAssert.noteExists(noteName: noteTwoName)
        AllNotesAssert.noteExists(noteName: noteThreeName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 2)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteOneName)
        TrashAssert.notesNumber(expectedNotesNumber: 1)

        //Step 5
        Trash.restoreNote(noteName: noteOneName)
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        //Step 6
        AllNotes.open()
        AllNotesAssert.notesExist(names: noteNamesArray)
        AllNotesAssert.notesNumber(expectedNotesNumber: 3)
    }

    func testCanTrashNote() throws {
        let noteName = "can trash note"

        // Step 1
        Trash.open()
        TrashAssert.notesNumber(expectedNotesNumber: 0)

        // Step 2
        AllNotes.open()
        AllNotes.createNoteAndLeaveEditor(noteName: noteName)
        AllNotesAssert.noteExists(noteName: noteName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 1)

        // Step 3
        AllNotes.trashNote(noteName: noteName)
        AllNotesAssert.noteAbsent(noteName: noteName)
        AllNotesAssert.notesNumber(expectedNotesNumber: 0)

        //Step 4
        Trash.open()
        TrashAssert.noteExists(noteName: noteName)
        TrashAssert.notesNumber(expectedNotesNumber: 1)
    }
}
