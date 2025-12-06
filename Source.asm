; ############################################################
; SUPER MARIO GAME - Roll Number: 2587 (Last Digit: 7)
; Fire Master Mario - Green Shirt
; ############################################################

INCLUDE Irvine32.inc
includelib Winmm.lib

PlaySound PROTO,
    pszSound:PTR BYTE,
    hmod:DWORD,
    fdwSound:DWORD

.data
    ConsoleInfo CONSOLE_CURSOR_INFO<1,0>
    
    ; === STUDENT INFO ===
    myName db "Name: [Your Name]",0
    myRoll db "Roll No: 2587",0
    mySection db "Section: [Your Section]",0
    
    ; === MENU STRINGS ===
    title1 db "SUPER MARIO BROS",0
    play_title db "Play (P)",0
    score_prompt db "HighScores (H)",0
    quitt db "Quit (Q)",0
    gameOver1 db "GAME OVER",0
    gameWon1 db "YOU WIN!",0
    
    ; === GAME STRINGS ===
    socre_txt db " Score: ",0
    livetxt db " Lives: ",0
    username_txt db " Player: ",0
    level_text db " World: ",0
    
    ; === PLAYER DATA ===
    userName db 20 dup(?)
    userNameSize = 20
    
    mario_x dd 5
    mario_y dd 18
    mario_velocity_y dd 0     ; For jump physics
    mario_on_ground db 1      ; 1 if on ground, 0 if in air
    mario_jump_power = -4     ; Negative = upward (slightly higher jump)
    gravity = 1               ; Pull down
    mario_speed = 1           ; Movement speed
    
    ; === FIRE MASTER MARIO (Roll 2587 - Last Digit 7) ===
    fire_active db 1          ; Starts with fire ability
    ice_flower_x dd 15
    ice_flower_y dd 10
    ice_flower_visible db 1
    
    ; Fireballs (max 2 on screen)
    fireball1_x dd -1         ; -1 = not active
    fireball1_y dd -1
    fireball1_dir db 0        ; 0=none, 1=right, 2=left
    fireball2_x dd -1
    fireball2_y dd -1
    fireball2_dir db 0
    
    ; === ENEMY DATA ===
    ; Goomba 1
    goomba1_x dd 25
    goomba1_y dd 17           ; On ground level
    goomba1_dir db 1          ; 1=right, 2=left
    goomba1_alive db 1
    goomba1_frozen dd 0       ; Freeze timer
    
    ; Goomba 2
    goomba2_x dd 60
    goomba2_y dd 17           ; On ground level
    goomba2_dir db 2
    goomba2_alive db 1
    goomba2_frozen dd 0
    
    ; === BOSS DATA (Level 2) ===
    boss_x dd 70
    boss_y dd 18
    boss_health db 5
    boss_alive db 1
    boss_dir db 2
    boss_fire_timer dd 0
    
    ; === GAME STATE ===
    level db 1
    score dd 0
    lives db 3
    game_state db 0           ; 0=menu, 1=playing, 2=paused, 3=gameover
    
    ; === LEVEL MAP ===
    ; 0 = empty, 1 = wall/platform, 2 = coin, 3 = ice flower
    map_width = 80
    map_height = 24
    
    ; Simplified level map (we'll build this procedurally)
    level1_map db (map_height * map_width) dup(0)
    
    ; === TIMING ===
    move_counter dd 0
    enemy_counter dd 0
    fireball_counter dd 0
    
    ; === INPUT ===
    last_key db 0
    facing_right db 1         ; 1=right, 0=left

.code

; ============================================================
; PROCEDURE: InitializeLevel1
; Creates the grassland level with platforms
; ============================================================
InitializeLevel1 PROC
    ; Clear map
    mov ecx, map_height * map_width
    mov esi, 0
    ClearLoop:
        mov [level1_map + esi], 0
        inc esi
        loop ClearLoop
    
    ; Create ground (row 18-23)
    mov eax, 18                ; Start row
    GroundLoop:
        mov ebx, 0             ; Column
        GroundColLoop:
            ; Calculate offset: row * width + col
            push eax
            mov eax, map_width
            imul eax, dword ptr [esp]    ; eax = row * width
            add eax, ebx       ; eax = row * width + col
            mov [level1_map + eax], 1
            pop eax
            
            inc ebx
            cmp ebx, map_width
            jl GroundColLoop
        
        inc eax
        cmp eax, map_height
        jl GroundLoop
    
    ; Create platforms
    ; Platform 1: Row 15, columns 10-22 (longer)
    mov eax, 15
    mov ebx, 10
    Plat1Loop:
        push eax
        mov eax, map_width
        imul eax, 15
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 23
        jl Plat1Loop
    
    ; Platform 2: Row 13, columns 28-40
    mov ebx, 28
    Plat2Loop:
        push eax
        mov eax, map_width
        imul eax, 13
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 41
        jl Plat2Loop
    
    ; Platform 3: Row 15, columns 45-57
    mov ebx, 45
    Plat3Loop:
        push eax
        mov eax, map_width
        imul eax, 15
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 58
        jl Plat3Loop
    
    ; Platform 4: Row 11, columns 15-20 (high platform)
    mov ebx, 15
    Plat4Loop:
        push eax
        mov eax, map_width
        imul eax, 11
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 21
        jl Plat4Loop
    
    ; Platform 5: Row 10, columns 50-56 (high platform)
    mov ebx, 50
    Plat5Loop:
        push eax
        mov eax, map_width
        imul eax, 10
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 57
        jl Plat5Loop
    
    ; Add coins on Platform 1
    mov ebx, 11
    Coin1Loop:
        push eax
        mov eax, map_width
        imul eax, 14
        add eax, ebx
        mov [level1_map + eax], 2
        pop eax
        inc ebx
        cmp ebx, 22
        jl Coin1Loop
    
    ; Add coins on Platform 2
    mov ebx, 29
    Coin2Loop:
        push eax
        mov eax, map_width
        imul eax, 12
        add eax, ebx
        mov [level1_map + eax], 2
        pop eax
        inc ebx
        cmp ebx, 40
        jl Coin2Loop
    
    ; Add coins on Platform 3
    mov ebx, 46
    Coin3Loop:
        push eax
        mov eax, map_width
        imul eax, 14
        add eax, ebx
        mov [level1_map + eax], 2
        pop eax
        inc ebx
        cmp ebx, 57
        jl Coin3Loop
    
    ; Add coins on high platform
    mov ebx, 16
    Coin4Loop:
        push eax
        mov eax, map_width
        imul eax, 10
        add eax, ebx
        mov [level1_map + eax], 2
        pop eax
        inc ebx
        cmp ebx, 20
        jl Coin4Loop
    
    ; Place ice flower on high platform
    mov eax, map_width
    imul eax, 9
    add eax, 53
    mov [level1_map + eax], 3
    
    ret
InitializeLevel1 ENDP

; ============================================================
; PROCEDURE: DrawMap
; Draws the current level
; ============================================================
DrawMap PROC
    ; Draw only visible area (skip HUD row)
    mov eax, 1              ; Row counter (start from row 1 to avoid HUD)
    DrawRowLoop:
        mov dh, al
        mov dl, 0
        call Gotoxy
        
        mov ebx, 0          ; Column counter
        DrawColLoop:
            ; Calculate map offset
            push eax
            push ebx
            mov eax, map_width
            imul dword ptr [esp + 4]      ; row * width
            add eax, dword ptr [esp]      ; + col
            mov esi, eax
            pop ebx
            pop eax
            
            ; Get tile type
            movzx ecx, byte ptr [level1_map + esi]
            
            cmp ecx, 0
            je DrawEmpty
            cmp ecx, 1
            je DrawWall
            cmp ecx, 2
            je DrawCoin
            cmp ecx, 3
            je DrawIceFlower
            jmp DrawEmpty
            
            DrawWall:
                push eax
                mov eax, brown + (black*16)
                call SetTextColor
                mov al, 219  ; Solid block
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawCoin:
                push eax
                mov eax, yellow + (black*16)
                call SetTextColor
                mov al, 'o'
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawIceFlower:
                cmp ice_flower_visible, 1
                jne DrawEmpty
                push eax
                mov eax, lightCyan + (black*16)
                call SetTextColor
                mov al, '*'
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawEmpty:
                push eax
                mov eax, white + (black*16)
                call SetTextColor
                mov al, ' '
                call WriteChar
                pop eax
            
            NextTile:
            inc ebx
            cmp ebx, 78          ; Draw 78 columns (most of screen width)
            jl DrawColLoop
        
        inc eax
        cmp eax, 24
        jl DrawRowLoop
    
    ret
DrawMap ENDP

; ============================================================
; PROCEDURE: DrawMario
; Draws Mario at current position (GREEN shirt for roll 2587)
; ============================================================
DrawMario PROC
    mov dl, byte ptr mario_x
    mov dh, byte ptr mario_y
    call Gotoxy
    
    ; Green Mario (odd roll number)
    mov eax, green + (black*16)
    call SetTextColor
    
    cmp facing_right, 1
    je FacingRight
    mov al, 'M'        ; Facing left
    jmp DrawChar
    FacingRight:
    mov al, 'M'        ; Facing right
    
    DrawChar:
    call WriteChar
    ret
DrawMario ENDP

; ============================================================
; PROCEDURE: DrawEnemies
; Draws all active enemies
; ============================================================
DrawEnemies PROC
    ; Draw Goomba 1
    cmp goomba1_alive, 1
    jne SkipGoomba1
    mov dl, byte ptr goomba1_x
    mov dh, byte ptr goomba1_y
    call Gotoxy
    
    ; Check if frozen
    cmp goomba1_frozen, 0
    jle NormalGoomba1
    mov eax, lightCyan + (black*16)
    jmp ColorSet1
    NormalGoomba1:
    mov eax, red + (black*16)
    ColorSet1:
    call SetTextColor
    mov al, '@'
    call WriteChar
    SkipGoomba1:
    
    ; Draw Goomba 2
    cmp goomba2_alive, 1
    jne SkipGoomba2
    mov dl, byte ptr goomba2_x
    mov dh, byte ptr goomba2_y
    call Gotoxy
    
    cmp goomba2_frozen, 0
    jle NormalGoomba2
    mov eax, lightCyan + (black*16)
    jmp ColorSet2
    NormalGoomba2:
    mov eax, red + (black*16)
    ColorSet2:
    call SetTextColor
    mov al, '@'
    call WriteChar
    SkipGoomba2:
    
    ret
DrawEnemies ENDP

; ============================================================
; PROCEDURE: DrawFireballs
; Draws active fireballs (BLUE for Fire Master Mario)
; ============================================================
DrawFireballs PROC
    ; Fireball 1
    cmp fireball1_dir, 0
    je SkipFire1
    mov dl, byte ptr fireball1_x
    mov dh, byte ptr fireball1_y
    call Gotoxy
    mov eax, lightBlue + (black*16)  ; BLUE fireballs (roll 2587)
    call SetTextColor
    mov al, '*'
    call WriteChar
    SkipFire1:
    
    ; Fireball 2
    cmp fireball2_dir, 0
    je SkipFire2
    mov dl, byte ptr fireball2_x
    mov dh, byte ptr fireball2_y
    call Gotoxy
    mov eax, lightBlue + (black*16)
    call SetTextColor
    mov al, '*'
    call WriteChar
    SkipFire2:
    
    ret
DrawFireballs ENDP

; ============================================================
; PROCEDURE: DrawHUD
; Draws score, lives, etc.
; ============================================================
DrawHUD PROC
    ; Save current position
    push eax
    push edx
    
    ; Position at top
    mov dh, 0
    mov dl, 0
    call Gotoxy
    
    mov eax, white + (blue*16)
    call SetTextColor
    
    ; Score
    mov edx, offset socre_txt
    call WriteString
    mov eax, score
    call WriteDec
    
    mov al, ' '
    call WriteChar
    call WriteChar
    
    ; Lives
    mov edx, offset livetxt
    call WriteString
    movzx eax, lives
    call WriteDec
    
    mov al, ' '
    call WriteChar
    call WriteChar
    
    ; Level
    mov edx, offset level_text
    call WriteString
    mov al, '1'
    add al, level
    dec al
    call WriteChar
    
    ; Reset to normal colors
    mov eax, white + (black*16)
    call SetTextColor
    
    pop edx
    pop eax
    ret
DrawHUD ENDP

; ============================================================
; PROCEDURE: CheckCollisionBelow
; Checks if there's a platform below Mario
; Returns: AL = 1 if collision, 0 if no collision
; ============================================================
CheckCollisionBelow PROC
    ; Check tile below Mario
    mov eax, mario_y
    inc eax                ; Look one row below
    cmp eax, map_height
    jge NoCollision
    
    imul eax, map_width
    add eax, mario_x
    
    movzx ecx, byte ptr [level1_map + eax]
    cmp ecx, 1
    je HasCollision
    
    NoCollision:
    mov al, 0
    ret
    
    HasCollision:
    mov al, 1
    ret
CheckCollisionBelow ENDP

; ============================================================
; PROCEDURE: CheckCollisionAbove
; Checks if there's a platform above Mario
; Returns: AL = 1 if collision, 0 if no collision
; ============================================================
CheckCollisionAbove PROC
    ; Check tile above Mario
    mov eax, mario_y
    cmp eax, 0
    jle NoCollisionAbove
    dec eax                ; Look one row above
    
    imul eax, map_width
    add eax, mario_x
    
    movzx ecx, byte ptr [level1_map + eax]
    cmp ecx, 1
    je HasCollisionAbove
    
    NoCollisionAbove:
    mov al, 0
    ret
    
    HasCollisionAbove:
    mov al, 1
    ret
CheckCollisionAbove ENDP

; ============================================================
; PROCEDURE: CheckCollisionAt
; Checks if there's a collision at given position
; Input: EAX = x, EBX = y
; Returns: AL = 1 if collision, 0 if no collision
; ============================================================
CheckCollisionAt PROC
    ; Bounds check
    cmp eax, 0
    jl HasCollision2
    cmp eax, map_width
    jge HasCollision2
    cmp ebx, 0
    jl HasCollision2
    cmp ebx, map_height
    jge HasCollision2
    
    ; Calculate offset
    push eax
    mov eax, ebx
    imul eax, map_width
    pop ebx
    add eax, ebx
    
    movzx ecx, byte ptr [level1_map + eax]
    cmp ecx, 1
    je HasCollision2
    
    mov al, 0
    ret
    
    HasCollision2:
    mov al, 1
    ret
CheckCollisionAt ENDP

; ============================================================
; PROCEDURE: UpdateMarioPhysics
; Handles gravity and jumping
; ============================================================
UpdateMarioPhysics PROC
    ; Always check if Mario is actually on ground (he might have walked off)
    ; First check if there's ground below
    call CheckCollisionBelow
    cmp al, 1
    je StillOnGround
    
    ; No ground below - start falling
    mov mario_on_ground, 0
    jmp ApplyPhysics
    
    StillOnGround:
    ; There IS ground below
    ; If velocity is 0 and we're marked as on ground, no need for physics
    cmp mario_velocity_y, 0
    jne ApplyPhysics
    mov mario_on_ground, 1
    jmp PhysicsDone
    
    ApplyPhysics:
    ; Apply gravity to velocity
    mov eax, mario_velocity_y
    add eax, gravity
    
    ; Limit fall speed
    cmp eax, 3
    jle VelocityOK
    mov eax, 3
    VelocityOK:
    mov mario_velocity_y, eax
    
    ; Check if moving upward (jumping) or downward (falling)
    cmp mario_velocity_y, 0
    jl MovingUp
    jg MovingDown
    jmp PhysicsDone        ; Velocity is 0, no movement
    
    MovingUp:
    ; Check each position as we move up
    mov ecx, mario_velocity_y
    neg ecx                ; Make positive for loop counter
    MoveUpLoop:
        ; Check if platform above current position
        push ecx
        call CheckCollisionAbove
        pop ecx
        cmp al, 1
        je HitPlatformAbove
        
        ; No collision, move up one pixel
        dec mario_y
        loop MoveUpLoop
    
    ; Finished moving up
    mov mario_on_ground, 0
    jmp PhysicsDone
    
    HitPlatformAbove:
    ; Hit platform - stop movement
    mov mario_velocity_y, 0
    mov mario_on_ground, 0
    jmp PhysicsDone
    
    MovingDown:
    ; Check each position as we move down
    mov ecx, mario_velocity_y
    MoveDownLoop:
        ; Check if ground below current position
        push ecx
        call CheckCollisionBelow
        pop ecx
        cmp al, 1
        je HitGround
        
        ; No collision, move down one pixel
        inc mario_y
        loop MoveDownLoop
    
    ; Finished moving down, still in air
    mov mario_on_ground, 0
    jmp PhysicsDone
    
    HitGround:
    ; Hit ground - stop falling
    mov mario_velocity_y, 0
    mov mario_on_ground, 1
    jmp PhysicsDone
    
    PhysicsDone:
    ; Prevent going off screen bottom
    cmp mario_y, 22
    jle NoFix
    mov mario_y, 17
    mov mario_velocity_y, 0
    mov mario_on_ground, 1
    NoFix:
    
    ret
UpdateMarioPhysics ENDP

; ============================================================
; PROCEDURE: HandleInput
; Processes keyboard input
; ============================================================
HandleInput PROC
    call ReadKey
    jz NoInput
    
    mov last_key, al
    
    ; Left - A
    cmp al, 'a'
    je MoveLeft
    cmp al, 'A'
    je MoveLeft
    
    ; Right - D
    cmp al, 'd'
    je MoveRight
    cmp al, 'D'
    je MoveRight
    
    ; Jump - W or Space
    cmp al, 'w'
    je TryJump
    cmp al, 'W'
    je TryJump
    cmp al, ' '
    je TryJump
    
    ; Fire - F
    cmp al, 'f'
    je ShootFireball
    cmp al, 'F'
    je ShootFireball
    
    ; Pause - P
    cmp al, 'p'
    je PauseGame
    cmp al, 'P'
    je PauseGame
    
    ; Quit - Q
    cmp al, 'q'
    je QuitGame
    cmp al, 'Q'
    je QuitGame
    
    jmp NoInput
    
    MoveLeft:
        mov facing_right, 0
        ; Check bounds
        cmp mario_x, 1
        jle NoInput
        ; Check for wall at destination
        mov eax, mario_x
        dec eax
        mov ebx, mario_y
        call CheckCollisionAt
        cmp al, 1
        je NoInput
        ; Can move
        dec mario_x
        jmp NoInput
    
    MoveRight:
        mov facing_right, 1
        ; Check bounds
        cmp mario_x, 76
        jge NoInput
        ; Check for wall at destination
        mov eax, mario_x
        inc eax
        mov ebx, mario_y
        call CheckCollisionAt
        cmp al, 1
        je NoInput
        ; Can move
        inc mario_x
        jmp NoInput
    
    TryJump:
        cmp mario_on_ground, 1
        jne NoInput
        mov eax, mario_jump_power
        mov mario_velocity_y, eax
        mov mario_on_ground, 0
        jmp NoInput
    
    ShootFireball:
        cmp fire_active, 1
        jne NoInput
        ; Find empty fireball slot
        cmp fireball1_dir, 0
        je UseSlot1
        cmp fireball2_dir, 0
        je UseSlot2
        jmp NoInput
        
        UseSlot1:
            mov eax, mario_x
            mov fireball1_x, eax
            mov eax, mario_y
            mov fireball1_y, eax
            ; Set fireball direction based on facing
            cmp facing_right, 1
            je Fire1Right
            mov fireball1_dir, 2    ; Facing left = direction 2
            jmp NoInput
            Fire1Right:
            mov fireball1_dir, 1    ; Facing right = direction 1
            jmp NoInput
        
        UseSlot2:
            mov eax, mario_x
            mov fireball2_x, eax
            mov eax, mario_y
            mov fireball2_y, eax
            ; Set fireball direction based on facing
            cmp facing_right, 1
            je Fire2Right
            mov fireball2_dir, 2    ; Facing left = direction 2
            jmp NoInput
            Fire2Right:
            mov fireball2_dir, 1    ; Facing right = direction 1
            jmp NoInput
    
    PauseGame:
        ; TODO: Implement pause
        jmp NoInput
    
    QuitGame:
        mov game_state, 3
        jmp NoInput
    
    NoInput:
    ret
HandleInput ENDP

; ============================================================
; PROCEDURE: UpdateFireballs
; Moves fireballs and checks collisions
; ============================================================
UpdateFireballs PROC
    ; Update Fireball 1
    cmp fireball1_dir, 0
    je SkipUpdate1
    
    movzx eax, fireball1_dir
    cmp eax, 1              ; Moving right
    jne Fire1Left
    inc fireball1_x
    jmp CheckFire1
    Fire1Left:
    dec fireball1_x
    
    CheckFire1:
    ; Check bounds
    cmp fireball1_x, 0
    jl DeactivateFire1
    cmp fireball1_x, map_width
    jge DeactivateFire1
    jmp SkipUpdate1
    
    DeactivateFire1:
    mov fireball1_dir, 0
    mov fireball1_x, -1
    SkipUpdate1:
    
    ; Update Fireball 2
    cmp fireball2_dir, 0
    je SkipUpdate2
    
    movzx eax, fireball2_dir
    cmp eax, 1
    jne Fire2Left
    inc fireball2_x
    jmp CheckFire2
    Fire2Left:
    dec fireball2_x
    
    CheckFire2:
    cmp fireball2_x, 0
    jl DeactivateFire2
    cmp fireball2_x, map_width
    jge DeactivateFire2
    jmp SkipUpdate2
    
    DeactivateFire2:
    mov fireball2_dir, 0
    mov fireball2_x, -1
    SkipUpdate2:
    
    ret
UpdateFireballs ENDP

; ============================================================
; PROCEDURE: UpdateEnemies
; Moves enemies back and forth
; ============================================================
UpdateEnemies PROC
    ; Update freeze timers
    cmp goomba1_frozen, 0
    jle Goomba1NotFrozen
    dec goomba1_frozen
    Goomba1NotFrozen:
    
    cmp goomba2_frozen, 0
    jle Goomba2NotFrozen
    dec goomba2_frozen
    Goomba2NotFrozen:
    
    ; Move Goomba 1 (patrols ground: columns 20-35)
    cmp goomba1_alive, 1
    jne SkipGoomba1Move
    cmp goomba1_frozen, 0
    jg SkipGoomba1Move
    
    movzx eax, goomba1_dir
    cmp eax, 1
    je Goomba1Right
    ; Moving left
    dec goomba1_x
    cmp goomba1_x, 20
    jge SkipGoomba1Move
    mov goomba1_dir, 1
    jmp SkipGoomba1Move
    Goomba1Right:
    inc goomba1_x
    cmp goomba1_x, 35
    jle SkipGoomba1Move
    mov goomba1_dir, 2
    SkipGoomba1Move:
    
    ; Move Goomba 2 (patrols ground: columns 55-70)
    cmp goomba2_alive, 1
    jne SkipGoomba2Move
    cmp goomba2_frozen, 0
    jg SkipGoomba2Move
    
    movzx eax, goomba2_dir
    cmp eax, 1
    je Goomba2Right
    dec goomba2_x
    cmp goomba2_x, 55
    jge SkipGoomba2Move
    mov goomba2_dir, 1
    jmp SkipGoomba2Move
    Goomba2Right:
    inc goomba2_x
    cmp goomba2_x, 70
    jle SkipGoomba2Move
    mov goomba2_dir, 2
    SkipGoomba2Move:
    
    ret
UpdateEnemies ENDP

; ============================================================
; PROCEDURE: CheckCollisions
; Checks Mario vs enemies, fireballs vs enemies, etc.
; ============================================================
CheckCollisions PROC
    ; Check Mario vs Goomba 1
    cmp goomba1_alive, 1
    jne SkipGoomba1Coll
    mov eax, mario_x
    cmp eax, goomba1_x
    jne SkipGoomba1Coll
    mov eax, mario_y
    cmp eax, goomba1_y
    jne SkipGoomba1Coll
    ; Hit! Check if jumping on it
    cmp mario_velocity_y, 0
    jle MarioHurt1
    ; Jumped on goomba
    mov goomba1_alive, 0
    add score, 100
    mov mario_velocity_y, -4   ; Bounce (matches jump power)
    jmp SkipGoomba1Coll
    MarioHurt1:
    dec lives
    ; Respawn Mario
    mov mario_x, 5
    mov mario_y, 17
    SkipGoomba1Coll:
    
    ; Check Mario vs Goomba 2
    cmp goomba2_alive, 1
    jne SkipGoomba2Coll
    mov eax, mario_x
    cmp eax, goomba2_x
    jne SkipGoomba2Coll
    mov eax, mario_y
    cmp eax, goomba2_y
    jne SkipGoomba2Coll
    cmp mario_velocity_y, 0
    jle MarioHurt2
    mov goomba2_alive, 0
    add score, 100
    mov mario_velocity_y, -4
    jmp SkipGoomba2Coll
    MarioHurt2:
    dec lives
    mov mario_x, 5
    mov mario_y, 17
    SkipGoomba2Coll:
    
    ; Check fireballs vs enemies
    ; Fireball 1 vs Goomba 1
    cmp fireball1_dir, 0
    je SkipFire1Goomba1
    cmp goomba1_alive, 1
    jne SkipFire1Goomba1
    mov eax, fireball1_x
    cmp eax, goomba1_x
    jne SkipFire1Goomba1
    mov eax, fireball1_y
    cmp eax, goomba1_y
    jne SkipFire1Goomba1
    ; Hit!
    mov goomba1_alive, 0
    mov fireball1_dir, 0
    add score, 200
    SkipFire1Goomba1:
    
    ; Fireball 1 vs Goomba 2
    cmp fireball1_dir, 0
    je SkipFire1Goomba2
    cmp goomba2_alive, 1
    jne SkipFire1Goomba2
    mov eax, fireball1_x
    cmp eax, goomba2_x
    jne SkipFire1Goomba2
    mov eax, fireball1_y
    cmp eax, goomba2_y
    jne SkipFire1Goomba2
    mov goomba2_alive, 0
    mov fireball1_dir, 0        ; Fixed: was fireball2_dir
    add score, 200
    SkipFire1Goomba2:
    
    ; Fireball 2 vs Goomba 1
    cmp fireball2_dir, 0
    je SkipFire2Goomba1
    cmp goomba1_alive, 1
    jne SkipFire2Goomba1
    mov eax, fireball2_x
    cmp eax, goomba1_x
    jne SkipFire2Goomba1
    mov eax, fireball2_y
    cmp eax, goomba1_y
    jne SkipFire2Goomba1
    ; Hit!
    mov goomba1_alive, 0
    mov fireball2_dir, 0
    add score, 200
    SkipFire2Goomba1:
    
    ; Fireball 2 vs Goomba 2
    cmp fireball2_dir, 0
    je SkipFire2Goomba2
    cmp goomba2_alive, 1
    jne SkipFire2Goomba2
    mov eax, fireball2_x
    cmp eax, goomba2_x
    jne SkipFire2Goomba2
    mov eax, fireball2_y
    cmp eax, goomba2_y
    jne SkipFire2Goomba2
    mov goomba2_alive, 0
    mov fireball2_dir, 0
    add score, 200
    SkipFire2Goomba2:
    
    ; Check coin collection
    mov eax, mario_y
    imul eax, map_width
    add eax, mario_x
    movzx ecx, byte ptr [level1_map + eax]
    cmp ecx, 2
    jne NoCoin
    ; Collected coin!
    mov byte ptr [level1_map + eax], 0
    add score, 200
    NoCoin:
    
    ; Check ice flower collection
    cmp ecx, 3
    jne NoIceFlower
    mov byte ptr [level1_map + eax], 0
    mov ice_flower_visible, 0
    ; Ice flower effect: freeze enemies
    mov goomba1_frozen, 240    ; ~4 seconds at 60fps
    mov goomba2_frozen, 240
    NoIceFlower:
    
    ret
CheckCollisions ENDP

; ============================================================
; PROCEDURE: PrintMainMenu
; ============================================================
PrintMainMenu PROC
    call Clrscr
    
    mov eax, red + (black*16)
    call SetTextColor
    mov dh, 5
    mov dl, 30
    call Gotoxy
    mov edx, offset title1
    call WriteString
    
    mov eax, yellow + (black*16)
    call SetTextColor
    mov dh, 7
    mov dl, 30
    call Gotoxy
    mov edx, offset myRoll
    call WriteString
    
    mov eax, green + (black*16)
    call SetTextColor
    mov dh, 10
    mov dl, 30
    call Gotoxy
    mov edx, offset play_title
    call WriteString
    
    mov eax, cyan + (black*16)
    call SetTextColor
    mov dh, 12
    mov dl, 30
    call Gotoxy
    mov edx, offset score_prompt
    call WriteString
    
    mov eax, red + (black*16)
    call SetTextColor
    mov dh, 14
    mov dl, 30
    call Gotoxy
    mov edx, offset quitt
    call WriteString
    
    ret
PrintMainMenu ENDP

; ============================================================
; PROCEDURE: GameLoop
; Main game loop
; ============================================================
GameLoop PROC
    ; Initial draw
    call Clrscr
    
    GameLoopStart:
        ; Draw everything
        call DrawMap
        call DrawHUD
        call DrawMario
        call DrawEnemies
        call DrawFireballs
        
        ; Handle input
        call HandleInput
        
        ; Check if quitting
        cmp game_state, 3
        je ExitGame
        
        ; Update physics
        call UpdateMarioPhysics
        
        ; Update game objects
        inc move_counter
        mov eax, move_counter
        and eax, 7              ; Every 8 frames (slower enemies)
        cmp eax, 0
        jne SkipEnemyUpdate
        call UpdateEnemies
        SkipEnemyUpdate:
        
        mov eax, move_counter
        and eax, 3              ; Every 4 frames
        cmp eax, 0
        jne SkipFireballUpdate
        call UpdateFireballs
        SkipFireballUpdate:
        
        ; Check collisions
        call CheckCollisions
        
        ; Check game over
        cmp lives, 0
        jle GameOver
        
        ; Small delay
        mov eax, 30
        call Delay
        
        jmp GameLoopStart
    
    GameOver:
        call Clrscr
        mov eax, red + (black*16)
        call SetTextColor
        mov dh, 12
        mov dl, 35
        call Gotoxy
        mov edx, offset gameOver1
        call WriteString
        
        mov eax, 2000
        call Delay
    
    ExitGame:
    ret
GameLoop ENDP

; ============================================================
; MAIN PROCEDURE
; ============================================================
main PROC
    ; Hide cursor
    mov eax, STD_OUTPUT_HANDLE
    invoke GetStdHandle, eax
    mov esi, offset ConsoleInfo
    invoke SetConsoleCursorInfo, eax, esi
    
    ; Main menu loop
    MenuLoop:
        call PrintMainMenu
        call ReadChar
        
        cmp al, 'p'
        je StartGame
        cmp al, 'P'
        je StartGame
        
        cmp al, 'q'
        je QuitProgram
        cmp al, 'Q'
        je QuitProgram
        
        jmp MenuLoop
    
    StartGame:
        ; Initialize level
        call InitializeLevel1
        
        ; Reset game state
        mov mario_x, 5
        mov mario_y, 17          ; One row above ground (row 18 is ground)
        mov mario_velocity_y, 0
        mov mario_on_ground, 1   ; Start on ground (changed from 0)
        mov lives, 3
        mov score, 0
        mov fire_active, 1      ; Fire Master Mario starts with fire
        mov fireball1_dir, 0
        mov fireball2_dir, 0
        mov goomba1_alive, 1
        mov goomba2_alive, 1
        mov goomba1_frozen, 0
        mov goomba2_frozen, 0
        mov ice_flower_visible, 1
        mov game_state, 1
        mov move_counter, 0
        
        ; Start game
        call GameLoop
        
        jmp MenuLoop
    
    QuitProgram:
    call Clrscr
    invoke ExitProcess, 0
main ENDP

END main
