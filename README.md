# Template Godot Jam

Inspiré de [Maaack's Godot Game Template](https://github.com/Maaack/Godot-Game-Template) et des [best practices Godot](https://docs.godotengine.org/en/stable/tutorials/best_practices/).

## Ce qui est déjà fait

- Menu principal : Jouer, Options, Crédits, Quitter
- Options : volumes (général, musique, effets), plein écran, **changement des touches clavier + manette**, tout sauvegardé automatiquement
- Pause (Échap / Start) : Reprendre, Options, Recommencer, Menu principal, Quitter
- Écran de fin (victoire / défaite + score), crédits
- Transitions entre les scènes (fondu)
- Tous les menus se naviguent au clavier et à la manette, avec des sons d'interface
- Exports Windows et Web déjà configurés

## Arborescence

```
autoloads/   Scripts globaux (voir plus bas). On y touche peu.
menus/       Menus + theme.tres (police, taille du texte).
game/        Votre jeu. Commencez par game.tscn.
assets/      Vos fichiers : music/, sfx/, sprites/, fonts/.
builds/      Les exports (ignorés par git).
```

## Démarrer

1. Ouvrir `game/game.tscn` : c'est la scène de jeu. Elle contient un **Placeholder** (boutons Gagner/Perdre/+10) → supprimez-le et ajoutez votre monde (`Node2D` ou `Node3D`) comme enfant de `Game`.
2. Le nom du jeu (titre du menu) : *Projet → Paramètres du projet → Application → Nom*.
3. Les crédits : modifier le texte du nœud `CreditsText` dans `menus/credits.tscn`.

## Les autoloads (utilisables depuis n'importe quel script)

| Nom | À quoi ça sert | Exemple |
|---|---|---|
| `Events` | Signaux globaux | `Events.game_over.emit(true)` |
| `Global` | Variables de la partie en cours | `Global.score += 10` |
| `Audio` | Musique et bruitages | `Audio.play_sfx(SON_SAUT)` |
| `SceneManager` | Changer de scène avec fondu | `SceneManager.change_scene(SceneManager.MAIN_MENU)` |
| | Nouvelle partie (remet `Global` à zéro) | `SceneManager.new_game()` |
| `Settings` | Sauvegarde des options | *(utilisé par le menu Options)* |

## A retenir:

**Finir la partie** (depuis le joueur, un ennemi, une zone…) :
```gdscript
Events.game_over.emit(true)   # victoire
Events.game_over.emit(false)  # défaite
```

**Score / variables globales** : ajouter la variable dans `autoloads/global.gd` et la remettre à zéro dans `reset()`. `reset()` est appelé par Jouer, Rejouer et Recommencer, **pas** entre deux niveaux : le score se garde d'un niveau à l'autre.

**Nouveau signal global** : ajouter `signal mon_signal` dans `autoloads/events.gd`, puis
`Events.mon_signal.emit()` pour l'envoyer, `Events.mon_signal.connect(_on_mon_signal)` pour l'écouter.

**Bruitage** :
```gdscript
const SON_SAUT := preload("res://assets/sfx/saut.wav")
Audio.play_sfx(SON_SAUT)        # normal
Audio.play_sfx(SON_SAUT, 0.1)   # hauteur aléatoire ±10 %, moins répétitif
```
Les boutons jouent tout seuls les sons d'interface (`assets/sfx/ui/`, sons de Kenney, CC0). Pour les changer, il suffit de remplacer les deux fichiers.

**Musique** : glisser un fichier dans la propriété `Music` de `MainMenu` ou de `Game` (inspecteur), ou `Audio.play_music(MA_MUSIQUE)`. Le changement de morceau se fait en fondu. Pour qu'elle boucle : sélectionner le fichier `.ogg` / `.mp3` → onglet *Import* → cocher *Loop* → *Réimporter*.

**Nouvelle scène / niveau** : `SceneManager.change_scene("res://game/niveau_2.tscn")`.

**Contrôles** : utiliser les actions, jamais les touches en dur (sinon le changement de touches et la manette ne marchent pas).
```gdscript
var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
if Input.is_action_just_pressed("action"):
	...
```
Actions existantes : `move_up/down/left/right` (ZQSD/WASD, croix et stick gauche), `action` (Espace / A), `pause` (Échap / Start).
Ajouter une action : *Paramètres du projet → Contrôles* (une touche **et** un bouton manette), puis l'ajouter dans `REMAPPABLE` de `autoloads/settings.gd` pour qu'elle apparaisse dans les Options.

**Pause** : il suffit que la scène contienne une instance de `menus/pause_menu.tscn` (déjà dans `game.tscn`). Un nœud qui doit continuer pendant la pause : `Process → Mode = Always`.

**Style des menus** : ouvrir `menus/theme.tres` (taille du texte, police, couleurs des boutons). La police `assets/fonts/OpenDyslexic-Regular.otf` est disponible pour l'accessibilité.

## Conseils godot:

1. **Une scène = un objet** (joueur, ennemi, pièce…), testable seule avec **F6**.
2. **Appeler vers le bas, signaler vers le haut** : un parent appelle ses enfants ; un enfant émet un signal (pas de `get_parent()`).
3. **Réglages en `@export`** (vitesse, vie, dégâts) pour les modifier dans l'inspecteur.
4. **Noms** : fichiers en `snake_case`, nœuds en `PascalCase`, code en anglais.
5. **Git** : petits commits souvent ; une seule personne modifie une même scène `.tscn` à la fois.

## Exporter

Les presets **Windows** et **Web** sont déjà dans `export_presets.cfg` (partagé via git).

1. *Éditeur → Gérer les modèles d'export → Télécharger* (une fois par PC).
2. *Projet → Exporter*, choisir le preset, *Exporter le projet* (décocher *Exporter avec le débogage*).
   - Windows → `builds/windows/game.exe` (un seul fichier, PCK intégré).
   - Web → `builds/web/` (`index.html` + fichiers).
3. **itch.io (version navigateur)** : zipper le *contenu* de `builds/web/` (pas le dossier), l'envoyer, cocher *This file will be played in the browser*, taille 1280×720 (le jeu s'adapte) avec *Fullscreen button* activé. Le bouton Quitter est caché automatiquement en Web.

➡️➡️➡️ Faites un export **dès le premier jour**, puis chaque soir!!!!!⬅️⬅️⬅️

Bonne jam ! (a mon équipe)
