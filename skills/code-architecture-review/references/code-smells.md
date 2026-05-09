# Code Smells Catalog

Source: Fowler's Refactoring, refactoring.guru, and modern additions.
Each smell includes: description, detection signal, severity, and the refactoring move.

---

## Category 1 — Bloaters
Things that have grown too large to handle effectively.

### God Class / God Module
**What:** A single class or file that knows too much and does too much — hundreds of methods, thousands of lines, imported everywhere.
**Signal:** File > 500 lines; imported by 10+ other files; class with >10 public methods doing unrelated things.
**Severity:** Critical
**Fix:** Extract Class — identify clusters of related fields/methods and move them to dedicated classes.

### Long Method
**What:** A method so long it's impossible to understand at a glance.
**Signal:** Function > 40 lines. Functions >20 lines deserve a second look.
**Severity:** Medium
**Fix:** Extract Method — find blocks of code that can be named and pulled into their own function. Each function should do one thing and do it at one level of abstraction.

### Large Class
**What:** A class with too many fields and methods.
**Signal:** >15 instance variables; constructor with >8 parameters.
**Severity:** Medium-High
**Fix:** Extract Class or Extract Subclass. Group related data into value objects.

### Long Parameter List
**What:** A function with >3-4 parameters.
**Signal:** `function processOrder(userId, productId, quantity, discount, coupon, addressId, paymentMethod)`.
**Severity:** Medium
**Fix:** Introduce Parameter Object — group related params into a struct/object. Or Replace Parameter with Method if the value can be derived.

### Primitive Obsession
**What:** Using raw primitives (`string`, `int`, `bool`) where a domain type would be safer.
**Signal:** `userId: string` passed everywhere; `"USD"` hardcoded; raw email strings without validation.
**Severity:** Medium
**Fix:** Replace Primitive with Object — create a `UserId`, `Currency`, `Email` type that encapsulates validation and behavior.

### Data Clumps
**What:** Groups of data that always appear together but aren't formalized as a type.
**Signal:** `(firstName, lastName, email)` passed around as three separate params in 6 different functions.
**Severity:** Low-Medium
**Fix:** Extract Class or Introduce Parameter Object for the clump.

---

## Category 2 — Object-Orientation Abusers

### Switch Statement / Long If-Else Chain
**What:** Switch/if-else chains that grow every time a new type is added.
**Signal:** `if type === 'admin'... else if type === 'editor'... else if type === 'viewer'...` duplicated in multiple places.
**Severity:** Medium-High
**Fix:** Replace Conditional with Polymorphism — create subclasses or strategy objects; or use a dispatch map.

### Temporary Field
**What:** Instance fields that are only set in certain conditions and null otherwise.
**Signal:** `this.result = null` in constructor; set only inside one method; other methods check `if (this.result)`.
**Severity:** Low-Medium
**Fix:** Extract Class for the special-case behavior.

### Refused Bequest
**What:** A subclass inherits methods from a parent but doesn't use (or actively breaks) them.
**Signal:** Subclass overrides methods to throw `NotImplementedError` or do nothing.
**Severity:** Medium
**Fix:** Replace Inheritance with Delegation; or restructure the hierarchy.

### Alternative Classes with Different Interfaces
**What:** Two classes do the same thing but have different method names.
**Signal:** `UserFetcher.getUser()` and `AccountLoader.loadAccount()` do identical things.
**Severity:** Low
**Fix:** Rename Method to unify interfaces; then Extract Superclass or introduce a shared interface.

---

## Category 3 — Change Preventers
These make it hard to change code without touching many places.

### Divergent Change
**What:** One class changes for multiple unrelated reasons.
**Signal:** "I change this class when I add a new payment method AND when I change the report format."
**Severity:** High
**Fix:** Split the class into two — one per reason to change (SRP).

### Shotgun Surgery
**What:** One logical change requires many small edits in many different files.
**Signal:** "To add a new user role, I have to edit 8 files."
**Severity:** High (opposite of Divergent Change — here one change hits many classes)
**Fix:** Move Method / Move Field to consolidate the scattered logic. Introduce a single place that owns the concept.

