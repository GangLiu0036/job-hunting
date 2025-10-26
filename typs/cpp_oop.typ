#import "@preview/cetz:0.4.0"
#import "@preview/equate:0.3.2": equate
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/hydra:0.6.1": hydra

#set page(paper: "a4", margin: (y: 4em), numbering: "1", header: context {
  align(right, emph(hydra(2)))
  line(length: 100%)
})

#set heading(numbering: "1.1")
#show heading.where(level: 1): it => pagebreak(weak: true) + it

#show: equate.with(breakable: true, sub-numbering: true)
#set math.equation(numbering: "(1-1)")
#set text(
  size: 10pt)

  
#show: codly-init.with()
#codly(languages: codly-languages)

// 封面页
#align(center + horizon)[
  #block(
    width: 100%,
    inset: 2em,
    [
      #text(size: 42pt, weight: "bold")[
        C++ 面向对象编程
      ]
      
      #v(1em)
      
      #text(size: 18pt)[
        从三大特性到设计模式
      ]
      
      #v(3em)
      
      #line(length: 60%, stroke: 2pt + rgb("#333333"))
      
      #v(3em)
      
      #text(size: 14pt)[
        *核心内容*
      ]
      
      #v(1em)
      
      #grid(
        columns: 1,
        row-gutter: 0.8em,
        align(left)[
          #text(size: 12pt)[
            • 封装：数据隐藏与访问控制 \
            • 继承：代码复用与类层次设计 \
            • 多态：虚函数与动态绑定 \
            • 构造与析构机制 \
            • 抽象类与接口设计 \
            • 组合 vs 继承 \
            • 面向对象设计原则 \
            • 实战：游戏开发场景应用
          ]
        ]
      )
      
      #v(4em)
      
      #line(length: 60%, stroke: 2pt + rgb("#333333"))
      
      #v(2em)
      
      #text(size: 12pt, style: "italic")[
        理论与实践 · 设计思想 · 场景应用
      ]
      
      #v(2em)
      
      #text(size: 11pt)[
        *作者*：Aweo
      ]
      
      #v(1em)
      
      #text(size: 11pt)[
        #datetime.today().display("[year]年[month]月")
      ]
    ]
  )
]

#pagebreak()

#outline()

#pagebreak()

= C++ 面向对象编程

C++的三大特性：*封装*、*继承*、*多态*，是面向对象编程的核心。

== 封装（Encapsulation）

=== 什么是封装？

*定义*：将数据和操作数据的方法绑定在一起，隐藏对象的内部实现细节，只暴露必要的接口。

*核心目的*：
1. 数据保护：防止外部直接访问和修改内部数据
2. 降低耦合：外部代码不依赖内部实现
3. 提高可维护性：修改内部实现不影响外部代码

=== 访问控制

```cpp
class Player {
private:
    // 私有成员：只能在类内部访问
    int health;
    int maxHealth;
    float posX, posY;
    
protected:
    // 保护成员：类内部和派生类可访问
    int level;
    float experience;
    
public:
    // 公有成员：任何地方都可访问
    Player(int maxHp) : health(maxHp), maxHealth(maxHp), 
                        posX(0), posY(0), level(1), experience(0) {}
    
    // 公有接口：提供安全的数据访问
    int getHealth() const { return health; }
    
    void takeDamage(int damage) {
        health -= damage;
        if (health < 0) health = 0;  // 确保健康值不为负
    }
    
    void heal(int amount) {
        health += amount;
        if (health > maxHealth) health = maxHealth;  // 不超过最大值
    }
    
    void moveTo(float x, float y) {
        posX = x;
        posY = y;
    }
    
    void getPosition(float& x, float& y) const {
        x = posX;
        y = posY;
    }
};

// 使用
Player player(100);
// player.health = -50;  // ✗ 错误！health是私有的
player.takeDamage(30);   // ✓ 通过公有接口安全地修改
std::cout << player.getHealth();  // 70
```

=== 游戏场景：物品系统

