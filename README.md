SUPER MARIO BROS - Assembly Game Project

Project Name: Super Mario Bros (x86 Assembly)
Author: Muhammad Mahd Kazmi
Roll Number: 23i-2587
Section: CS-B
Course: Computer Organization and Assembly Language 

----------------
PROJECT OVERVIEW
----------------

This is a Super Mario Bros inspired game written entirely in x86 Assembly 
language using the Irvine32 library. The game features classic platformer 
mechanics, two challenging levels, enemies, power-ups, and a boss fight.

-------------
GAME FEATURES
-------------

Levels:
  - Level 1: Classic grassland level with platforms, pipes, and enemies
  - Level 2: Castle level with fire chains, moving platforms, and Bowser boss

Gameplay:
  - Smooth scrolling camera that follows Mario
  - Jump physics with gravity simulation
  - Collision detection with platforms, pipes, and enemies
  - Countdown timer (1:50) that decreases lives when it hits zero
  - Checkpoint system in Level 2 (respawn at checkpoint after death)

Enemies:
  - Goombas: Basic walking enemies
  - Koopa Troopa: Enemies with shell mechanics
  - Bowser: Level 2 boss with fireball attacks

Power-ups:
  - Fire Flower: Grants ability to shoot blue fireballs
  - Ice Flower: Freezes enemies temporarily
  - Super Mushroom: Increases jump height
  - Mario starts with fire ability (based on my roll number)

Other Features:
  - High score system with file saving
  - Player name entry
  - Pause menu (Press P)
  - Colorful ASCII graphics
  - Destructible bridge in boss fight

--------
CONTROLS
--------

Movement:
  - A / Left Arrow  : Move Left
  - D / Right Arrow : Move Right
  - W / Space       : Jump

Actions:
  - F : Shoot Fireball
  - P : Pause Game
  - Q : Quit to Menu

Menu:
  - P : Play
  - H : View High Scores
  - Q : Quit Game
  - 1/2 : Select Level

----------
HOW TO RUN
----------

Prerequisites:
  1. Visual Studio with MASM assembler
  2. Irvine32 library installed and configured
  3. Windows operating system

Running:
  1. Open the project in Visual Studio
  2. Make sure Irvine32.inc is properly linked
  3. Build the solution (Ctrl+Shift+B)
  4. Run the game (F5 or Ctrl+F5)

If you get errors about missing Irvine32.lib, check that the library path 
is correctly set in project properties.

-----------------
TECHNICAL DETAILS
-----------------

Implementation:
  - Language: x86 Assembly (MASM)
  - Library: Irvine32
  - Map Size: 160x24 tiles
  - Viewport: 78 columns
  - Frame-based game loop

Key Features:
  - Tile-based collision detection
  - Camera scrolling system
  - Enemy AI with movement patterns
  - Physics simulation (gravity, jumping)
  - File I/O for high scores

Challenges I Faced:
  - Getting jump physics to feel right
  - Implementing smooth scrolling in assembly
  - Managing collision detection edge cases
  - Checkpoint system for all death scenarios


----------------
SPECIAL FEATURES
----------------

Roll Number Customization (2587):
  - Last digit is 7, so Mario has fire power from the start
  - Blue fireballs
  - Green shirt color scheme

Unique Additions:
  - Checkpoint system in Level 2
  - Vertical fire chains
  - Moving platforms
  - Shell kicking mechanics
  - Boss fight with destructible bridge

------------
KNOWN ISSUES
------------

- Timer might update slightly faster/slower than real-time
- Console flickering on slower systems
- Border characters need proper codepage setting

These are minor and don't affect gameplay significantly.

-------------------
FUTURE IMPROVEMENTS
-------------------

If I had more time:
  - Sound effects
  - More enemy types
  - Additional levels
  - Power-up animations
  - Better boss AI

-------
CREDITS
-------

Game Design & Programming: Muhammad Mahd Kazmi
Inspired by: Nintendo's Super Mario Bros
Tools: Visual Studio, MASM, Irvine32 Library


Hope you enjoy playing! The code is well-commented if you want to explore :)



<img width="1012" height="577" alt="title_screen" src="https://github.com/user-attachments/assets/ba5a5935-5f1d-454f-a133-021d24fd708e" />



<img width="1362" height="687" alt="instructions" src="https://github.com/user-attachments/assets/1a6ed9dd-8b9f-467a-94fd-b0be6b9ca0eb" />
<img width="941" height="515" alt="credentials" src="https://github.com/user-attachments/assets/04ea6ee7-b886-4855-a107-e9e99ed62780" />
<img width="995" height="596" alt="level1" src="https://github.com/user-attachments/assets/689c719d-3b8e-4e9b-b708-965f55a78be4" />
<img width="975" height="572" alt="level2" src="https://github.com/user-attachments/assets/715e25d5-2e55-4ad3-9bbd-0b96b91767a1" />
