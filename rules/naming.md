# Casing Conventions
- **PascalCase**: Classes, methods, properties, public fields, enums, namespaces
 - `public class PlayerController`, `public void StartGame()`, `public bool IsGameActive`
- **camelCase**: Local variables, method parameters
 - `int maxHealthPoints`, `void UpdateHealth(int healthValue)`
- **leading underscore camelCase**: private fields
 - `private int _healthPoints`
- **Interfaces**: Start with capital "I" followed by adjective
 - `public interface IMovable`, `public interface IDamageable`

# Variable Naming Guidelines
- Use **nouns** for variable names: `playerHealth`, `gameScore`, `enemyCount`
- **Boolean variables**: Start with verb (is/has/can/should)
 - `isGameActive`, `hasKey`, `canMove`, `shouldRespawn`
- **Collections**: Use plural nouns
 - `List<Enemy> enemies`, `Enemy[] activeEnemies`
- **Constants**: Use PascalCase with descriptive names
 - `public const int MaxPlayerLives = 3;`

# Method Naming Guidelines
- Start with **verbs**: `StartGame()`, `UpdateHealth()`, `DestroyEnemy()`
- **Boolean methods**: Ask questions
 - `IsGameOver()`, `HasRequiredItems()`, `CanPlayerMove()`
- **Event handlers**: Use "On" prefix
 - `OnPlayerDeath()`, `OnLevelComplete()`, `OnButtonClick()`