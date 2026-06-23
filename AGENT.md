Use Feature-First Clean Architecture.

Structure:

lib/
├── core/
├── shared/
├── features/
│ └── feature_name/
│ ├── data/
│ ├── domain/
│ └── presentation/

Keep business logic outside widgets.

Coding Standards
Follow SOLID principles
Prefer composition over inheritance
One responsibility per class
Reuse existing components before creating new ones
Write clean, maintainable, and scalable code
Naming
Files: snake_case
Classes: PascalCase
Variables: camelCase
Constants: lowerCamelCase

Examples:

user_model.dart
UserModel
userName
apiBaseUrl

State Management
Use GetX