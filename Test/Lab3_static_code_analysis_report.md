# Lab 3 ataskaita: Static code analysis ir code review (Godot + GUT)

## 1. Darbo tikslas
Atlikti pasirinktos programinės įrangos (Godot žaidimo projekto) kokybės vertinimą:
- rankiniu code review būdu,
- static code analysis būdu,
- suprojektuoti ir įgyvendinti 1 papildomą static analysis taisyklę.

## 2. Analizuota programinė įranga
Projektas: Gladiator (Godot, GDScript)

Analizuotos klasės/failai:
- res://scripts/base/Entity.gd
- res://scripts/player/Player.gd
- res://scripts/enemy/enemy.gd
- res://scripts/weapons/enemy_sword.gd
- res://Test/Integration/test_combat.gd

## 3. Naudotas code review checklist
Pritaikytos taisyklės iš pateikto pavyzdinio checklist:
- Variables: aiškūs ir nuoseklūs tipai, vardai.
- Defensive Programming: null/egzistavimo patikros prieš naudojimą.
- Loops and Branches: šakų pilnumas ir saugus valdymo srautas.
- Documentation/Readability: nereikalingų debug fragmentų nebuvimas produkciniame kode.
- Structure: failų kelių nuoseklumas (platforminis suderinamumas, case-sensitive keliai).

## 4. Code review rezultatai

| Source file | Class | Method | Line | Unsatisfied checklist rule | Comment |
|---|---|---|---:|---|---|
| res://scripts/player/Player.gd | Player | load_player_data | 227 | Defensive Programming (null checks) | total_coins.text naudojamas be aiškios null patikros; jei UI mazgas neegzistuoja ar neinicijuotas, gaunama runtime klaida. |
| res://scripts/player/Player.gd | Player | throw_bomb | 128 | Defensive Programming | get_tree().current_scene naudojamas tiesiogiai; jei scena neaktyvi/pakeista, add_child gali lūžti. |
| res://scripts/player/Player.gd | Player | add_special_ammo | 103 | Readability / Production logging | Produkciniame kode paliktas print() debug išvedimas. |
| res://scripts/enemy/enemy.gd | Enemy | _physics_process | 36 | Defensive Programming (type safety) | player_ref tipas Node2D, bet naudojama player_ref.is_dead; savybė nepriklauso baziniam Node2D, galimas netikėtas lūžis keičiant objektą. |
| res://scripts/enemy/enemy.gd | Enemy | (globalus laukas coin preload) | 12 | Structure (path consistency) | Kelias naudoja res://Scenes/... (didžioji raidė), kas gali sukelti problemas case-sensitive aplinkose. |
| res://scripts/weapons/enemy_sword.gd | enemy_sword | swing | 45,47 | Readability / Production logging | Palikti debug print() iškvietimai produkciniame kovos kode. |
| res://scripts/base/Entity.gd | Entity | take_damage | 41 | Defensive Programming (input validation) | Nėra validacijos neigiamai žalai; perduotas neigiamas amount didintų health. |

## 5. Static code analysis

### 5.1 Pasirinktas įrankis
Kadangi projektas yra GDScript/Godot (ne Java/.NET), pasirinktas derinys:
- GUT pagrindu vykdomas custom static rule testas,
- papildoma automatinė paieška pagal taisyklę (print() aptikimas .gd failuose).

Pastaba: JTest/FindBugs/FxCop yra orientuoti į Java/.NET, todėl šiam projektui netinka tiesiogiai.

### 5.2 Vykdymas
- Integruotas custom rule failas: res://scripts/tools/static_rule_no_debug_prints.gd
- Rule testas per GUT: res://Test/Unit/test_static_rule_no_debug_prints.gd

## 6. Sukurta custom static analysis taisyklė

### 6.1 Taisyklė
Rule pavadinimas: NoDebugPrintsInProductionScripts

Apibrėžimas:
- Jei .gd faile aptinkamas print(...), žymima kaip pažeidimas (debug log produkciniame kode).

Motyvacija:
- Mažina triukšmą loguose.
- Mažina riziką palikti nereikalingus debug fragmentus release versijoje.

### 6.2 Įgyvendinimas
Failas: res://scripts/tools/static_rule_no_debug_prints.gd

Logika:
1. Rekursiškai skenuojami perduoti keliai (naudota res://scripts).
2. Skaitomas kiekvienas .gd failas eilutė po eilutės.
3. RegEx aptinka print\s*\( šabloną.
4. Grąžinamas pažeidimų sąrašas: path, line, code.

### 6.3 Aptikti pažeidimai pagal custom rule

| Source file | Class | Method | Line | Unsatisfied checklist rule | Comment |
|---|---|---|---:|---|---|
| res://scripts/player/Player.gd | Player | add_special_ammo | 103 | NoDebugPrintsInProductionScripts | Debug print paliktas. |
| res://scripts/player/Player.gd | Player | throw_bomb | 108 | NoDebugPrintsInProductionScripts | Debug print paliktas. |
| res://scripts/player/Player.gd | Player | throw_bomb | 113 | NoDebugPrintsInProductionScripts | Debug print paliktas. |
| res://scripts/player/Player.gd | Player | throw_bomb | 143 | NoDebugPrintsInProductionScripts | Debug print paliktas. |
| res://scripts/player/Player.gd | Player | throw_bomb | 145 | NoDebugPrintsInProductionScripts | Debug print paliktas. |
| res://scripts/enemy/sword_enemy.gd | sword_enemy | perform_attack | 6 | NoDebugPrintsInProductionScripts | Debug print paliktas. |
| res://scripts/enemy/sword_enemy.gd | sword_enemy | perform_attack | 12 | NoDebugPrintsInProductionScripts | Debug print paliktas. |
| res://scripts/weapons/enemy_sword.gd | enemy_sword | swing | 45 | NoDebugPrintsInProductionScripts | Debug print paliktas. |
| res://scripts/weapons/enemy_sword.gd | enemy_sword | swing | 47 | NoDebugPrintsInProductionScripts | Debug print paliktas. |
| res://scripts/wave_manager.gd | WaveManager | clear_enemies / start_wave / _start_grace_period | 82,99,154 | NoDebugPrintsInProductionScripts | Keli debug print iškvietimai. |

## 7. Atnaujinti testai pagal projekto būseną

Atnaujinimas:
- Test failas res://Test/Integration/test_combat.gd naudojo netikslų kelią res://scripts/enemy/Enemy.gd.
- Pakeista į res://scripts/enemy/enemy.gd.
- Po after_each pridėtas player/enemy nunulinimas.

Tai pašalina vieną pasenusį testų neatitikimą ir sumažina flaky testų riziką.

## 8. Išvados
- Code review metu rasta kelios potencialios rizikos vietos (null/type/path consistency, input validation, debug logs).
- Įgyvendinta ir integruota custom static analysis taisyklė per GUT.
- Parengta ataskaitos struktūra su lentelėmis pagal laboratorinio darbo reikalaujamą formatą.
