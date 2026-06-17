# Feature Ideas for Screenplay-Prompt

## Screenplay Elements

### 1. Character dialogue prompts
- Git status → "CHARACTER" label
- Clean: NARRATOR
- Dirty: GIT (speaking your uncommitted changes)
- Merge conflict: ANTAGONIST

### 2. Scene headings from git branches
```
INT. FEATURE/AUTH-REFACTOR - DAY
$ git checkout main
DISSOLVE TO:
INT. MAIN - DAY
```

### 3. Action lines from last command
```
$ npm test
(Tests pass. Rick nods approvingly.)

INT. /HOME/RICK/PROJECT - DAY
```

## Time/Context Awareness

### 4. Golden hour transitions
- 6-7am: FADE IN:
- 5-6pm: MAGIC HOUR:
- Midnight: FADE TO BLACK:

### 5. Weekend sluglines
```
INT. /HOME/RICK - SATURDAY
(instead of DAY/NIGHT)
```

### 6. Session-based act structure
```
ACT I
INT. TERMINAL - DAY
$ # work work work...
(2 hours later)
ACT II
```

## Git Integration

### 7. Commit count → page numbers
```
                                                      PAGE 247

INT. REPO - NIGHT
```

### 8. Branch-specific locations
- main → INT. STUDIO
- feature/* → INT. WRITER'S ROOM
- hotfix/* → EXT. BURNING BUILDING

### 9. PR status transitions
- Open PR: MEANWHILE:
- Merged: THE END.
- Conflict: TO BE CONTINUED...

## Visual Enhancements

### 10. Parentheticals for command status
```
INT. PROJECT - DAY
(frustrated)
$ npm install
```

### 11. Montage mode for loops
```
MONTAGE - BUILDING THE PROJECT
$ make
$ make test
$ make deploy
END MONTAGE
```

### 12. Dual timeline (split screen)
```
INT. PROJECT - DAY          |  INTERCUT WITH: INT. CI/CD - NIGHT
$                           |  (pipeline running...)
```

## Productivity

### 13. Timer-based urgency
```
INT. PROJECT - DAY (T-30 MINUTES TO DEADLINE)
```

### 14. Pomodoro scene breaks
- 25min → FADE TO: BREAK
- Shows coffee cup ASCII art

### 15. Command history as flashbacks
```
FLASHBACK TO:
$ git commit -m "this will work"
(It didn't work.)
BACK TO PRESENT:
```

## Easter Eggs

### 16. Famous screenplay references
- ~/rosebud → special location
- midnight → "Here's Johnny!" transition
- Error code 404 → "Forget it, Jake. It's Chinatown."

### 17. Weather-based sluglines (via wttr.in)
```
EXT. /HOME/RICK - TORRENTIAL RAIN - NIGHT
```

### 18. Fortune cookie scene descriptions
```
INT. PROJECT - DAY
(The code works on first try. Impossible.)
```

## Config Expansions

### 19. Character name customization
```
~/.config/screenplay/character
RICK SANCHEZ
```

### 20. Genre modes
- noir: All NIGHT, detective terms
- horror: Ominous transitions
- comedy: Lighthearted beats

### 21. Soundtrack annotations
```
INT. PROJECT - DAY
(♫ "Eye of the Tiger" plays)
```

## Performance/System

### 22. Load average as tension
```
INT. OVERLOADED-SERVER - DAY (SERVERS AT 95%)
```

### 23. Disk space warnings
```
INT. /HOME - DAY
(The hard drive groans. Only 2GB remain.)
```

### 24. Network status
```
EXT. OFFLINE - DAY (NO CONNECTION)
```

## Advanced

### 25. Multi-user screenplay
- SSH session shows other "characters"
- tmux pairs → dialogue format

### 26. Screenplay export
```
$ screenplay-export --today
# Generates .fountain file of session
```

### 27. Async job tracking
```
MEANWHILE:
(background job still running...)
```

## Implementation Notes

- Most features can be optional config flags
- Maintain single-file architecture for core
- Extensions could live in `~/.config/screenplay/plugins/`
- Keep performance overhead minimal (cache everything)