### Parallel Inheritance Hierarchies
**What:** Every time you add a subclass of X, you also have to add a subclass of Y.
**Signal:** `AnimalShape` and `AnimalRenderer` hierarchies that must always grow together.
**Severity:** Medium
**Fix:** Collapse into a single hierarchy or use delegation.

---

## Category 4 — Dispensables
Things that are unnecessary and should be removed.

### Duplicate Code (DRY Violation)
**What:** The same code structure (or near-identical logic) appears in multiple places.
**Signal:** Ctrl+F finds the same 10-line block in 3 files; copy-paste comment patterns.
**Severity:** High
**Fix:** Extract Method (same class), Pull Up Method (subclasses), or Extract Module.

### Dead Code
**What:** Code that is never executed — unreachable branches, unused functions, obsolete modules.
**Signal:** Functions never called; `if false` blocks; commented-out code; unused imports.
**Severity:** Medium (low for style, high for maintenance confusion)
**Fix:** Delete it. Version control keeps history.

### Lazy Class
**What:** A class that does so little it doesn't justify its own existence.
**Signal:** A class with one method that wraps another class with no added logic.
**Severity:** Low
**Fix:** Inline Class — collapse it into the calling class.

### Speculative Generality
**What:** Code written "in case we need it later" — hooks, abstractions, and parameters with no current user.
**Signal:** Abstract base classes with one subclass; configuration parameters nobody sets; generic utilities with one call site.
**Severity:** Low
**Fix:** YAGNI — delete it. Re-add when there's a real second use case.

### Data Class
**What:** A class that only holds data — getters and setters, no behavior.
**Signal:** A class with 10 fields, all public or with trivial getters/setters, and no methods beyond that.
**Severity:** Low-Medium (not always bad, but signals missing behavior elsewhere)
**Fix:** Move behavior that operates on this data into the class (Feature Envy smell on the other side).

### Comments as Crutch
**What:** Comments that exist because the code is unclear, not because the concept is genuinely complex.
**Signal:** Comments that re-state what the code does (`// increment i by 1`) rather than why.
**Severity:** Low (style issue, but signals unclear code)
**Fix:** Extract Method with a descriptive name; use Rename Variable/Function. Good code mostly explains itself.

---

## Category 5 — Couplers
These cause excessive coupling between classes.

### Feature Envy
**What:** A method that seems more interested in data from another class than its own.
**Signal:** `OrderProcessor.process()` reaches into `User` to get email, address, payment method — using more of User's data than its own.
**Severity:** High
**Fix:** Move Method — the method probably belongs on the class whose data it uses.

### Inappropriate Intimacy
**What:** Two classes know too much about each other's internals.
**Signal:** ClassA accesses private fields of ClassB; mutual imports; circular dependency.
**Severity:** High
**Fix:** Move Method / Move Field to reduce coupling; introduce an interface between them.

### Message Chains
**What:** A long chain of method calls to get to data: `a.getB().getC().getD().getValue()`.
**Signal:** Chains of 3+ `.get()` calls; `req.user.profile.settings.theme`.
**Severity:** Medium
**Fix:** Hide Delegate — add a method on the first object that provides the needed data directly (Law of Demeter).

### Middle Man
**What:** A class that does nothing but delegate every call to another class.
**Signal:** `UserService.getUser(id)` just calls `userRepository.findById(id)` with zero added logic.
**Severity:** Low
**Fix:** Remove Middle Man — call the delegate directly; or justify the middleman's existence.

---

## Severity Quick Reference

| Severity | Meaning |
|----------|---------|
| **Critical** | Fix immediately — causes bugs, blocks testing, or makes the system fragile |
| **High** | Fix in next sprint — compounds over time, slows every future change |
| **Medium** | Fix when touching the file — won't hurt now but creates debt |
| **Low** | Good to fix — style, clarity, and maintainability improvements |