```cpp
// 物品基类
class Item {
private:
    int itemId;
    std::string name;
    int stackSize;      // 当前堆叠数量
    int maxStackSize;   // 最大堆叠数量
    
public:
    Item(int id, const std::string& name, int maxStack = 1)
        : itemId(id), name(name), stackSize(1), maxStackSize(maxStack) {}
    
    // 尝试添加物品到堆叠
    bool addToStack(int amount) {
        if (stackSize + amount <= maxStackSize) {
            stackSize += amount;
            return true;
        }
        return false;
    }
    
    // 从堆叠中移除
    bool removeFromStack(int amount) {
        if (stackSize >= amount) {
            stackSize -= amount;
            return true;
        }
        return false;
    }
    
    // 只读访问
    int getId() const { return itemId; }
    const std::string& getName() const { return name; }
    int getStackSize() const { return stackSize; }
    int getMaxStackSize() const { return maxStackSize; }
    
    // 虚函数：子类可重写
    virtual void use() = 0;
    virtual ~Item() = default;
};

// 消耗品
class Consumable : public Item {
private:
    int healAmount;
    
public:
    Consumable(int id, const std::string& name, int heal)
        : Item(id, name, 99), healAmount(heal) {}  // 消耗品最多堆叠99个
    
    void use() override {
        std::cout << "使用 " << getName() << "，恢复 " << healAmount << " 生命值\n";
        removeFromStack(1);
    }
};

// 装备
class Equipment : public Item {
private:
    int attackBonus;
    int defenseBonus;
    bool equipped;
    
public:
    Equipment(int id, const std::string& name, int atk, int def)
        : Item(id, name, 1),  // 装备不可堆叠
          attackBonus(atk), defenseBonus(def), equipped(false) {}
    
    void use() override {
        equipped = !equipped;
        std::cout << (equipped ? "装备了 " : "卸下了 ") << getName() << "\n";
    }
    
    bool isEquipped() const { return equipped; }
    int getAttackBonus() const { return attackBonus; }
    int getDefenseBonus() const { return defenseBonus; }
};

// 背包系统
class Inventory {
private:
    std::vector<std::unique_ptr<Item>> items;
    int maxSlots;
    
public:
    Inventory(int slots = 20) : maxSlots(slots) {}
    
    bool addItem(std::unique_ptr<Item> item) {
        // 先尝试堆叠到已有物品
        for (auto& existingItem : items) {
            if (existingItem->getId() == item->getId()) {
                if (existingItem->addToStack(item->getStackSize())) {
                    return true;
                }
            }
        }
        
        // 无法堆叠，检查是否有空位
        if (items.size() < maxSlots) {
            items.push_back(std::move(item));
            return true;
        }
        
        return false;  // 背包已满
    }
    
    void listItems() const {
        std::cout << "背包物品 (" << items.size() << "/" << maxSlots << "):\n";
        for (const auto& item : items) {
            std::cout << "- " << item->getName();
            if (item->getMaxStackSize() > 1) {
                std::cout << " x" << item->getStackSize();
            }
            std::cout << "\n";
        }
    }
};
```

=== 封装的最佳实践

```cpp
// ✓ 好的封装：不变性保证
class Rectangle {
private:
    double width;
    double height;
    
public:
    Rectangle(double w, double h) : width(w), height(h) {
        if (w <= 0 || h <= 0) {
            throw std::invalid_argument("宽和高必须为正数");
        }
    }
    
    void setWidth(double w) {
        if (w <= 0) throw std::invalid_argument("宽必须为正数");
        width = w;
    }
    
    void setHeight(double h) {
        if (h <= 0) throw std::invalid_argument("高必须为正数");
        height = h;
    }
    
    double getArea() const { return width * height; }
};

// ✗ 差的封装：暴露内部数据
class BadRectangle {
public:
    double width, height;  // 直接公开，无法保证数据有效性
};

BadRectangle rect;
rect.width = -5;  // 可以设置非法值！
```

== 继承（Inheritance）

=== 什么是继承？

*定义*：一个类（派生类）可以继承另一个类（基类）的成员，实现代码复用和类层次结构。

*继承类型*：
- public继承：is-a关系（派生类是基类的一种）
- protected继承：受保护实现
- private继承：实现继承（不推荐，建议用组合）

=== 游戏场景：角色系统

