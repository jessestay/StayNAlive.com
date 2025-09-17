# Agile Development Standards

## Sprint Structure
```
Every sprint must have:
1. Clear user stories with business value
2. Defined acceptance criteria (AC)
3. Automated tests for each AC
4. Documentation updates
5. Working demo at end
```

## User Story Format
```
As a [role]
I want [feature]
So that [benefit]

Acceptance Criteria:
✅/❌ [Testable criterion]
  - Implementation: [class::method()]
  - Test: [TestClass::testMethod()]
```

## Test Coverage Requirements
```
1. Every AC must have corresponding test(s)
2. Tests must be automated
3. No story is "Done" until tests pass
4. Coverage report required in sprint review
```

## Documentation Requirements
```
1. README.md with installation/usage
2. SPRINT[N].md tracking story progress
3. INSTALL.md with platform-specific guides
4. API documentation for public interfaces
```

## Sprint Tracking
```
docs/SPRINT[N].md must contain:
- User stories with AC status (✅/❌)
- Implementation details
- Test coverage
- Demo instructions
```

## Release Criteria
```
Before merge to main:
1. All AC tests passing
2. Documentation updated
3. Installation tested on all platforms
4. Demo instructions verified
5. No known bugs
```

## Story Weights
```
Estimate complexity (1-5):
1: Simple change, single file
2: Multiple files, no new features
3: New feature, existing patterns
4: Complex feature, new patterns
5: System-wide changes
```

## Sprint Review Checklist
```
1. All stories complete?
2. All tests passing?
3. Documentation updated?
4. Demo works?
5. Installation verified?
6. Cross-platform tested?
```

## Quality Gates
```
Code cannot be merged unless:
1. Tests exist for all AC
2. Tests pass on all platforms
3. Documentation is current
4. Installation verified
5. Demo instructions work
```

## Sprint Planning Rules
```
1. Stories must be sized to complete in sprint
2. Each story needs clear AC
3. AC must be testable
4. Platform requirements documented
5. Dependencies identified
```

## Development Flow
```
1. Create story branch
2. Write failing tests
3. Implement feature
4. Make tests pass
5. Update documentation
6. Create demo
7. Verify installation
8. Submit PR
```

## Documentation Flow
```
1. Update user stories in SPRINT[N].md
2. Add tests to verify AC
3. Document implementation
4. Create/update installation guides
5. Write demo instructions
6. Verify all docs match code
``` 