# Unity Plugin - Agent Instructions

## Key Principles
- Use Unity's built-in features and tools wherever possible
- Structure projects using Unity's component-based architecture for modularity
- Adhere closely to KISS, DRY, YAGNI, SOLID. And clean up after yourself
- Zero Duplication: No duplicate code or files exist in the codebase
- Single Implementation: Each feature has exactly one implementation
- No Fallbacks: No fallback systems that hide or mask errors
- Transparent Errors: All errors are properly displayed to users
- Don't use Resources folder. Try to use Addressables instead.

## Interaction Rules
1. In any mode, don't edit code immediately, show me all changed lines and ask for my confirmation before.
2. In plan mode, act like you're a senior engineer teaching me code. Give me the some explanation about
- The way you think
- What is the pros & cons of this plan
Also give me some short points on which I should focus (to learn) in the plan
3. Please tell me in details if I need to interact with the Unity Editor. For example : create a game object on scene, create a new prefab ...

## Naming Conventions

### Casing
- **PascalCase**: Classes, methods, properties, public fields, enums, namespaces
  - `public class PlayerController`, `public void StartGame()`, `public bool IsGameActive`
- **camelCase**: Local variables, method parameters
  - `int maxHealthPoints`, `void UpdateHealth(int healthValue)`
- **leading underscore camelCase**: private fields
  - `private int _healthPoints`
- **Interfaces**: Start with capital "I" followed by adjective
  - `public interface IMovable`, `public interface IDamageable`

### Variable Naming
- Use **nouns** for variable names: `playerHealth`, `gameScore`, `enemyCount`
- **Boolean variables**: Start with verb (is/has/can/should)
  - `isGameActive`, `hasKey`, `canMove`, `shouldRespawn`
- **Collections**: Use plural nouns
  - `List<Enemy> enemies`, `Enemy[] activeEnemies`
- **Constants**: Use PascalCase with descriptive names
  - `public const int MaxPlayerLives = 3;`

### Method Naming
- Start with **verbs**: `StartGame()`, `UpdateHealth()`, `DestroyEnemy()`
- **Boolean methods**: Ask questions
  - `IsGameOver()`, `HasRequiredItems()`, `CanPlayerMove()`
- **Event handlers**: Use "On" prefix
  - `OnPlayerDeath()`, `OnLevelComplete()`, `OnButtonClick()`

## Code Style
- **Descriptive names**: Avoid abbreviations except in math contexts
- **Consistent access modifiers**: Be explicit about public/protected/private
- **Meaningful comments**: Explain why, not what
- **Single responsibility**: Each class/method should have one clear purpose

## File Organization
- **One MonoBehaviour per file**: File name matches class name
- **Folder structure**: Group by feature/system
  - `Scripts/Player/`, `Scripts/UI/`, `Scripts/Managers/`
- **Namespace usage**: Organize code logically
  - `namespace GameProject.Player { ... }`

## Unity Development Patterns
- **MonoBehaviour**: For GameObject-attached scripts
- **ScriptableObjects**: For data containers and shared resources
- **Singletons**: Try not to use singleton, if the project is using Zenject
- **Component pattern**: Clear separation of concerns and modularity
- **Observer pattern**: Use R3 for object-based events, or Zenject Signals for scene-based or project-based events
- **Dependency Injection**: Try to use DI as much as possible if the project uses Zenject framework

## Performance Best Practices
- **Object pooling**: For frequently instantiated/destroyed objects
- **UniTask**: For time-based operations and async tasks instead of Coroutines or async/await
- **Unity Job System**: For CPU-intensive operations
- **Addressables**: For efficient asset management and loading
- **Profiler-driven optimization**: Use Unity Profiler to identify bottlenecks

## Error Handling & Debugging
- Use Unity's Debug class: `Debug.Log()`, `Debug.LogWarning()`, `Debug.LogError()`
- Implement proper null checks and validation
- Use Unity's assertion system: `Debug.Assert()` for development
- Implement try-catch blocks for external API calls

## Architecture Guidelines
- **MVC/MVP patterns**: For complex UI systems
- **Command pattern**: For undoable actions and input handling
- **State machines**: For game states and AI behaviors
- **Dependency injection**: For testable and maintainable code
- **Event-driven architecture**: For loose coupling between systems

## Memory Management
- Avoid frequent allocations in Update() loops
- Use object pooling for temporary objects
- Dispose of resources properly (implement IDisposable)
- Monitor memory usage with Unity Profiler
- Use struct for small data types to avoid heap allocations

Always refer to Unity's official documentation and follow the project's established patterns and conventions.