```cpp
// 基类：游戏实体
class GameObject {
protected:
    int id;
    std::string name;
    float x, y;
    bool active;
    
public:
    GameObject(int id, const std::string& name)
        : id(id), name(name), x(0), y(0), active(true) {}
    
    virtual ~GameObject() = default;
    
    // 每帧更新
    virtual void update(float deltaTime) = 0;
    
    // 渲染
    virtual void render() const = 0;
    
    // 通用功能
    void setPosition(float newX, float newY) {
        x = newX;
        y = newY;
    }
    
    void setActive(bool isActive) { active = isActive; }
    bool isActive() const { return active; }
    
    int getId() const { return id; }
    const std::string& getName() const { return name; }
};

// 派生类：可移动实体
class MovableObject : public GameObject {
protected:
    float velocityX, velocityY;
    float speed;
    
public:
    MovableObject(int id, const std::string& name, float speed)
        : GameObject(id, name), velocityX(0), velocityY(0), speed(speed) {}
    
    void setVelocity(float vx, float vy) {
        velocityX = vx;
        velocityY = vy;
    }
    
    void update(float deltaTime) override {
        if (active) {
            x += velocityX * speed * deltaTime;
            y += velocityY * speed * deltaTime;
        }
    }
};

// 战斗实体
class CombatEntity : public MovableObject {
protected:
    int health;
    int maxHealth;
    int attackPower;
    int defense;
    
public:
    CombatEntity(int id, const std::string& name, float speed, int maxHp, int atk, int def)
        : MovableObject(id, name, speed), 
          health(maxHp), maxHealth(maxHp), attackPower(atk), defense(def) {}
    
    virtual void takeDamage(int damage) {
        int actualDamage = std::max(0, damage - defense);
        health -= actualDamage;
        if (health < 0) health = 0;
        
        if (health == 0) {
            onDeath();
        }
    }
    
    virtual void attack(CombatEntity* target) {
        if (target && isAlive()) {
            std::cout << name << " 攻击 " << target->getName() << "\n";
            target->takeDamage(attackPower);
        }
    }
    
    virtual void onDeath() {
        std::cout << name << " 已死亡\n";
        setActive(false);
    }
    
    bool isAlive() const { return health > 0; }
    int getHealth() const { return health; }
};

// 玩家角色
class Player : public CombatEntity {
private:
    int level;
    int experience;
    int experienceToNextLevel;
    Inventory inventory;
    
public:
    Player(const std::string& name)
        : CombatEntity(1, name, 100.0f, 100, 10, 5),
          level(1), experience(0), experienceToNextLevel(100),
          inventory(20) {}
    
    void gainExperience(int exp) {
        experience += exp;
        std::cout << name << " 获得 " << exp << " 经验值\n";
        
        while (experience >= experienceToNextLevel) {
            levelUp();
        }
    }
    
    void levelUp() {
        level++;
        experience -= experienceToNextLevel;
        experienceToNextLevel = level * 100;
        
        // 属性提升
        maxHealth += 20;
        health = maxHealth;
        attackPower += 5;
        defense += 2;
        
        std::cout << name << " 升级到 " << level << " 级！\n";
    }
    
    void render() const override {
        std::cout << "[玩家] " << name << " Lv." << level 
                  << " HP:" << health << "/" << maxHealth 
                  << " 位置:(" << x << "," << y << ")\n";
    }
    
    Inventory& getInventory() { return inventory; }
};

// 敌人
class Enemy : public CombatEntity {
private:
    int expReward;
    
public:
    Enemy(int id, const std::string& name, int maxHp, int atk, int def, int exp)
        : CombatEntity(id, name, 50.0f, maxHp, atk, def), expReward(exp) {}
    
    void onDeath() override {
        CombatEntity::onDeath();
        std::cout << "击败 " << name << "，获得 " << expReward << " 经验值\n";
    }
    
    int getExpReward() const { return expReward; }
    
    void render() const override {
        std::cout << "[敌人] " << name << " HP:" << health << "/" << maxHealth 
                  << " 位置:(" << x << "," << y << ")\n";
    }
};

// NPC
class NPC : public GameObject {
private:
    std::string dialogue;
    
public:
    NPC(int id, const std::string& name, const std::string& dialogue)
        : GameObject(id, name), dialogue(dialogue) {}
    
    void talk() {
        std::cout << name << ": \"" << dialogue << "\"\n";
    }
    
    void update(float deltaTime) override {
        // NPC通常不需要更新逻辑
    }
    
    void render() const override {
        std::cout << "[NPC] " << name << " 位置:(" << x << "," << y << ")\n";
    }
};
```

=== 继承中的构造和析构

```cpp
class Base {
public:
    Base() { std::cout << "Base构造\n"; }
    virtual ~Base() { std::cout << "Base析构\n"; }
};

class Derived : public Base {
private:
    int* data;
    
public:
    Derived() : Base() {  // 先调用基类构造
        data = new int[100];
        std::cout << "Derived构造\n";
    }
    
    ~Derived() override {
        delete[] data;
        std::cout << "Derived析构\n";
        // 然后自动调用Base析构
    }
};

// 使用
{
    Derived d;
    // 输出：
    // Base构造
    // Derived构造
}
// 作用域结束：
// Derived析构
// Base析构
```

=== 多重继承（谨慎使用）

```cpp
// 接口类（纯虚函数）
class IRenderable {
public:
    virtual void render() const = 0;
    virtual ~IRenderable() = default;
};

class IUpdatable {
public:
    virtual void update(float deltaTime) = 0;
    virtual ~IUpdatable() = default;
};

class ICollidable {
public:
    virtual bool checkCollision(const ICollidable* other) const = 0;
    virtual ~ICollidable() = default;
};

// 游戏实体实现多个接口
class Bullet : public IRenderable, public IUpdatable, public ICollidable {
private:
    float x, y;
    float vx, vy;
    float radius;
    
public:
    Bullet(float x, float y, float vx, float vy)
        : x(x), y(y), vx(vx), vy(vy), radius(5.0f) {}
    
    void render() const override {
        std::cout << "渲染子弹于 (" << x << "," << y << ")\n";
    }
    
    void update(float deltaTime) override {
        x += vx * deltaTime;
        y += vy * deltaTime;
    }
    
    bool checkCollision(const ICollidable* other) const override {
        // 简化的碰撞检测
        return false;
    }
};
```

== 多态（Polymorphism）

=== 什么是多态？

*定义*：同一操作作用于不同对象，产生不同的行为。

*实现方式*：
1. *编译时多态*：函数重载、模板
2. *运行时多态*：虚函数、动态绑定

=== 虚函数机制

