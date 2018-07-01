import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var password: String
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        
        init(id: UUID?, name: String, username: String) {
            self.id = id
            self.name = name
            self.username = username
        }
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Content {}

extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        // Create the User table
        return Database.create(self, on: connection) { builder in
            // Add all columns to the User table using the User's properties
            try addProperties(to: builder)
            // Add an unique index to username on User
            try builder.addIndex(to: \.username, isUnique: true)
        }
    }
}

extension User: Parameter {}
extension User.Public: Content {}

extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

// Create Admin User
struct AdminUser: Migration {
    typealias Database = PostgreSQLDatabase

    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        // Note: Obviously, in a production system, you shouldn’t use password as the password for your admin user! You also don’t want to hardcode the password in case it ends up in source control. You can either read an environment variable or generate a random password and print it out.
        let password = try? BCrypt.hash("password")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(
        name: "Admin",
        username: "admin",
        password: hashedPassword)

        return user.save(on: connection).transform(to: ())
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
            return .done(on: connection)
    }
}

extension User: PasswordAuthenticatable {}
extension User: SessionAuthenticatable {}
