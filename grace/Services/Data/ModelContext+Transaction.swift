import SwiftData

extension ModelContext {
  /// Runs a SwiftData transaction and rolls back every pending change if it fails.
  func performTransactionOrRollback(_ changes: () throws -> Void) throws {
    try Self.performTransactionOrRollback(
      transaction: { try transaction(block: changes) },
      rollback: { rollback() }
    )
  }

  /// Runs a transaction operation and invokes its matching rollback on failure.
  nonisolated static func performTransactionOrRollback(
    transaction: () throws -> Void,
    rollback: () -> Void
  ) throws {
    do {
      try transaction()
    } catch {
      rollback()
      throw error
    }
  }
}