```cpp
// 技能系统
class Skill {
protected:
    std::string name;
    int manaCost;
    float cooldown;
    float currentCooldown;
    
public:
    Skill(const std::string& name, int mana, float cd)
        : name(name), manaCost(mana), cooldown(cd), currentCooldown(0) {}
    
    virtual ~Skill() = default;
    
    // 纯虚函数：子类必须实现
    virtual void execute(CombatEntity* caster, CombatEntity* target) = 0;
    
    // 虚函数：子类可选择重写
    virtual void update(float deltaTime) {
        if (currentCooldown > 0) {
            currentCooldown -= deltaTime;
        }
    }
    
    bool isReady() const { return currentCooldown <= 0; }
    
    void startCooldown() { currentCooldown = cooldown; }
    
    const std::string& getName() const { return name; }
    int getManaCost() const { return manaCost; }
};

// 攻击技能
class AttackSkill : public Skill {
private:
    int damageMultiplier;
    
public:
    AttackSkill(const std::string& name, int mana, float cd, int dmgMul)
        : Skill(name, mana, cd), damageMultiplier(dmgMul) {}
    
    void execute(CombatEntity* caster, CombatEntity* target) override {
        if (!isReady() || !caster || !target) return;
        
        int damage = caster->getAttackPower() * damageMultiplier;
        std::cout << caster->getName() << " 使用 " << name 
                  << " 对 " << target->getName() << " 造成 " << damage << " 伤害\n";
        target->takeDamage(damage);
        startCooldown();
    }
};

// 治疗技能
class HealSkill : public Skill {
private:
    int healAmount;
    
public:
    HealSkill(const std::string& name, int mana, float cd, int heal)
        : Skill(name, mana, cd), healAmount(heal) {}
    
    void execute(CombatEntity* caster, CombatEntity* target) override {
        if (!isReady() || !target) return;
        
        std::cout << caster->getName() << " 使用 " << name 
                  << " 治疗 " << target->getName() << " " << healAmount << " 生命值\n";
        // 假设CombatEntity有heal方法
        startCooldown();
    }
};

// 范围攻击技能
class AOESkill : public Skill {
private:
    int damage;
    float range;
    
public:
    AOESkill(const std::string& name, int mana, float cd, int dmg, float r)
        : Skill(name, mana, cd), damage(dmg), range(r) {}
    
    void execute(CombatEntity* caster, CombatEntity* target) override {
        if (!isReady() || !caster) return;
        
        std::cout << caster->getName() << " 使用范围技能 " << name << "\n";
        // 对范围内所有敌人造成伤害
        startCooldown();
    }
};

// 技能管理器
class SkillManager {
private:
    std::vector<std::unique_ptr<Skill>> skills;
    
public:
    void addSkill(std::unique_ptr<Skill> skill) {
        skills.push_back(std::move(skill));
    }
    
    void useSkill(size_t index, CombatEntity* caster, CombatEntity* target) {
        if (index < skills.size()) {
            skills[index]->execute(caster, target);
        }
    }
    
    void updateAll(float deltaTime) {
        for (auto& skill : skills) {
            skill->update(deltaTime);
        }
    }
    
    void listSkills() const {
        std::cout << "技能列表:\n";
        for (size_t i = 0; i < skills.size(); ++i) {
            std::cout << i << ". " << skills[i]->getName() 
                      << " (魔法消耗: " << skills[i]->getManaCost() << ")"
                      << (skills[i]->isReady() ? " [就绪]" : " [冷却中]") << "\n";
        }
    }
};
```

=== 虚函数表（vtable）原理

```cpp
class Animal {
public:
    virtual void makeSound() { std::cout << "Animal sound\n"; }
    virtual void move() { std::cout << "Animal moves\n"; }
    virtual ~Animal() = default;
};

class Dog : public Animal {
public:
    void makeSound() override { std::cout << "Woof!\n"; }
    void move() override { std::cout << "Dog runs\n"; }
};

class Cat : public Animal {
public:
    void makeSound() override { std::cout << "Meow!\n"; }
    // 不重写move，使用基类实现
};

// 内存布局
/*
Animal对象:
┌─────────┬──────┐
│  vptr   │ data │
└─────────┴──────┘
    │
    └──> Animal的vtable:
         ┌────────────────────┐
         │ &Animal::makeSound │
         │ &Animal::move      │
         │ &Animal::~Animal   │
         └────────────────────┘

Dog对象:
┌─────────┬──────┐
│  vptr   │ data │
└─────────┴──────┘
    │
    └──> Dog的vtable:
         ┌────────────────────┐
         │ &Dog::makeSound    │  // 重写
         │ &Dog::move         │  // 重写
         │ &Dog::~Dog         │
         └────────────────────┘
*/

// 多态调用
void playWithAnimal(Animal* animal) {
    animal->makeSound();  // 运行时决定调用哪个版本
    animal->move();
}

Dog dog;
Cat cat;
playWithAnimal(&dog);  // 输出：Woof! Dog runs
playWithAnimal(&cat);  // 输出：Meow! Animal moves
```

=== 游戏场景：AI系统

