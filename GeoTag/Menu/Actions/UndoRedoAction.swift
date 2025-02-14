//
// Copyright 2023 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import Foundation

// macOS 14.3 and later: undo and redo disabled checks are only done when the
// the app is launched.  As a result undo/redu are always disabled.  Comment
// the reuturn of the real value and return false (never disabled).  Live
// with menu item titles that do not change

extension AppState {

    // return true if the undo menu option should be disabled.

    var undoDisabled: Bool {
        Self.logger.notice(
            """
            canUndo: \(self.undoManager.canUndo, privacy: .public), \
            \(self.undoManager.levelsOfUndo, privacy: .public) levels
            """)
        return false  // !undoManager.canUndo
    }

    // return true if the redo menu option should be disabled.

    var redoDisabled: Bool {
        Self.logger.notice("canRedo: \(self.undoManager.canRedo, privacy: .public)")
        return false  // !undoManager.canRedo
    }

    func undoAction() {
        if undoManager.canUndo {
            undoManager.undo()
        }
    }

    func redoAction() {
        if undoManager.canRedo {
            undoManager.redo()
        }
    }
}
