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

SetConsoleOutputCP PROTO :DWORD
SetConsoleCP PROTO :DWORD

.data
    ConsoleInfo CONSOLE_CURSOR_INFO<1,0>
    
    ; === STUDENT INFO ===
    myName db "Name: Mahd Kazmi",0
    myRoll db "Roll No: 2587",0
    mySection db "Section: B ",0
    
    ; === MENU STRINGS ===
    title1 db "SUPER MARIO BROS",0
    play_title db "Play (P)",0
    score_prompt db "HighScores (H)",0
    quitt db "Quit (Q)",0
    gameOver1 db "GAME OVER",0
    gameWon1 db "Level 1 Completed",0
    instr_title db "INSTRUCTIONS",0
    instr_move db "Move: A/D or Left/Right Arrows",0
    instr_jump db "Jump: W or Space",0
    instr_shoot db "Shoot: F (after fire flower pickup)",0
    instr_pause db "Pause: P ",0
    instr_quit db "Quit: Q",0
    instr_power db "Power-ups: Fire flower = fireballs, Ice flower = freeze",0
    instr_divider db "---------------",0
    level_select_title db "Select Level (1 or 2)",0
    level_select_hint db "Level 2 uses placeholder layout for now",0
    level_select_prompt db "Press 1 or 2 to start",0
    level_opt1 db "1) Level 1 - Grassland ",0
    level_opt2 db "2) Level 2 - In development (placeholder)",0
    
    ; === PAUSE MENU STRINGS ===
    pause_title db "PAUSED",0
    pause_resume db "Resume (R)",0
    pause_quit db "Quit to Menu (Q)",0
    
    ; === MARIO ASCII ART ===
    mario_line1 db "  __  __       __    __      _____      _____      ____       ____      ",0
    mario_line2 db " |  \/  |     /_ |  /_ |    |  __ \    |_   _|    / __ \     / __ \     ",0
    mario_line3 db " | \  / |      | |   | |    | |__) |     | |     | |  | |   | |  | |    ",0
    mario_line4 db " | |\/| |      | |   | |    |  _  /      | |     | |  | |   | |  | |    ",0
    mario_line5 db " | |  | |      | |   | |    | | \ \     _| |_    | |__| |   | |__| |    ",0
    mario_line6 db " |_|  |_|      |_|   |_|    |_|  \_\   |_____|    \____/     \____/     ",0
    
    ; === GAME STRINGS ===
    socre_txt db " Score: ",0
    livetxt db " Lives: ",0
    username_txt db " Player: ",0
    level_text db " World: ",0
    timer_text db " Time: ",0
    
    ; === PLAYER DATA ===
    userName db 20 dup(?)
    userNameSize = 20
    
    mario_x dd 5
    mario_y dd 18
    mario_velocity_y dd 0     ; For jump physics
    mario_on_ground db 1      ; 1 if on ground, 0 if in air
    normal_jump_power dd -4   ; base jump
    super_jump_power dd -5    ; boosted jump
    mario_jump_power dd -4    ; current jump power (mutable)
    gravity = 1               ; Pull down
    mario_speed = 1           ; Movement speed
    
    ; === FIRE MASTER MARIO (Roll 2587 - Last Digit 7) ===
    fire_active db 0          ; Starts without fire until power-up collected
    ice_flower_x dd 15
    ice_flower_y dd 10
    ice_flower_visible db 1
    super_active db 0         ; Super mushroom effect flag
    
    ; Fire flower power-up (random spawn)
    fire_flower_x dd 0
    fire_flower_y dd 0
    fire_flower_visible db 0
    fire_spawn_count = 10
    fire_spawn_coords db \
        16,14, 33,12, 50,14, 18,10, 25,14, \
        52,12, 67,10, 110,15, 120,8, 32,9, 140,17   ; platform positions both levels
    fire_shots_left db 0
    
    ; Super mushroom power-up (random spawn)
    mushroom_x dd 0
    mushroom_y dd 0
    mushroom_visible db 0
    mushroom_spawn_count = 10
    mushroom_spawn_coords db \
        16,14, 33,12, 50,14, 18,10, 25,14, \
        52,12, 67,10, 110,15, 120,8, 32,9, 140,17
    flag_x dd 150
    level_complete db 0
    
    ; === LEVEL 2 FIRE CHAINS ===
    fire_chain1_anchor_x dd 70
    fire_chain1_anchor_y dd 12
    fire_chain2_anchor_x dd 110
    fire_chain2_anchor_y dd 14
    
    ; === MOVING PLATFORMS (Level 2) ===
    moving_plat_count = 3
    moving_plat_x dd 60, 95, 125
    moving_plat_y dd 11, 13, 9
    moving_plat_dir db 1, 2, 1           ; 1=right, 2=left
    moving_plat_left dd 55, 90, 120
    moving_plat_right dd 70, 110, 135
    
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
    
    ; Koopa Troopa (green)
    koopa_x dd 35
    koopa_y dd 17
    koopa_dir db 1            ; 1=right, 2=left
    koopa_state db 0          ; 0=walking,1=shell idle,2=shell left,3=shell right
    koopa_alive db 1
    koopa_frozen dd 0
    
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
    ; 4 = pipe top-left, 5 = pipe top-right, 6 = pipe vertical side
    ; 7 = warp pipe entrance, 8 = pipe top-middle, 9 = pipe body fill
    ; 10 = fire flower (grants fireballs), 11 = cloud (decoration)
    ; 12 = flag pole, 13 = flag top, 14 = lava, 15 = super mushroom
    map_width = 160
    map_height = 24
    viewport_width = 78
    
    ; Simplified level map (we'll build this procedurally)
    level1_map db (map_height * map_width) dup(0)
    
    ; === CAMERA ===
    camera_x dd 0
    
    ; === TIMING ===
    move_counter dd 0
    enemy_counter dd 0
    fireball_counter dd 0
    game_timer dd 0          ; Game timer in seconds
    frame_counter dd 0       ; Frame counter for timer
    
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
    
    ; Platform 6: Row 14, columns 90-108
    mov ebx, 90
    Plat6Loop:
        push eax
        mov eax, map_width
        imul eax, 14
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 109
        jl Plat6Loop
    
    ; Platform 7: Row 12, columns 118-134
    mov ebx, 118
    Plat7Loop:
        push eax
        mov eax, map_width
        imul eax, 12
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 135
        jl Plat7Loop
    
    ; Platform 8: Row 16, columns 136-148 (approach to flag)
    mov ebx, 136
    Plat8Loop:
        push eax
        mov eax, map_width
        imul eax, 16
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 149
        jl Plat8Loop
    
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
    
    ; Coins on Platform 6
    mov ebx, 92
    Coin6Loop:
        push eax
        mov eax, map_width
        imul eax, 13
        add eax, ebx
        mov [level1_map + eax], 2
        pop eax
        inc ebx
        cmp ebx, 107
        jl Coin6Loop
    
    ; Coins on Platform 7
    mov ebx, 120
    Coin7Loop:
        push eax
        mov eax, map_width
        imul eax, 11
        add eax, ebx
        mov [level1_map + eax], 2
        pop eax
        inc ebx
        cmp ebx, 133
        jl Coin7Loop
    
    ; Place ice flower on high platform
    mov eax, map_width
    imul eax, 9
    add eax, 53
    mov [level1_map + eax], 3
    
    ; Place fire flower randomly on platforms
    mov fire_flower_visible, 1
    mov eax, fire_spawn_count
    call RandomRange                 ; 0..count-1
    mov edi, eax
    mov ecx, fire_spawn_count
FireFind1:
    cmp ecx, 0
    jle FirePlace1
    mov ebx, edi
    shl ebx, 1
    movzx eax, byte ptr [fire_spawn_coords + ebx]
    mov fire_flower_x, eax
    movzx eax, byte ptr [fire_spawn_coords + ebx + 1]
    mov fire_flower_y, eax
    mov eax, fire_flower_y
    imul eax, map_width
    add eax, fire_flower_x
    movzx ebx, byte ptr [level1_map + eax]
    cmp ebx, 1              ; ensure platform tile
    je FirePlace1
    inc edi
    cmp edi, fire_spawn_count
    jl FireCont1
    mov edi, 0
FireCont1:
    dec ecx
    jmp FireFind1
FirePlace1:
    mov eax, fire_flower_y
    imul eax, map_width
    add eax, fire_flower_x
    mov byte ptr [level1_map + eax], 10
    
    ; Place mushroom randomly on platforms
    mov mushroom_visible, 1
    mov eax, mushroom_spawn_count
    call RandomRange
    mov edi, eax
    mov ecx, mushroom_spawn_count
MushFind1:
    cmp ecx, 0
    jle MushPlace1
    mov ebx, edi
    shl ebx, 1
    movzx eax, byte ptr [mushroom_spawn_coords + ebx]
    mov mushroom_x, eax
    movzx eax, byte ptr [mushroom_spawn_coords + ebx + 1]
    mov mushroom_y, eax
    mov eax, mushroom_y
    imul eax, map_width
    add eax, mushroom_x
    movzx ebx, byte ptr [level1_map + eax]
    cmp ebx, 1
    je MushPlace1
    inc edi
    cmp edi, mushroom_spawn_count
    jl MushCont1
    mov edi, 0
MushCont1:
    dec ecx
    jmp MushFind1
MushPlace1:
    mov eax, mushroom_y
    imul eax, map_width
    add eax, mushroom_x
    mov byte ptr [level1_map + eax], 15
    
    ; Add decorative clouds (non-colliding) only for level 1
    cmp level, 1
    jne SkipClouds
        ; Cloud 1 (x=12..14, y=5..6)
        mov eax, map_width
        imul eax, 5
        add eax, 12
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        mov eax, map_width
        imul eax, 6
        add eax, 13
        mov byte ptr [level1_map + eax], 11
        
        ; Cloud 2 (x=42..45, y=4..5)
        mov eax, map_width
        imul eax, 4
        add eax, 42
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        mov eax, map_width
        imul eax, 5
        add eax, 43
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        
        ; Cloud 3 (x=68..70, y=6..7)
        mov eax, map_width
        imul eax, 6
        add eax, 68
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        mov eax, map_width
        imul eax, 7
        add eax, 69
        mov byte ptr [level1_map + eax], 11
        
        ; Cloud 4 (x=100..103, y=5..6)
        mov eax, map_width
        imul eax, 5
        add eax, 100
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        mov eax, map_width
        imul eax, 6
        add eax, 101
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        
        ; Cloud 5 (x=125..127, y=4..5)
        mov eax, map_width
        imul eax, 4
        add eax, 125
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        inc eax
        mov byte ptr [level1_map + eax], 11
        mov eax, map_width
        imul eax, 5
        add eax, 126
        mov byte ptr [level1_map + eax], 11
    SkipClouds:
    
    ; === Add Pipes ===
    ; Pipe 1: Medium pipe at x=40, starting at y=15 (3 blocks tall)
    ; Top
    mov eax, map_width
    imul eax, 15
    add eax, 40
    mov [level1_map + eax], 4
    inc eax
    mov [level1_map + eax], 8
    inc eax
    mov [level1_map + eax], 5
    ; Body row 1
    mov eax, map_width
    imul eax, 16
    add eax, 40
    mov [level1_map + eax], 6
    inc eax
    mov [level1_map + eax], 9
    inc eax
    mov [level1_map + eax], 6
    ; Body row 2
    mov eax, map_width
    imul eax, 17
    add eax, 40
    mov [level1_map + eax], 6
    inc eax
    mov [level1_map + eax], 9
    inc eax
    mov [level1_map + eax], 6
    
    ; Pipe 2: Tall warp pipe at x=65, starting at y=14 (4 blocks tall)
    ; Top
    mov eax, map_width
    imul eax, 14
    add eax, 65
    mov [level1_map + eax], 4
    inc eax
    mov [level1_map + eax], 8
    inc eax
    mov [level1_map + eax], 5
    ; Body row 1
    mov eax, map_width
    imul eax, 15
    add eax, 65
    mov [level1_map + eax], 6
    inc eax
    mov [level1_map + eax], 9
    inc eax
    mov [level1_map + eax], 6
    ; Body row 2 with warp entrance
    mov eax, map_width
    imul eax, 16
    add eax, 65
    mov [level1_map + eax], 6
    inc eax
    mov [level1_map + eax], 7    ; Warp entrance
    inc eax
    mov [level1_map + eax], 6
    ; Body row 3
    mov eax, map_width
    imul eax, 17
    add eax, 65
    mov [level1_map + eax], 6
    inc eax
    mov [level1_map + eax], 9
    inc eax
    mov [level1_map + eax], 6
    
    ; Flagpole near end (x=flag_x, y=8..17) - level 1
    mov ebx, 8
FlagPoleLoopL1:
    mov ecx, map_width
    imul ecx, ebx
    add ecx, flag_x
    mov byte ptr [level1_map + ecx], 12
    inc ebx
    cmp ebx, 18
    jl FlagPoleLoopL1
    
    ; Flag top (x=flag_x-1, y=8)
    mov eax, map_width
    imul eax, 8
    add eax, flag_x
    dec eax
    mov byte ptr [level1_map + eax], 13
    
    ; Reset level completion flag
    mov level_complete, 0
    
    ret
InitializeLevel1 ENDP

; ============================================================
; PROCEDURE: InitializeLevel2
; Placeholder: currently reuses level 1 layout
; ============================================================
InitializeLevel2 PROC
    mov level, 2
    
    ; Clear map
    mov ecx, map_height * map_width
    mov esi, 0
    ClearLoop2:
        mov [level1_map + esi], 0
        inc esi
        loop ClearLoop2
    
    ; Ground (stone) rows 18-23
    mov eax, 18
    GroundLoop2:
        mov ebx, 0
        GroundColLoop2:
            push eax
            mov eax, map_width
            imul eax, dword ptr [esp]
            add eax, ebx
            mov [level1_map + eax], 1
            pop eax
            
            inc ebx
            cmp ebx, map_width
            jl GroundColLoop2
        inc eax
        cmp eax, map_height
        jl GroundLoop2
    
    ; Ceiling stone rows (rows 1-2) to give a cave feel
    mov eax, 1
    CeilRowLoop2:
        mov ebx, 0
        CeilColLoop2:
            push eax
            mov eax, map_width
            imul eax, dword ptr [esp]
            add eax, ebx
            mov [level1_map + eax], 1
            pop eax
            
            inc ebx
            cmp ebx, map_width
            jl CeilColLoop2
        inc eax
        cmp eax, 3
        jl CeilRowLoop2
    
    ; Place fire flower randomly (level 2) on platforms
    mov fire_flower_visible, 1
    mov eax, fire_spawn_count
    call RandomRange
    mov edi, eax
    mov ecx, fire_spawn_count
FireFind2:
    cmp ecx, 0
    jle FirePlace2
    mov ebx, edi
    shl ebx, 1
    movzx eax, byte ptr [fire_spawn_coords + ebx]
    mov fire_flower_x, eax
    movzx eax, byte ptr [fire_spawn_coords + ebx + 1]
    mov fire_flower_y, eax
    mov eax, fire_flower_y
    imul eax, map_width
    add eax, fire_flower_x
    movzx ebx, byte ptr [level1_map + eax]
    cmp ebx, 1
    je FirePlace2
    inc edi
    cmp edi, fire_spawn_count
    jl FireCont2
    mov edi, 0
FireCont2:
    dec ecx
    jmp FireFind2
FirePlace2:
    mov eax, fire_flower_y
    imul eax, map_width
    add eax, fire_flower_x
    mov byte ptr [level1_map + eax], 10
    
    ; Place mushroom randomly (level 2) on platforms
    mov mushroom_visible, 1
    mov eax, mushroom_spawn_count
    call RandomRange
    mov edi, eax
    mov ecx, mushroom_spawn_count
MushFind2:
    cmp ecx, 0
    jle MushPlace2
    mov ebx, edi
    shl ebx, 1
    movzx eax, byte ptr [mushroom_spawn_coords + ebx]
    mov mushroom_x, eax
    movzx eax, byte ptr [mushroom_spawn_coords + ebx + 1]
    mov mushroom_y, eax
    mov eax, mushroom_y
    imul eax, map_width
    add eax, mushroom_x
    movzx ebx, byte ptr [level1_map + eax]
    cmp ebx, 1
    je MushPlace2
    inc edi
    cmp edi, mushroom_spawn_count
    jl MushCont2
    mov edi, 0
MushCont2:
    dec ecx
    jmp MushFind2
MushPlace2:
    mov eax, mushroom_y
    imul eax, map_width
    add eax, mushroom_x
    mov byte ptr [level1_map + eax], 15
    
    ; Lava pits
    ; Pit 1: columns 36-37 (very narrow)
    mov ebx, 36
    Lava1Loop:
        mov eax, 18
        Lava1Rows:
            push eax
            mov eax, map_width
            imul eax, dword ptr [esp]
            add eax, ebx
            mov byte ptr [level1_map + eax], 14
            pop eax
            inc eax
            cmp eax, 24
            jl Lava1Rows
        inc ebx
        cmp ebx, 38
        jl Lava1Loop
    
    ; Pit 2: columns 87-88 (very narrow)
    mov ebx, 87
    Lava2Loop:
        mov eax, 18
        Lava2Rows:
            push eax
            mov eax, map_width
            imul eax, dword ptr [esp]
            add eax, ebx
            mov byte ptr [level1_map + eax], 14
            pop eax
            inc eax
            cmp eax, 24
            jl Lava2Rows
        inc ebx
        cmp ebx, 89
        jl Lava2Loop
    
    ; Pit 3 (boss bridge lava): columns 138-158
    mov ebx, 138
    Lava3Loop:
        mov eax, 18
        Lava3Rows:
            push eax
            mov eax, map_width
            imul eax, dword ptr [esp]
            add eax, ebx
            mov byte ptr [level1_map + eax], 14
            pop eax
            inc eax
            cmp eax, 24
            jl Lava3Rows
        inc ebx
        cmp ebx, 159
        jl Lava3Loop
    
    ; Stone platforms
    ; Platform A: Row 14, columns 10-28
    mov ebx, 10
    PlatA:
        push eax
        mov eax, map_width
        imul eax, 14
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 29
        jl PlatA
    
    ; Platform B: Row 12, columns 48-60
    mov ebx, 48
    PlatB:
        push eax
        mov eax, map_width
        imul eax, 12
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 61
        jl PlatB
    
    ; Platform C: Row 15, columns 100-120
    mov ebx, 100
    PlatC:
        push eax
        mov eax, map_width
        imul eax, 15
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 121
        jl PlatC
    
    ; Small stone platforms (Level 2 extras)
    ; PlatD: Row 9, columns 30-34
    mov ebx, 30
    PlatD:
        push eax
        mov eax, map_width
        imul eax, 9
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 35
        jl PlatD
    
    ; PlatE: Row 10, columns 65-69
    mov ebx, 65
    PlatE:
        push eax
        mov eax, map_width
        imul eax, 10
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 70
        jl PlatE
    
    ; PlatF: Row 8, columns 118-122 (near boss area approach)
    mov ebx, 118
    PlatF:
        push eax
        mov eax, map_width
        imul eax, 8
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 123
        jl PlatF
    
    ; Boss bridge over lava (row 17, columns 140-156)
    mov ebx, 140
    BridgeLoop:
        push eax
        mov eax, map_width
        imul eax, 17
        add eax, ebx
        mov [level1_map + eax], 1
        pop eax
        inc ebx
        cmp ebx, 157
        jl BridgeLoop
    
    ; Flagpole near end (x=flag_x, y=8..17)
    mov ebx, 8
FlagPoleLoopL2:
    mov ecx, map_width
    imul ecx, ebx
    add ecx, flag_x
    mov byte ptr [level1_map + ecx], 12
    inc ebx
    cmp ebx, 18
    jl FlagPoleLoopL2
    
    ; Flag top (x=flag_x-1, y=8)
    mov eax, map_width
    imul eax, 8
    add eax, flag_x
    dec eax
    mov byte ptr [level1_map + eax], 13
    
    ; Reset completion
    mov level_complete, 0
    
    ret
InitializeLevel2 ENDP

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
        
    mov ebx, 0          ; Column counter (screen space)
        DrawColLoop:
            ; Calculate map offset with camera
            mov esi, camera_x
            add esi, ebx                  ; map_x = camera_x + screen_col
            cmp esi, map_width
            jge DrawEmpty
            
            push eax
            push ebx
            mov eax, map_width
            imul dword ptr [esp + 4]      ; row * width
            add eax, esi                  ; + map_x
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
            cmp ecx, 4
            je DrawPipeTopLeft
            cmp ecx, 5
            je DrawPipeTopRight
            cmp ecx, 6
            je DrawPipeVertical
            cmp ecx, 7
            je DrawWarpPipe
            cmp ecx, 8
            je DrawPipeTopMid
            cmp ecx, 9
            je DrawPipeFill
            cmp ecx, 10
            je DrawFireFlower
            cmp ecx, 11
            je DrawCloud
    cmp ecx, 12
    je DrawFlagPole
    cmp ecx, 13
    je DrawFlagTop
    cmp ecx, 14
    je DrawLava
    cmp ecx, 15
    je DrawMushroom
            jmp DrawEmpty
            
            DrawWall:
                push eax
                cmp level, 2
                jne WallLevel1
                mov eax, lightGray + (black*16)
                jmp WallColorDone
                WallLevel1:
                mov eax, brown + (blue*16)
                WallColorDone:
                call SetTextColor
                mov al, 219  ; Solid block
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawCoin:
                push eax
                cmp level, 2
                jne CoinLevel1
                mov eax, yellow + (black*16)
                jmp CoinColorDone
                CoinLevel1:
                mov eax, yellow + (blue*16)
                CoinColorDone:
                call SetTextColor
                mov al, 'o'
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawIceFlower:
                cmp ice_flower_visible, 1
                jne DrawEmpty
                push eax
                cmp level, 2
                jne IceLevel1
                mov eax, lightCyan + (black*16)
                jmp IceColorDone
                IceLevel1:
                mov eax, lightCyan + (blue*16)
                IceColorDone:
                call SetTextColor
                mov al, '*'
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawFireFlower:
                cmp fire_flower_visible, 1
                jne DrawEmpty
                push eax
                cmp level, 2
                jne FireFlw1
                mov eax, lightRed + (black*16)
                jmp FireFlwSet
                FireFlw1:
                mov eax, lightRed + (blue*16)
                FireFlwSet:
                call SetTextColor
                mov al, 'F'
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawCloud:
                push eax
                cmp level, 2
                jne CloudL1
                mov eax, white + (black*16)
                jmp CloudSet
                CloudL1:
                mov eax, white + (blue*16)
                CloudSet:
                call SetTextColor
                mov al, 219        ; solid block for compact bright cloud
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawLava:
                push eax
                mov eax, lightRed + (black*16)
                call SetTextColor
                mov al, 247        ; medium shade
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawMushroom:
                push eax
                mov eax, red + (black*16)
                call SetTextColor
                mov al, 'U'
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawFlagPole:
                push eax
                mov eax, white + (blue*16)
                call SetTextColor
                mov al, 179        ; vertical line
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawFlagTop:
                push eax
                mov eax, lightGreen + (blue*16)
                call SetTextColor
                mov al, '>'        ; simple flag head
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawPipeTopLeft:
                push eax
                cmp level, 2
                jne PipeL1
                mov eax, green + (black*16)
                jmp PipeSet1
                PipeL1:
                mov eax, green + (blue*16)
                PipeSet1:
                call SetTextColor
                mov al, 201  ; ╔
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawPipeTopRight:
                push eax
                cmp level, 2
                jne PipeR1
                mov eax, green + (black*16)
                jmp PipeSet2
                PipeR1:
                mov eax, green + (blue*16)
                PipeSet2:
                call SetTextColor
                mov al, 187  ; ╗
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawPipeTopMid:
                push eax
                cmp level, 2
                jne PipeM1
                mov eax, green + (black*16)
                jmp PipeSet3
                PipeM1:
                mov eax, green + (blue*16)
                PipeSet3:
                call SetTextColor
                mov al, 205  ; ═
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawPipeVertical:
                push eax
                cmp level, 2
                jne PipeV1
                mov eax, green + (black*16)
                jmp PipeSet4
                PipeV1:
                mov eax, green + (blue*16)
                PipeSet4:
                call SetTextColor
                mov al, 186  ; ║
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawPipeFill:
                push eax
                cmp level, 2
                jne PipeF1
                mov eax, green + (black*16)
                jmp PipeSet5
                PipeF1:
                mov eax, green + (blue*16)
                PipeSet5:
                call SetTextColor
                mov al, 219  ; █
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawWarpPipe:
                push eax
                mov eax, lightGreen + (blue*16)
                call SetTextColor
                mov al, 254  ; ■ (warp entrance)
                call WriteChar
                pop eax
                jmp NextTile
            
            DrawEmpty:
                push eax
                cmp level, 2
                jne EmptyL1
                mov eax, white + (black*16)
                jmp EmptySet
                EmptyL1:
                mov eax, white + (blue*16)
                EmptySet:
                call SetTextColor
                mov al, ' '
                call WriteChar
                pop eax
            
            NextTile:
            inc ebx
            cmp ebx, viewport_width
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
    ; Convert world to screen using camera
    mov eax, mario_x
    sub eax, camera_x
    cmp eax, 0
    jl SkipMarioDraw
    cmp eax, viewport_width
    jge SkipMarioDraw
    mov dl, al
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
    SkipMarioDraw:
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
    mov eax, goomba1_x
    sub eax, camera_x
    cmp eax, 0
    jl SkipGoomba1
    cmp eax, viewport_width
    jge SkipGoomba1
    mov dl, al
    mov dh, byte ptr goomba1_y
    call Gotoxy
    
    ; Check if frozen
    cmp goomba1_frozen, 0
    jle NormalGoomba1
    mov eax, lightCyan + (blue*16)
    jmp ColorSet1
    NormalGoomba1:
    mov eax, red + (blue*16)
    ColorSet1:
    call SetTextColor
    mov al, '@'
    call WriteChar
    SkipGoomba1:
    
    ; Draw Goomba 2
    cmp goomba2_alive, 1
    jne SkipGoomba2
    mov eax, goomba2_x
    sub eax, camera_x
    cmp eax, 0
    jl SkipGoomba2
    cmp eax, viewport_width
    jge SkipGoomba2
    mov dl, al
    mov dh, byte ptr goomba2_y
    call Gotoxy
    
    cmp goomba2_frozen, 0
    jle NormalGoomba2
    mov eax, lightCyan + (blue*16)
    jmp ColorSet2
    NormalGoomba2:
    mov eax, red + (blue*16)
    ColorSet2:
    call SetTextColor
    mov al, '@'
    call WriteChar
    SkipGoomba2:
    
    ; Draw Koopa Troopa
    cmp koopa_alive, 1
    jne SkipKoopa
    mov eax, koopa_x
    sub eax, camera_x
    cmp eax, 0
    jl SkipKoopa
    cmp eax, viewport_width
    jge SkipKoopa
    mov dl, al
    mov dh, byte ptr koopa_y
    call Gotoxy
    
    cmp koopa_frozen, 0
    jle KoopaColorNormal
    mov eax, lightCyan + (blue*16)
    jmp KoopaColorSet
    KoopaColorNormal:
    movzx eax, koopa_state
    cmp eax, 0
    je KoopaGreen
    mov eax, yellow + (blue*16)   ; Shell colors
    jmp KoopaColorSet
    KoopaGreen:
    mov eax, green + (blue*16)
    KoopaColorSet:
    call SetTextColor
    
    movzx eax, koopa_state
    cmp eax, 0
    je DrawKoopaWalk
    DrawKoopaShell:
    mov al, 'O'
    call WriteChar
    jmp SkipKoopa
    DrawKoopaWalk:
    mov al, 'K'
    call WriteChar
    SkipKoopa:
    
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
    mov eax, fireball1_x
    sub eax, camera_x
    cmp eax, 0
    jl SkipFire1
    cmp eax, viewport_width
    jge SkipFire1
    mov dl, al
    mov dh, byte ptr fireball1_y
    call Gotoxy
    mov eax, lightCyan + (blue*16)  ; BLUE fireballs on sky
    call SetTextColor
    mov al, '*'
    call WriteChar
    SkipFire1:
    
    ; Fireball 2
    cmp fireball2_dir, 0
    je SkipFire2
    mov eax, fireball2_x
    sub eax, camera_x
    cmp eax, 0
    jl SkipFire2
    cmp eax, viewport_width
    jge SkipFire2
    mov dl, al
    mov dh, byte ptr fireball2_y
    call Gotoxy
    mov eax, lightCyan + (blue*16)
    call SetTextColor
    mov al, '*'
    call WriteChar
    SkipFire2:
    
    ret
DrawFireballs ENDP

; ============================================================
; PROCEDURE: DrawMovingPlatforms (Level 2)
; ============================================================
DrawMovingPlatforms PROC
    cmp level, 2
    jne SkipMovePlatDraw
    
    mov ecx, 0
PlatDrawLoop:
    cmp ecx, moving_plat_count
    jge SkipMovePlatDraw
    
    mov eax, [moving_plat_x + ecx*4]
    sub eax, camera_x
    cmp eax, 0
    jl NextPlatDraw
    cmp eax, viewport_width
    jge NextPlatDraw
    mov dl, al
    mov edx, [moving_plat_y + ecx*4]
    mov dh, dl    ; temp? fix below
    mov dh, byte ptr [moving_plat_y + ecx*4]
    call Gotoxy
    mov eax, lightGray + (black*16) ; match stone platform color
    call SetTextColor
    mov al, 219                ; solid block like normal platforms
    call WriteChar
NextPlatDraw:
    inc ecx
    jmp PlatDrawLoop
    
SkipMovePlatDraw:
    ret
DrawMovingPlatforms ENDP

; ============================================================
; PROCEDURE: DrawBoss (Level 2)
; Simple static boss render
; ============================================================
DrawBoss PROC
    cmp level, 2
    jne SkipBoss
    cmp boss_alive, 1
    jne SkipBoss
    
    mov eax, boss_x
    sub eax, camera_x
    cmp eax, 0
    jl SkipBoss
    cmp eax, viewport_width
    jge SkipBoss
    mov dl, al
    mov dh, byte ptr boss_y
    call Gotoxy
    mov eax, red + (black*16)
    call SetTextColor
    mov al, 'B'
    call WriteChar
SkipBoss:
    ret
DrawBoss ENDP

; ============================================================
; PROCEDURE: DrawFireChains (Level 2)
; Renders rotating fire chains anchored at fixed points
; ============================================================
DrawFireChains PROC
    cmp level, 2
    jne NoChains
    
    ; phase cycles every few frames using move_counter
    mov eax, move_counter
    shr eax, 2
    and eax, 3
    mov bl, al                 ; phase for chain1
    ; chain 1
    push ebx
    push eax
    push edx
    push ecx
    push esi
    push edi
    
    mov esi, fire_chain1_anchor_x
    mov edi, fire_chain1_anchor_y
    call DrawOneChain
    
    ; chain 2 (phase offset +1)
    mov eax, move_counter
    shr eax, 2
    inc eax
    and eax, 3
    mov bl, al
    mov esi, fire_chain2_anchor_x
    mov edi, fire_chain2_anchor_y
    call DrawOneChain
    
    pop edi
    pop esi
    pop ecx
    pop edx
    pop eax
    pop ebx
NoChains:
    ret
DrawFireChains ENDP

; Helper: DrawOneChain
; Inputs: esi = anchor_x, edi = anchor_y, bl = phase (0R,1D,2L,3U)
DrawOneChain PROC
    ; length = 3 fireballs
    mov ecx, 1
ChainLoop:
    mov eax, esi
    mov edx, edi
    cmp bl, 0
    je ChainRight
    cmp bl, 1
    je ChainDown
    cmp bl, 2
    je ChainLeft
    ; up
    sub edx, ecx
    jmp ChainPosReady
ChainRight:
    add eax, ecx
    jmp ChainPosReady
ChainDown:
    add edx, ecx
    jmp ChainPosReady
ChainLeft:
    sub eax, ecx
ChainPosReady:
    ; cull to viewport
    sub eax, camera_x
    cmp eax, 0
    jl SkipBall
    cmp eax, viewport_width
    jge SkipBall
    mov edx, edi
    mov dh, dl
    mov dl, al
    call Gotoxy
    mov eax, lightRed + (black*16)
    call SetTextColor
    mov al, 'o'
    call WriteChar
SkipBall:
    inc ecx
    cmp ecx, 4
    jle ChainLoop
    ret
DrawOneChain ENDP

; ============================================================
; PROCEDURE: CheckFireChainHit
; Returns AL=1 if Mario intersects a chain fireball (level 2 only)
; ============================================================
CheckFireChainHit PROC
    cmp level, 2
    jne NoHitChain
    
    ; chain 1 phase
    mov eax, move_counter
    shr eax, 2
    and eax, 3
    mov bl, al
    mov esi, fire_chain1_anchor_x
    mov edi, fire_chain1_anchor_y
    call CheckOneChainHit
    cmp al, 1
    je HitChain
    
    ; chain 2 phase (offset +1)
    mov eax, move_counter
    shr eax, 2
    inc eax
    and eax, 3
    mov bl, al
    mov esi, fire_chain2_anchor_x
    mov edi, fire_chain2_anchor_y
    call CheckOneChainHit
    cmp al, 1
    je HitChain
    
    jmp NoHitChain
    
HitChain:
    mov al, 1
    ret
NoHitChain:
    mov al, 0
    ret
CheckFireChainHit ENDP

; Helper: CheckOneChainHit
; Inputs: esi = anchor_x, edi = anchor_y, bl = phase
; Output: AL=1 if Mario intersects
CheckOneChainHit PROC
    mov ecx, 1
ChainHitLoop:
    mov eax, esi
    mov edx, edi
    cmp bl, 0
    je CRight
    cmp bl, 1
    je CDown
    cmp bl, 2
    je CLeft
    ; up
    sub edx, ecx
    jmp CPosReady
CRight:
    add eax, ecx
    jmp CPosReady
CDown:
    add edx, ecx
    jmp CPosReady
CLeft:
    sub eax, ecx
CPosReady:
    cmp eax, mario_x
    jne NextChainBall
    cmp edx, mario_y
    jne NextChainBall
    mov al, 1
    ret
NextChainBall:
    inc ecx
    cmp ecx, 4
    jle ChainHitLoop
    mov al, 0
    ret
CheckOneChainHit ENDP

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
    
    mov al, ' '
    call WriteChar
    call WriteChar
    
    ; Timer (display as M:SS format)
    mov edx, offset timer_text
    call WriteString
    
    ; Calculate minutes and seconds
    mov eax, game_timer
    mov ebx, 60
    xor edx, edx
    div ebx                 ; EAX = minutes, EDX = seconds
    
    ; Display minutes
    call WriteDec
    mov al, ':'
    call WriteChar
    
    ; Display seconds with leading zero if needed
    mov eax, edx
    cmp eax, 10
    jge NoLeadingZero
    push eax
    mov al, '0'
    call WriteChar
    pop eax
    NoLeadingZero:
    call WriteDec
    
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
    cmp ecx, 1             ; Platform
    je HasCollision
    cmp ecx, 4             ; Pipe top-left
    je HasCollision
    cmp ecx, 5             ; Pipe top-right
    je HasCollision
    cmp ecx, 6             ; Pipe vertical side
    je HasCollision
    cmp ecx, 7             ; Warp entrance
    je HasCollision
    cmp ecx, 8             ; Pipe top-middle
    je HasCollision
    cmp ecx, 9             ; Pipe body fill
    je HasCollision
    ; Moving platforms (level 2)
    cmp level, 2
    jne NoMovePlatB
    mov ecx, 0
CheckBelowMovePlatLoop:
    cmp ecx, moving_plat_count
    jge NoMovePlatB
    mov eax, mario_x
    cmp eax, [moving_plat_x + ecx*4]
    jne NextMovePlatB
    mov eax, mario_y
    inc eax
    cmp eax, [moving_plat_y + ecx*4]
    jne NextMovePlatB
    mov al, 1
    ret
NextMovePlatB:
    inc ecx
    jmp CheckBelowMovePlatLoop
NoMovePlatB:
    
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
    cmp ecx, 1             ; Platform
    je HasCollisionAbove
    cmp ecx, 4             ; Pipe top-left
    je HasCollisionAbove
    cmp ecx, 5             ; Pipe top-right
    je HasCollisionAbove
    cmp ecx, 6             ; Pipe vertical
    je HasCollisionAbove
    cmp ecx, 7             ; Warp entrance
    je HasCollisionAbove
    cmp ecx, 8             ; Pipe top-middle
    je HasCollisionAbove
    cmp ecx, 9             ; Pipe body fill
    je HasCollisionAbove
    ; Moving platforms (level 2)
    cmp level, 2
    jne NoMovePlatA
    mov ecx, 0
CheckAboveMovePlatLoop:
    cmp ecx, moving_plat_count
    jge NoMovePlatA
    mov eax, mario_x
    cmp eax, [moving_plat_x + ecx*4]
    jne NextMovePlatA
    mov eax, mario_y
    dec eax
    cmp eax, [moving_plat_y + ecx*4]
    jne NextMovePlatA
    mov al, 1
    ret
NextMovePlatA:
    inc ecx
    jmp CheckAboveMovePlatLoop
NoMovePlatA:
    
    NoCollisionAbove:
    mov al, 0
    ret
    
    HasCollisionAbove:
    mov al, 1
    ret
CheckCollisionAbove ENDP

; ============================================================
; PROCEDURE: UpdateCamera
; Keeps camera centered on Mario within map bounds
; ============================================================
UpdateCamera PROC
    ; desired = mario_x - viewport_width/2 (approx)
    mov eax, mario_x
    sub eax, 39                 ; viewport_width/2 rounded
    cmp eax, 0
    jge CameraClampMax
    mov eax, 0
CameraClampMax:
    mov ebx, map_width
    sub ebx, viewport_width
    cmp eax, ebx
    jle CameraSet
    mov eax, ebx
CameraSet:
    mov camera_x, eax
    ret
UpdateCamera ENDP

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
    cmp ecx, 1             ; Platform
    je HasCollision2
    cmp ecx, 4             ; Pipe top-left
    je HasCollision2
    cmp ecx, 5             ; Pipe top-right
    je HasCollision2
    cmp ecx, 6             ; Pipe vertical
    je HasCollision2
    cmp ecx, 7             ; Warp entrance
    je HasCollision2
    cmp ecx, 8             ; Pipe top-middle
    je HasCollision2
    cmp ecx, 9             ; Pipe body fill
    je HasCollision2
    ; Moving platforms (level 2)
    cmp level, 2
    jne NoMovePlatAt
    mov ecx, 0
CheckAtMovePlatLoop:
    cmp ecx, moving_plat_count
    jge NoMovePlatAt
    cmp eax, [moving_plat_x + ecx*4]
    jne NextMovePlatAt
    cmp ebx, [moving_plat_y + ecx*4]
    jne NextMovePlatAt
    mov al, 1
    ret
NextMovePlatAt:
    inc ecx
    jmp CheckAtMovePlatLoop
NoMovePlatAt:
    
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
        mov eax, map_width
        sub eax, 2
        cmp mario_x, eax
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
        cmp fire_shots_left, 0
        jle NoInput
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
            dec fire_shots_left
            cmp fire_shots_left, 0
            jg NoInput
            mov fire_active, 0
            jmp NoInput
            Fire1Right:
            mov fireball1_dir, 1    ; Facing right = direction 1
            dec fire_shots_left
            cmp fire_shots_left, 0
            jg NoInput
            mov fire_active, 0
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
            dec fire_shots_left
            cmp fire_shots_left, 0
            jg NoInput
            mov fire_active, 0
            jmp NoInput
            Fire2Right:
            mov fireball2_dir, 1    ; Facing right = direction 1
            dec fire_shots_left
            cmp fire_shots_left, 0
            jg NoInput
            mov fire_active, 0
            jmp NoInput
    
    PauseGame:
        ; Toggle pause state (2 = paused)
        cmp game_state, 2
        je NoInput  ; Already paused, ignore additional P presses
        mov game_state, 2
        call DrawPauseMenu
        ; Wait for key release
        PauseWait:
            call ReadKey
            jnz PauseWait
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
    
    ; Stop on walls/pipes/platforms
    push ebx
    mov eax, fireball1_x
    mov ebx, fireball1_y
    call CheckCollisionAt
    pop ebx
    cmp al, 1
    je DeactivateFire1
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
    
    ; Stop on walls/pipes/platforms
    push ebx
    mov eax, fireball2_x
    mov ebx, fireball2_y
    call CheckCollisionAt
    pop ebx
    cmp al, 1
    je DeactivateFire2
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
    
    ; Move moving platform (level 2)
    cmp level, 2
    jne SkipMovePlatUpdate
    movzx eax, moving_plat_dir
    cmp eax, 1
    jne PlatMoveLeft
    inc moving_plat_x
    mov eax, moving_plat_x
    cmp eax, moving_plat_right
    jle SkipMovePlatUpdate
    mov moving_plat_dir, 2
    dec moving_plat_x
    jmp SkipMovePlatUpdate
PlatMoveLeft:
    dec moving_plat_x
    mov eax, moving_plat_x
    cmp eax, moving_plat_left
    jge SkipMovePlatUpdate
    mov moving_plat_dir, 1
    inc moving_plat_x
SkipMovePlatUpdate:
    
    cmp koopa_frozen, 0
    jle KoopaNotFrozen
    dec koopa_frozen
    KoopaNotFrozen:
    
    ; Move Goomba 1 (patrols ground: columns 20-35)
    cmp goomba1_alive, 1
    jne SkipGoomba1Move
    cmp goomba1_frozen, 0
    jg SkipGoomba1Move
    
    movzx eax, goomba1_dir
    cmp eax, 1
    je Goomba1Right
    ; Moving left
    mov eax, goomba1_x
    dec eax
    mov ebx, goomba1_y
    push ebx
    push eax
    call CheckCollisionAt    ; Check if pipe or wall ahead
    pop ebx                  ; Restore proposed x position
    pop ecx                  ; Clean up stack
    cmp al, 1
    je Goomba1HitLeft
    mov goomba1_x, ebx       ; Safe to move
    cmp goomba1_x, 20
    jge SkipGoomba1Move
    Goomba1HitLeft:
    mov goomba1_dir, 1
    jmp SkipGoomba1Move
    Goomba1Right:
    mov eax, goomba1_x
    inc eax
    mov ebx, goomba1_y
    push ebx
    push eax
    call CheckCollisionAt    ; Check if pipe or wall ahead
    pop ebx                  ; Restore proposed x position
    pop ecx                  ; Clean up stack
    cmp al, 1
    je Goomba1HitRight
    mov goomba1_x, ebx       ; Safe to move
    cmp goomba1_x, 35
    jle SkipGoomba1Move
    Goomba1HitRight:
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
    ; Moving left
    mov eax, goomba2_x
    dec eax
    mov ebx, goomba2_y
    push ebx
    push eax
    call CheckCollisionAt    ; Check if pipe or wall ahead
    pop ebx                  ; Restore proposed x position
    pop ecx                  ; Clean up stack
    cmp al, 1
    je Goomba2HitLeft
    mov goomba2_x, ebx       ; Safe to move
    cmp goomba2_x, 55
    jge SkipGoomba2Move
    Goomba2HitLeft:
    mov goomba2_dir, 1
    jmp SkipGoomba2Move
    Goomba2Right:
    mov eax, goomba2_x
    inc eax
    mov ebx, goomba2_y
    push ebx
    push eax
    call CheckCollisionAt    ; Check if pipe or wall ahead
    pop ebx                  ; Restore proposed x position
    pop ecx                  ; Clean up stack
    cmp al, 1
    je Goomba2HitRight
    mov goomba2_x, ebx       ; Safe to move
    cmp goomba2_x, 70
    jle SkipGoomba2Move
    Goomba2HitRight:
    mov goomba2_dir, 2
    SkipGoomba2Move:
    
    ; Move Koopa Troopa
    cmp koopa_alive, 1
    jne SkipKoopaMove
    cmp koopa_frozen, 0
    jg SkipKoopaMove
    
    cmp koopa_state, 0
    jne KoopaShellLogic
    
    ; Walking
    movzx eax, koopa_dir
    cmp eax, 1
    je KoopaRight
    ; Moving left
    mov eax, koopa_x
    dec eax
    mov ebx, koopa_y
    push ebx
    push eax
    call CheckCollisionAt
    pop ebx
    pop ecx
    cmp al, 1
    je KoopaHitLeft
    mov koopa_x, ebx
    cmp koopa_x, 25
    jge SkipKoopaMove
    KoopaHitLeft:
    mov koopa_dir, 1
    jmp SkipKoopaMove
    
    KoopaRight:
    mov eax, koopa_x
    inc eax
    mov ebx, koopa_y
    push ebx
    push eax
    call CheckCollisionAt
    pop ebx
    pop ecx
    cmp al, 1
    je KoopaHitRight
    mov koopa_x, ebx
    cmp koopa_x, 55
    jle SkipKoopaMove
    KoopaHitRight:
    mov koopa_dir, 2
    jmp SkipKoopaMove
    
    KoopaShellLogic:
    cmp koopa_state, 1
    je SkipKoopaMove          ; Shell idle
    cmp koopa_state, 2
    je KoopaShellLeft
    cmp koopa_state, 3
    je KoopaShellRight
    jmp SkipKoopaMove
    
    KoopaShellLeft:
    mov ecx, 2                ; shell moves 2 tiles per update
    KoopaShellLeftLoop:
        mov eax, koopa_x
        dec eax
        mov ebx, koopa_y
        push ebx
        push eax
        call CheckCollisionAt
        pop ebx
        pop edx
        cmp al, 1
        je KoopaShellLeftHit
        mov koopa_x, ebx
        dec ecx
        jnz KoopaShellLeftLoop
        jmp SkipKoopaMove
    KoopaShellLeftHit:
    mov koopa_state, 3        ; bounce to the right
    jmp SkipKoopaMove
    
    KoopaShellRight:
    mov ecx, 2
    KoopaShellRightLoop:
        mov eax, koopa_x
        inc eax
        mov ebx, koopa_y
        push ebx
        push eax
        call CheckCollisionAt
        pop ebx
        pop edx
        cmp al, 1
        je KoopaShellRightHit
        mov koopa_x, ebx
        dec ecx
        jnz KoopaShellRightLoop
        jmp SkipKoopaMove
    KoopaShellRightHit:
    mov koopa_state, 2        ; bounce to the left
    
    SkipKoopaMove:
    
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
    
    ; Check Mario vs Koopa
    cmp koopa_alive, 1
    jne SkipKoopaColl
    mov eax, mario_x
    cmp eax, koopa_x
    jne SkipKoopaColl
    mov eax, mario_y
    cmp eax, koopa_y
    jne SkipKoopaColl
    cmp mario_velocity_y, 0
    jle KoopaSideCollision
    ; Stomped Koopa -> enter shell
    mov koopa_state, 1
    add score, 200
    mov mario_velocity_y, -4
    jmp SkipKoopaColl
    
    KoopaSideCollision:
    cmp koopa_state, 1
    je KickShell
    cmp koopa_state, 2
    je KoopaShellHurt
    cmp koopa_state, 3
    je KoopaShellHurt
    ; Walking Koopa hurts
    dec lives
    mov mario_x, 5
    mov mario_y, 17
    jmp SkipKoopaColl
    
    KickShell:
    mov eax, mario_x
    cmp eax, koopa_x
    jl KickShellRight
    mov koopa_state, 2         ; kick left
    mov koopa_dir, 2
    jmp SkipKoopaColl
    KickShellRight:
    mov koopa_state, 3         ; kick right
    mov koopa_dir, 1
    jmp SkipKoopaColl
    
    KoopaShellHurt:
    dec lives
    mov mario_x, 5
    mov mario_y, 17
    SkipKoopaColl:
    
    ; Shell moving hits goombas
    cmp koopa_state, 2
    je ShellMoving
    cmp koopa_state, 3
    jne SkipShellHits
    ShellMoving:
        cmp goomba1_alive, 1
        jne CheckShellGoomba2
        mov eax, koopa_x
        cmp eax, goomba1_x
        jne CheckShellGoomba2
        mov eax, koopa_y
        cmp eax, goomba1_y
        jne CheckShellGoomba2
        mov goomba1_alive, 0
        add score, 200
    CheckShellGoomba2:
        cmp goomba2_alive, 1
        jne SkipShellHits
        mov eax, koopa_x
        cmp eax, goomba2_x
        jne SkipShellHits
        mov eax, koopa_y
        cmp eax, goomba2_y
        jne SkipShellHits
        mov goomba2_alive, 0
        add score, 200
    SkipShellHits:
    
    ; Boss collision (level 2)
    cmp level, 2
    jne SkipBossTouch
    cmp boss_alive, 1
    jne SkipBossTouch
    mov eax, mario_x
    cmp eax, boss_x
    jne SkipBossTouch
    mov eax, mario_y
    cmp eax, boss_y
    jne SkipBossTouch
    jmp MarioHurtCommon
    SkipBossTouch:
    
    ; Fire chains (level 2)
    cmp level, 2
    jne SkipChainTouch
    call CheckFireChainHit
    cmp al, 1
    je MarioHurtCommon
    SkipChainTouch:
    
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
    
    ; Fireball 1 vs Koopa
    cmp fireball1_dir, 0
    je SkipFire1Koopa
    cmp koopa_alive, 1
    jne SkipFire1Koopa
    mov eax, fireball1_x
    cmp eax, koopa_x
    jne SkipFire1Koopa
    mov eax, fireball1_y
    cmp eax, koopa_y
    jne SkipFire1Koopa
    mov koopa_alive, 0
    mov fireball1_dir, 0
    add score, 200
    SkipFire1Koopa:
    
    ; Fireball 2 vs Koopa
    cmp fireball2_dir, 0
    je SkipFire2Koopa
    cmp koopa_alive, 1
    jne SkipFire2Koopa
    mov eax, fireball2_x
    cmp eax, koopa_x
    jne SkipFire2Koopa
    mov eax, fireball2_y
    cmp eax, koopa_y
    jne SkipFire2Koopa
    mov koopa_alive, 0
    mov fireball2_dir, 0
    add score, 200
    SkipFire2Koopa:
    
    ; Fireballs vs Boss (level 2)
    cmp level, 2
    jne SkipBossFireAll
    cmp boss_alive, 1
    jne SkipBossFireAll
    
    ; Fireball 1
    cmp fireball1_dir, 0
    je CheckBossFireball2
    mov eax, fireball1_x
    cmp eax, boss_x
    jne CheckBossFireball2
    mov eax, fireball1_y
    cmp eax, boss_y
    jne CheckBossFireball2
    mov fireball1_dir, 0
    mov fireball1_x, -1
    dec boss_health
    cmp boss_health, 0
    jg CheckBossFireball2
    mov boss_alive, 0
    add score, 500
    
    CheckBossFireball2:
    cmp fireball2_dir, 0
    je SkipBossFireAll
    mov eax, fireball2_x
    cmp eax, boss_x
    jne SkipBossFireAll
    mov eax, fireball2_y
    cmp eax, boss_y
    jne SkipBossFireAll
    mov fireball2_dir, 0
    mov fireball2_x, -1
    dec boss_health
    cmp boss_health, 0
    jg SkipBossFireAll
    mov boss_alive, 0
    add score, 500
    SkipBossFireAll:
    
    ; Check coin collection
    mov eax, mario_y
    imul eax, map_width
    add eax, mario_x
    movzx ecx, byte ptr [level1_map + eax]
    
    ; Lava hazard
    cmp ecx, 14
    jne NoLava
    jmp MarioHurtCommon
    NoLava:
    
    cmp ecx, 2
    jne NoCoin
    ; Collected coin!
    mov byte ptr [level1_map + eax], 0
    add score, 200
    NoCoin:
    
    ; Super mushroom pickup
    cmp ecx, 15
    jne NoMushroom
    mov byte ptr [level1_map + eax], 0
    mov mushroom_visible, 0
    inc lives
    mov super_active, 1
    mov eax, super_jump_power
    mov mario_jump_power, eax
    NoMushroom:
    
    ; Check fire flower collection
    cmp ecx, 10
    jne NoFireFlower
    mov byte ptr [level1_map + eax], 0
    mov fire_flower_visible, 0
    mov fire_active, 1
    mov fire_shots_left, 2
    mov fireball1_dir, 0
    mov fireball2_dir, 0
    mov fireball1_x, -1
    mov fireball1_y, -1
    mov fireball2_x, -1
    mov fireball2_y, -1
    NoFireFlower:
    
    ; Check ice flower collection
    cmp ecx, 3
    jne NoIceFlower
    mov byte ptr [level1_map + eax], 0
    mov ice_flower_visible, 0
    ; Ice flower effect: freeze enemies
    ; Freeze timer ticks once every enemy update (every 8 frames).
    ; HUD seconds tick every 10 frames, so 5 ticks ≈ 4 HUD seconds (5*8=40 frames).
    mov goomba1_frozen, 5
    mov goomba2_frozen, 5
    mov koopa_frozen, 5
    NoIceFlower:
    
    ; Check flagpole for level completion
    cmp ecx, 12
    je LevelComplete
    cmp ecx, 13
    jne NotFlag
    LevelComplete:
    mov level_complete, 1
    NotFlag:
    
    ret
    
    MarioHurtCommon:
    dec lives
    mov mario_x, 5
    mov mario_y, 17
    mov mario_velocity_y, 0
    mov mario_on_ground, 1
    mov super_active, 0
    mov eax, normal_jump_power
    mov mario_jump_power, eax
    
    ret
CheckCollisions ENDP

; ============================================================
; PROCEDURE: DrawMarioASCII
; Draws colorful MARIO ASCII art
; ============================================================
DrawMarioASCII PROC
    ; Line 1 - Red
    mov dh, 2
    mov dl, 5
    call Gotoxy
    mov eax, red + (black*16)
    call SetTextColor
    mov edx, offset mario_line1
    call WriteString
    
    ; Line 2 - Yellow
    mov dh, 3
    mov dl, 5
    call Gotoxy
    mov eax, yellow + (black*16)
    call SetTextColor
    mov edx, offset mario_line2
    call WriteString
    
    ; Line 3 - Green
    mov dh, 4
    mov dl, 5
    call Gotoxy
    mov eax, green + (black*16)
    call SetTextColor
    mov edx, offset mario_line3
    call WriteString
    
    ; Line 4 - Cyan
    mov dh, 5
    mov dl, 5
    call Gotoxy
    mov eax, cyan + (black*16)
    call SetTextColor
    mov edx, offset mario_line4
    call WriteString
    
    ; Line 5 - Magenta
    mov dh, 6
    mov dl, 5
    call Gotoxy
    mov eax, magenta + (black*16)
    call SetTextColor
    mov edx, offset mario_line5
    call WriteString
    
    ; Line 6 - Light Blue
    mov dh, 7
    mov dl, 5
    call Gotoxy
    mov eax, lightBlue + (black*16)
    call SetTextColor
    mov edx, offset mario_line6
    call WriteString
    
    ret
DrawMarioASCII ENDP

; ============================================================
; PROCEDURE: DrawPauseMenu
; Draws the pause menu with black screen
; ============================================================
DrawPauseMenu PROC
    ; Clear screen for clean pause menu
    call Clrscr
    
    ; Draw pause title
    mov eax, yellow + (black*16)
    call SetTextColor
    mov dh, 10
    mov dl, 35
    call Gotoxy
    mov edx, offset pause_title
    call WriteString
    
    ; Draw resume option
    mov eax, green + (black*16)
    call SetTextColor
    mov dh, 13
    mov dl, 32
    call Gotoxy
    mov edx, offset pause_resume
    call WriteString
    
    ; Draw quit option
    mov eax, red + (black*16)
    call SetTextColor
    mov dh, 15
    mov dl, 29
    call Gotoxy
    mov edx, offset pause_quit
    call WriteString
    
    ret
DrawPauseMenu ENDP

; ============================================================
; PROCEDURE: PrintMainMenu
; ============================================================
PrintMainMenu PROC
    call Clrscr
    
    ; Draw colorful MARIO ASCII art
    call DrawMarioASCII
    
    ; Draw "BROS" subtitle
    mov eax, magenta + (black*16)
    call SetTextColor
    mov dh, 9
    mov dl, 30
    call Gotoxy
    mov edx, offset title1
    call WriteString
    
    mov eax, yellow + (black*16)
    call SetTextColor
    mov dh, 11
    mov dl, 30
    call Gotoxy
    mov edx, offset myRoll
    call WriteString
    
    mov eax, green + (black*16)
    call SetTextColor
    mov dh, 14
    mov dl, 30
    call Gotoxy
    mov edx, offset play_title
    call WriteString
    
    mov eax, cyan + (black*16)
    call SetTextColor
    mov dh, 16
    mov dl, 30
    call Gotoxy
    mov edx, offset score_prompt
    call WriteString
    
    mov eax, red + (black*16)
    call SetTextColor
    mov dh, 18
    mov dl, 30
    call Gotoxy
    mov edx, offset quitt
    call WriteString
    
    ret
PrintMainMenu ENDP

; ============================================================
; PROCEDURE: ShowInstructionsAndSelectLevel
; Displays controls and lets player choose level 1 or 2
; ============================================================
ShowInstructionsAndSelectLevel PROC
    call Clrscr
    
    ; Title
    mov eax, yellow + (black*16)
    call SetTextColor
    mov dh, 2
    mov dl, 30
    call Gotoxy
    mov edx, offset instr_title
    call WriteString
    
    ; Divider under title
    mov eax, white + (black*16)
    call SetTextColor
    mov dh, 3
    mov dl, 28
    call Gotoxy
    mov edx, offset instr_divider
    call WriteString
    
    ; Controls
    mov eax, white + (black*16)
    call SetTextColor
    
    mov dh, 4
    mov dl, 8
    call Gotoxy
    mov edx, offset instr_move
    call WriteString
    
    mov dh, 5
    mov dl, 8
    call Gotoxy
    mov edx, offset instr_jump
    call WriteString
    
    mov dh, 6
    mov dl, 8
    call Gotoxy
    mov edx, offset instr_shoot
    call WriteString
    
    mov dh, 7
    mov dl, 8
    call Gotoxy
    mov edx, offset instr_pause
    call WriteString
    
    mov dh, 8
    mov dl, 8
    call Gotoxy
    mov edx, offset instr_quit
    call WriteString
    
    mov dh, 9
    mov dl, 8
    call Gotoxy
    mov edx, offset instr_power
    call WriteString
    
    ; Level selection (spaced lower, separate rows)
    mov eax, lightGreen + (black*16)
    call SetTextColor
    mov dh, 14
    mov dl, 20
    call Gotoxy
    mov edx, offset level_select_title
    call WriteString
    
    mov eax, cyan + (black*16)
    call SetTextColor
    mov dh, 15
    mov dl, 20
    call Gotoxy
    mov edx, offset level_select_hint
    call WriteString
    
    mov eax, white + (black*16)
    call SetTextColor
    mov dh, 17
    mov dl, 24
    call Gotoxy
    mov edx, offset level_opt1
    call WriteString
    
    mov dh, 18
    mov dl, 24
    call Gotoxy
    mov edx, offset level_opt2
    call WriteString
    
    mov eax, yellow + (black*16)
    call SetTextColor
    mov dh, 20
    mov dl, 24
    call Gotoxy
    mov edx, offset level_select_prompt
    call WriteString
    
    ; Wait for selection
    LevelSelectLoop:
        call ReadChar
        cmp al, '1'
        je SelectLevel1
        cmp al, '2'
        je SelectLevel2
        jmp LevelSelectLoop
    
    SelectLevel1:
        mov level, 1
        ret
    SelectLevel2:
        mov level, 2
        ret
ShowInstructionsAndSelectLevel ENDP

; ============================================================
; PROCEDURE: GameLoop
; Main game loop
; ============================================================
GameLoop PROC
    ; Initial draw
    call Clrscr
        call UpdateCamera
    
    GameLoopStart:
        ; Draw everything
            call UpdateCamera
        call DrawMap
        call DrawHUD
            call DrawFireChains
            call DrawMovingPlatforms
        call DrawMario
        call DrawEnemies
            call DrawBoss
        call DrawFireballs
        
        ; Handle input
        call HandleInput
        
        ; Check if quitting
        cmp game_state, 3
        je ExitGame
        
        ; Check if paused - if so, wait for resume/quit input
        cmp game_state, 2
        jne ContinueGameplay
        
        ; In pause state - wait for R or Q
        PauseInputLoop:
            call ReadKey
            jz PauseInputLoop  ; No key pressed, keep waiting
            
            ; Check for Resume (R)
            cmp al, 'r'
            je ResumeGame
            cmp al, 'R'
            je ResumeGame
            
            ; Check for Quit (Q)
            cmp al, 'q'
            je QuitFromPause
            cmp al, 'Q'
            je QuitFromPause
            
            ; Invalid key, keep waiting
            jmp PauseInputLoop
        
        ResumeGame:
            mov game_state, 1
            call Clrscr  ; Clear pause screen
            jmp GameLoopStart  ; Redraw everything
        
        QuitFromPause:
            mov game_state, 3
            jmp ExitGame
        
        ContinueGameplay:
        
        ; Update physics
        call UpdateMarioPhysics
        
        ; Update game objects
        inc move_counter
        inc frame_counter
        
        ; Update timer every ~1 second
        mov eax, frame_counter
        cmp eax, 10              ; 20 frames at 30ms delay = ~600ms, adjusted for more accurate 1 second
        jl SkipTimerUpdate
        
        ; Decrement timer (countdown)
        cmp game_timer, 0
        jle TimerExpired
        dec game_timer
        mov frame_counter, 0
        jmp SkipTimerUpdate
        
        TimerExpired:
        ; Timer ran out - lose a life
        dec lives
        cmp lives, 0
        jle GameOver            ; No lives left = game over
        
        ; Respawn Mario with remaining lives
        mov mario_x, 5
        mov mario_y, 17
        mov mario_velocity_y, 0
        mov mario_on_ground, 1
        mov game_timer, 110     ; Reset timer to 1:50
        mov frame_counter, 0
        
        SkipTimerUpdate:
        
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
        
        ; Check level completion
        cmp level_complete, 1
        jne ContinueAfterWinCheck
        ; Black background with bright text
        mov eax, white + (black*16)
        call SetTextColor
        call Clrscr
        mov eax, lightGreen + (black*16)
        call SetTextColor
        mov dh, 11
        mov dl, 30
        call Gotoxy
        mov edx, offset gameWon1
        call WriteString
        
        ; Show score
        mov eax, yellow + (black*16)
        call SetTextColor
        mov dh, 13
        mov dl, 30
        call Gotoxy
        mov edx, offset socre_txt
        call WriteString
        mov eax, score
        call WriteDec
        
        ; Small prompt
        mov eax, white + (black*16)
        call SetTextColor
        mov dh, 15
        mov dl, 28
        call Gotoxy
        mov edx, offset level_select_prompt ; reuse "Press 1 or 2 to start" text
        call WriteString
        
        mov eax, 2500
        call Delay
        mov game_state, 3
        jmp ExitGame
        ContinueAfterWinCheck:
        
        ; Check game over
        cmp lives, 0
        jle GameOver
        
        ; Small delay
        mov eax, 30
        call Delay
        
        jmp GameLoopStart
    
    GameOver:
        mov eax, white + (black*16)
        call SetTextColor
        call Clrscr
        
        ; Title
        mov eax, red + (black*16)
        call SetTextColor
        mov dh, 11
        mov dl, 34
        call Gotoxy
        mov edx, offset gameOver1
        call WriteString
        
        ; Score line
        mov eax, yellow + (black*16)
        call SetTextColor
        mov dh, 13
        mov dl, 30
        call Gotoxy
        mov edx, offset socre_txt
        call WriteString
        mov eax, score
        call WriteDec
        
        ; Prompt
        mov eax, white + (black*16)
        call SetTextColor
        mov dh, 15
        mov dl, 28
        call Gotoxy
        mov edx, offset level_select_prompt ; reuse "Press 1 or 2 to start"
        call WriteString
        
        mov eax, 2500
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
    
    ; Ensure box-drawing characters (╔═╗ etc.) render correctly
    mov eax, 437                     ; OEM US code page with box chars
    invoke SetConsoleOutputCP, eax
    invoke SetConsoleCP, eax
    call Randomize
    
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
        ; Instructions + level select
        call ShowInstructionsAndSelectLevel
        
        ; Initialize selected level (2 currently reuses level 1 layout)
        cmp level, 2
        je InitLevel2Start
        call InitializeLevel1
        jmp InitDone
        InitLevel2Start:
        call InitializeLevel2
        InitDone:
        
        ; Reset game state
        mov mario_x, 5
        mov mario_y, 17          ; One row above ground (row 18 is ground)
        mov mario_velocity_y, 0
        mov mario_on_ground, 1   ; Start on ground (changed from 0)
        mov lives, 3
        mov score, 0
        mov game_timer, 110     ; Start with 110 seconds (1:50)
        mov frame_counter, 0
        mov fire_active, 0
        mov fire_shots_left, 0
        mov fireball1_dir, 0
        mov fireball2_dir, 0
        mov fireball1_x, -1
        mov fireball1_y, -1
        mov fireball2_x, -1
        mov fireball2_y, -1
        mov super_active, 0
        mov mushroom_visible, 0
        mov eax, normal_jump_power
        mov mario_jump_power, eax
        mov goomba1_frozen, 0
        mov goomba2_frozen, 0
        mov koopa_frozen, 0
        mov camera_x, 0
        mov game_state, 1
        mov move_counter, 0
    
    cmp level, 2
    jne InitLevel1Actors
        ; Level 2 setup
        mov goomba1_alive, 0
        mov goomba2_alive, 0
        mov koopa_alive, 0
        mov boss_alive, 1
        mov boss_health, 6
        mov boss_x, 145
        mov boss_y, 17
        mov flag_x, 156
        jmp InitActorsDone
    InitLevel1Actors:
        mov goomba1_alive, 1
        mov goomba2_alive, 1
        mov koopa_alive, 1
        mov boss_alive, 0
        mov boss_health, 0
        mov goomba1_x, 25
        mov goomba1_y, 17
        mov goomba1_dir, 1
        mov goomba2_x, 105
        mov goomba2_y, 17
        mov goomba2_dir, 2
        mov koopa_state, 0
        mov koopa_dir, 1
        mov koopa_x, 130
        mov koopa_y, 17
        mov ice_flower_visible, 1
        mov flag_x, 150
    InitActorsDone:
        
        ; Start game
        call GameLoop
        
        jmp MenuLoop
    
    QuitProgram:
    call Clrscr
    invoke ExitProcess, 0
main ENDP

END main