```cpp
// AI行为基类
class AIBehavior {
protected:
    std::string behaviorName;
    
public:
    AIBehavior(const std::string& name) : behaviorName(name) {}
    virtual ~AIBehavior() = default;
    
    // 执行行为
    virtual void execute(Enemy* entity, Player* target, float deltaTime) = 0;
    
    // 判断是否可以执行该行为
    virtual bool canExecute(Enemy* entity, Player* target) const = 0;
    
    const std::string& getName() const { return behaviorName; }
};

// 追逐行为
class ChaseBehavior : public AIBehavior {
private:
    float chaseRange;
    
public:
    ChaseBehavior(float range = 200.0f) 
        : AIBehavior("Chase"), chaseRange(range) {}
    
    bool canExecute(Enemy* entity, Player* target) const override {
        if (!entity || !target) return false;
        
        float dx = target->getX() - entity->getX();
        float dy = target->getY() - entity->getY();
        float distance = std::sqrt(dx*dx + dy*dy);
        
        return distance < chaseRange;
    }
    
    void execute(Enemy* entity, Player* target, float deltaTime) override {
        float dx = target->getX() - entity->getX();
        float dy = target->getY() - entity->getY();
        float distance = std::sqrt(dx*dx + dy*dy);
        
        if (distance > 0) {
            float vx = dx / distance;
            float vy = dy / distance;
            entity->setVelocity(vx, vy);
        }
    }
};

// 攻击行为
class AttackBehavior : public AIBehavior {
private:
    float attackRange;
    float attackCooldown;
    float currentCooldown;
    
public:
    AttackBehavior(float range = 30.0f, float cooldown = 1.0f)
        : AIBehavior("Attack"), attackRange(range), 
          attackCooldown(cooldown), currentCooldown(0) {}
    
    bool canExecute(Enemy* entity, Player* target) const override {
        if (!entity || !target || currentCooldown > 0) return false;
        
        float dx = target->getX() - entity->getX();
        float dy = target->getY() - entity->getY();
        float distance = std::sqrt(dx*dx + dy*dy);
        
        return distance <= attackRange;
    }
    
    void execute(Enemy* entity, Player* target, float deltaTime) override {
        if (currentCooldown > 0) {
            currentCooldown -= deltaTime;
            return;
        }
        
        entity->attack(target);
        currentCooldown = attackCooldown;
    }
};

// 巡逻行为
class PatrolBehavior : public AIBehavior {
private:
    std::vector<std::pair<float, float>> waypoints;
    size_t currentWaypoint;
    float waypointReachDistance;
    
public:
    PatrolBehavior(const std::vector<std::pair<float, float>>& points)
        : AIBehavior("Patrol"), waypoints(points), currentWaypoint(0),
          waypointReachDistance(10.0f) {}
    
    bool canExecute(Enemy* entity, Player* target) const override {
        return !waypoints.empty();
    }
    
    void execute(Enemy* entity, Player* target, float deltaTime) override {
        if (waypoints.empty()) return;
        
        auto& [targetX, targetY] = waypoints[currentWaypoint];
        float dx = targetX - entity->getX();
        float dy = targetY - entity->getY();
        float distance = std::sqrt(dx*dx + dy*dy);
        
        if (distance < waypointReachDistance) {
            // 到达当前巡逻点，前往下一个
            currentWaypoint = (currentWaypoint + 1) % waypoints.size();
        } else {
            // 移动向巡逻点
            float vx = dx / distance;
            float vy = dy / distance;
            entity->setVelocity(vx * 0.5f, vy * 0.5f);  // 巡逻速度较慢
        }
    }
};

// AI控制器
class AIController {
private:
    std::vector<std::unique_ptr<AIBehavior>> behaviors;
    AIBehavior* currentBehavior;
    
public:
    AIController() : currentBehavior(nullptr) {}
    
    void addBehavior(std::unique_ptr<AIBehavior> behavior) {
        behaviors.push_back(std::move(behavior));
    }
    
    void update(Enemy* entity, Player* target, float deltaTime) {
        // 选择优先级最高且可执行的行为
        for (auto& behavior : behaviors) {
            if (behavior->canExecute(entity, target)) {
                if (currentBehavior != behavior.get()) {
                    currentBehavior = behavior.get();
                    std::cout << entity->getName() << " 切换行为: " 
                              << currentBehavior->getName() << "\n";
                }
                currentBehavior->execute(entity, target, deltaTime);
                return;
            }
        }
        
        // 没有可执行的行为，停止移动
        entity->setVelocity(0, 0);
        currentBehavior = nullptr;
    }
};

// 使用示例
void setupEnemy() {
    Enemy enemy(1, "哥布林", 50, 5, 2, 25);
    
    AIController ai;
    ai.addBehavior(std::make_unique<AttackBehavior>(30.0f, 1.0f));  // 优先级最高
    ai.addBehavior(std::make_unique<ChaseBehavior>(200.0f));
    ai.addBehavior(std::make_unique<PatrolBehavior>(
        std::vector<std::pair<float, float>>{{0,0}, {100,0}, {100,100}, {0,100}}
    ));
    
    // 游戏循环中
    // ai.update(&enemy, &player, deltaTime);
}
```

== 抽象类与接口

=== 抽象类

*定义*：包含至少一个纯虚函数的类，不能实例化，用作基类定义接口。

```cpp
// 武器系统
class Weapon {
protected:
    std::string name;
    int damage;
    float range;
    
public:
    Weapon(const std::string& name, int dmg, float rng)
        : name(name), damage(dmg), range(rng) {}
    
    virtual ~Weapon() = default;
    
    // 纯虚函数：攻击方法
    virtual void attack(const std::string& targetName) = 0;
    
    // 纯虚函数：特殊能力
    virtual void specialAbility() = 0;
    
    // 普通虚函数：可以有默认实现
    virtual void display() const {
        std::cout << "武器: " << name << " 伤害:" << damage 
                  << " 范围:" << range << "\n";
    }
    
    int getDamage() const { return damage; }
    float getRange() const { return range; }
};

// Weapon weapon;  // ✗ 错误！不能实例化抽象类

// 近战武器
class MeleeWeapon : public Weapon {
protected:
    float attackSpeed;
    
public:
    MeleeWeapon(const std::string& name, int dmg, float speed)
        : Weapon(name, dmg, 2.0f), attackSpeed(speed) {}
    
    void attack(const std::string& targetName) override {
        std::cout << "用 " << name << " 近战攻击 " << targetName 
                  << "，造成 " << damage << " 伤害\n";
    }
};

// 剑
class Sword : public MeleeWeapon {
public:
    Sword() : MeleeWeapon("铁剑", 25, 1.0f) {}
    
    void specialAbility() override {
        std::cout << "剑技：旋风斩！范围伤害 " << damage * 1.5 << "\n";
    }
};

// 锤子
class Hammer : public MeleeWeapon {
public:
    Hammer() : MeleeWeapon("战锤", 40, 0.7f) {}
    
    void specialAbility() override {
        std::cout << "重击：震地！眩晕敌人\n";
    }
};

// 远程武器
class RangedWeapon : public Weapon {
protected:
    int ammo;
    int maxAmmo;
    
public:
    RangedWeapon(const std::string& name, int dmg, float rng, int maxAmmo)
        : Weapon(name, dmg, rng), ammo(maxAmmo), maxAmmo(maxAmmo) {}
    
    void attack(const std::string& targetName) override {
        if (ammo > 0) {
            std::cout << "用 " << name << " 远程攻击 " << targetName 
                      << "，造成 " << damage << " 伤害\n";
            ammo--;
        } else {
            std::cout << "弹药耗尽！需要装填\n";
        }
    }
    
    void reload() {
        ammo = maxAmmo;
        std::cout << name << " 已装填\n";
    }
};

// 弓
class Bow : public RangedWeapon {
public:
    Bow() : RangedWeapon("长弓", 20, 50.0f, 30) {}
    
    void specialAbility() override {
        if (ammo >= 3) {
            std::cout << "多重箭！发射3支箭\n";
            ammo -= 3;
        }
    }
};

// 使用多态
void testWeapon(Weapon* weapon) {
    weapon->display();
    weapon->attack("哥布林");
    weapon->specialAbility();
}

Sword sword;
Bow bow;
testWeapon(&sword);
testWeapon(&bow);
```

=== 接口设计模式

```cpp
// 保存/加载接口
class ISaveable {
public:
    virtual void save(std::ostream& out) const = 0;
    virtual void load(std::istream& in) = 0;
    virtual ~ISaveable() = default;
};

// 玩家数据实现保存接口
class PlayerData : public ISaveable {
private:
    std::string playerName;
    int level;
    int health;
    float x, y;
    
public:
    void save(std::ostream& out) const override {
        out << playerName << "\n"
            << level << "\n"
            << health << "\n"
            << x << " " << y << "\n";
    }
    
    void load(std::istream& in) override {
        std::getline(in, playerName);
        in >> level >> health >> x >> y;
        in.ignore();  // 忽略换行符
    }
};

// 存档管理器
class SaveManager {
public:
    static void saveGame(const std::string& filename, const ISaveable& data) {
        std::ofstream file(filename);
        if (file.is_open()) {
            data.save(file);
            std::cout << "游戏已保存到 " << filename << "\n";
        }
    }
    
    static void loadGame(const std::string& filename, ISaveable& data) {
        std::ifstream file(filename);
        if (file.is_open()) {
            data.load(file);
            std::cout << "游戏已从 " << filename << " 加载\n";
        }
    }
};
```

== 组合 vs 继承

=== 何时使用继承？

*Is-A关系*：派生类是基类的一种特化

```cpp
// ✓ 好的继承：明确的is-a关系
class Vehicle { };
class Car : public Vehicle { };  // Car is a Vehicle

class Animal { };
class Dog : public Animal { };   // Dog is an Animal
```

=== 何时使用组合？

*Has-A关系*：对象包含另一个对象

```cpp
// ✓ 好的组合：has-a关系
class Engine {
public:
    void start() { std::cout << "引擎启动\n"; }
    void stop() { std::cout << "引擎停止\n"; }
};

class Car {
private:
    Engine engine;  // Car has an Engine
    
public:
    void start() {
        engine.start();
        std::cout << "汽车启动\n";
    }
};
```

=== 游戏场景：组件系统（推荐）

```cpp
// 组件基类
class Component {
protected:
    bool enabled;
    
public:
    Component() : enabled(true) {}
    virtual ~Component() = default;
    
    virtual void update(float deltaTime) = 0;
    
    void setEnabled(bool e) { enabled = e; }
    bool isEnabled() const { return enabled; }
};

// 具体组件
class TransformComponent : public Component {
public:
    float x, y;
    float rotation;
    float scaleX, scaleY;
    
    TransformComponent() 
        : x(0), y(0), rotation(0), scaleX(1), scaleY(1) {}
    
    void update(float deltaTime) override {
        // 变换更新逻辑
    }
    
    void setPosition(float newX, float newY) {
        x = newX;
        y = newY;
    }
};

class SpriteComponent : public Component {
private:
    std::string texturePath;
    int width, height;
    
public:
    SpriteComponent(const std::string& path, int w, int h)
        : texturePath(path), width(w), height(h) {}
    
    void update(float deltaTime) override {
        // 精灵更新逻辑
    }
    
    void render(float x, float y) const {
        std::cout << "渲染精灵 " << texturePath 
                  << " 于 (" << x << "," << y << ")\n";
    }
};

class PhysicsComponent : public Component {
private:
    float velocityX, velocityY;
    float mass;
    bool useGravity;
    
public:
    PhysicsComponent(float m = 1.0f, bool gravity = true)
        : velocityX(0), velocityY(0), mass(m), useGravity(gravity) {}
    
    void update(float deltaTime) override {
        if (useGravity) {
            velocityY += 9.8f * deltaTime;  // 重力加速度
        }
    }
    
    void setVelocity(float vx, float vy) {
        velocityX = vx;
        velocityY = vy;
    }
    
    float getVelocityX() const { return velocityX; }
    float getVelocityY() const { return velocityY; }
};

class HealthComponent : public Component {
private:
    int currentHealth;
    int maxHealth;
    
public:
    HealthComponent(int maxHp) 
        : currentHealth(maxHp), maxHealth(maxHp) {}
    
    void update(float deltaTime) override {
        // 生命值相关更新（如自动回复）
    }
    
    void takeDamage(int damage) {
        currentHealth -= damage;
        if (currentHealth < 0) currentHealth = 0;
    }
    
    void heal(int amount) {
        currentHealth += amount;
        if (currentHealth > maxHealth) currentHealth = maxHealth;
    }
    
    bool isAlive() const { return currentHealth > 0; }
    int getHealth() const { return currentHealth; }
};

// 游戏实体：组合多个组件
class Entity {
private:
    std::string name;
    std::map<std::string, std::unique_ptr<Component>> components;
    
public:
    Entity(const std::string& name) : name(name) {}
    
    template<typename T, typename... Args>
    T* addComponent(const std::string& compName, Args&&... args) {
        auto comp = std::make_unique<T>(std::forward<Args>(args)...);
        T* ptr = comp.get();
        components[compName] = std::move(comp);
        return ptr;
    }
    
    template<typename T>
    T* getComponent(const std::string& compName) {
        auto it = components.find(compName);
        if (it != components.end()) {
            return dynamic_cast<T*>(it->second.get());
        }
        return nullptr;
    }
    
    void update(float deltaTime) {
        for (auto& [name, comp] : components) {
            if (comp->isEnabled()) {
                comp->update(deltaTime);
            }
        }
    }
    
    const std::string& getName() const { return name; }
};

// 使用示例：创建一个玩家实体
Entity* createPlayer() {
    auto player = new Entity("Player");
    
    // 添加变换组件
    auto transform = player->addComponent<TransformComponent>("transform");
    transform->setPosition(100, 100);
    
    // 添加精灵组件
    player->addComponent<SpriteComponent>("sprite", "player.png", 32, 32);
    
    // 添加物理组件
    auto physics = player->addComponent<PhysicsComponent>("physics", 1.0f, true);
    physics->setVelocity(50, 0);
    
    // 添加生命值组件
    player->addComponent<HealthComponent>("health", 100);
    
    return player;
}

// 游戏循环
void gameLoop() {
    Entity* player = createPlayer();
    float deltaTime = 0.016f;  // 约60 FPS
    
    // 更新所有组件
    player->update(deltaTime);
    
    // 访问特定组件
    auto health = player->getComponent<HealthComponent>("health");
    if (health) {
        health->takeDamage(10);
        std::cout << "玩家生命值: " << health->getHealth() << "\n";
    }
    
    auto transform = player->getComponent<TransformComponent>("transform");
    auto sprite = player->getComponent<SpriteComponent>("sprite");
    if (transform && sprite) {
        sprite->render(transform->x, transform->y);
    }
    
    delete player;
}
```

== 面向对象设计原则

=== SOLID原则

*1. 单一职责原则（Single Responsibility Principle）*

一个类应该只有一个引起它变化的原因。

```cpp
// ✗ 违反SRP：一个类做太多事
class BadPlayer {
    void move() { }
    void attack() { }
    void saveToDatabase() { }  // 不应该在这里！
    void renderGraphics() { }  // 不应该在这里！
};

// ✓ 遵循SRP：职责分离
class Player {
    void move() { }
    void attack() { }
};

class PlayerRepository {
    void save(const Player& player) { }
    void load(Player& player) { }
};

class PlayerRenderer {
    void render(const Player& player) { }
};
```

*2. 开闭原则（Open-Closed Principle）*

对扩展开放，对修改关闭。

```cpp
// ✓ 通过继承扩展，不修改原有代码
class DamageCalculator {
public:
    virtual int calculate(int baseDamage) const {
        return baseDamage;
    }
    virtual ~DamageCalculator() = default;
};

class CriticalDamageCalculator : public DamageCalculator {
private:
    float critChance;
    float critMultiplier;
    
public:
    CriticalDamageCalculator(float chance, float multiplier)
        : critChance(chance), critMultiplier(multiplier) {}
    
    int calculate(int baseDamage) const override {
        if (rand() % 100 < critChance * 100) {
            return baseDamage * critMultiplier;
        }
        return baseDamage;
    }
};
```

*3. 里氏替换原则（Liskov Substitution Principle）*

子类对象应该能够替换父类对象。

```cpp
// ✓ 正确的LSP
class Bird {
public:
    virtual void eat() { std::cout << "鸟在吃\n"; }
    virtual ~Bird() = default;
};

class Sparrow : public Bird {
public:
    void eat() override { std::cout << "麻雀在吃虫子\n"; }
};

void feedBird(Bird* bird) {
    bird->eat();  // 任何Bird的子类都可以
}

// ✗ 违反LSP的经典例子
class BirdBad {
public:
    virtual void fly() { std::cout << "飞\n"; }
};

class Penguin : public BirdBad {
public:
    void fly() override {
        throw std::logic_error("企鹅不会飞！");  // 违反LSP！
    }
};
```

*4. 接口隔离原则（Interface Segregation Principle）*

不应该强迫客户端依赖它不使用的接口。

```cpp
// ✗ 违反ISP：庞大的接口
class IWorker {
public:
    virtual void work() = 0;
    virtual void eat() = 0;
    virtual void sleep() = 0;
};

// Robot实现IWorker，但不需要eat和sleep

// ✓ 遵循ISP：接口分离
class IWorkable {
public:
    virtual void work() = 0;
    virtual ~IWorkable() = default;
};

class IFeedable {
public:
    virtual void eat() = 0;
    virtual ~IFeedable() = default;
};

class ISleepable {
public:
    virtual void sleep() = 0;
    virtual ~ISleepable() = default;
};

class Human : public IWorkable, public IFeedable, public ISleepable {
public:
    void work() override { std::cout << "工作\n"; }
    void eat() override { std::cout << "吃饭\n"; }
    void sleep() override { std::cout << "睡觉\n"; }
};

class Robot : public IWorkable {
public:
    void work() override { std::cout << "工作\n"; }
    // 不需要实现eat和sleep
};
```

*5. 依赖倒置原则（Dependency Inversion Principle）*

高层模块不应该依赖低层模块，两者都应该依赖抽象。

```cpp
// ✗ 违反DIP：直接依赖具体类
class BadGame {
    Sword sword;  // 依赖具体武器
    
public:
    void attack() {
        sword.attack("敌人");
    }
};

// ✓ 遵循DIP：依赖抽象
class GoodGame {
private:
    std::unique_ptr<Weapon> weapon;  // 依赖抽象接口
    
public:
    void setWeapon(std::unique_ptr<Weapon> w) {
        weapon = std::move(w);
    }
    
    void attack(const std::string& target) {
        if (weapon) {
            weapon->attack(target);
        }
    }
};

// 使用
GoodGame game;
game.setWeapon(std::make_unique<Sword>());
game.attack("哥布林");

game.setWeapon(std::make_unique<Bow>());
game.attack("龙");
```

== 总结与最佳实践

*封装*：
- 优先使用private，必要时用protected，谨慎使用public
- 提供getter/setter保护数据完整性
- 隐藏实现细节，暴露稳定接口

*继承*：
- 用于"is-a"关系
- 避免深层继承（一般不超过3层）
- 基类析构函数声明为virtual
- 考虑使用final防止继承

*多态*：
- 通过虚函数实现运行时多态
- 纯虚函数定义接口契约
- 优先使用接口（抽象类）而非具体类

*组合优于继承*：
- 优先考虑组件系统
- 更灵活，耦合度更低
- 更容易测试和维护

*设计原则*：
- 遵循SOLID原则
- 保持高内聚、低耦合
- 面向接口编程
- 优先使用组合而非继承