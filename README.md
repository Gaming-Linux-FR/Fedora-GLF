# Fedora-GLF
[![lang-fr](https://img.shields.io/badge/lang-fr-blue.svg)]() Un script qui modifie Fedora Linux  pour le gaming et la création de contenus.

[![lang-en](https://img.shields.io/badge/lang-en-blue.svg)]() Fedora Linux setup for gaming and content creation

## Script
Pour démarrer avec le script :

1. Mettre à jour son système avec Logiciel (ou Discover). Un reboot est nécessaire et fait normalement parti du processus de mise à jour.

2. Copier-coller ce qui suit dans un terminal :
```bash
  git clone https://github.com/Gaming-Linux-FR/Fedora-GLF.git ~/Fedora-GLF \
  && cd ~/Fedora-GLF \
  && chmod +x ./fedora-GLF.sh \
  && ./fedora-GLF.sh
```
## Fonctionnalités
### Gestion des applications
- Optimisation de la vitesse du gestionnaire de paquets [DNF](https://doc.fedora-fr.org/wiki/DNF,_le_gestionnaire_de_paquets_de_Fedora)
- Installation du dépôt [Flathub](https://flathub.org/fr) si nécessaire afin d'accéder à de nombreux [flatpaks](https://flatpak.org/).
  - :warning: actuellement cassé, veuillez activer les "dépôts tiers" lors de l'installation ou lors du premier usage de Logiciels.
- Installation des dépôts [RPM Fusion](https://rpmfusion.org/) pour ouvrir l'accès à des logiciels propriétaires
- Installation de [Flatseal](https://github.com/tchx84/flatseal) pour gérer les droits des flatpaks
### Cartes graphiques
- Autodétection des cartes graphiques NVIDIA récentes (2014+) et installation des pilotes propriétaires avec [CUDA](https://fr.wikipedia.org/wiki/Compute_Unified_Device_Architecture)
- Installation de l'accélération graphique pour des codecs multimédias avec des brevets pour les cartes AMD et Intel
- Support de [ROCm](https://fr.wikipedia.org/wiki/Compute_Unified_Device_Architecture) pour les cartes graphiques AMD pour les calculs haute performance et l'IA
### Multimédia
- Installation de codecs multimédias propriétaires ou brevetés
- Installation des polices de Microsoft (Andale, Arial, Calibri, Cambria, Candara, Comic Sans MS, Consolas, Constantia, Corbel, Courier New, Georgia, Impact, Tahoma, Times New Roman, Trebuchet MS, Verdana, Webdings)
- Installation de polices (Google Roboto, Mozilla Fira, dejavu, liberation, Google Noto Emoji-sans-serif, Adobe Source, Awesome, Google Droid)
### Support matériel
- Mise à jour des [firmwares supportés par Linux](https://fwupd.org/)
- Installation de firmwares propriétaires (b43, broadcom-bt, dvb, nouveau)
- Installation d'[OpenRGB](https://openrgb.org/) pour gérer les lumières des périphériques
### Améliorations du bureau
- Installation d'outils et d'extensions pour le [bureau GNOME](https://www.gnome.org/) :
  - GNOME Tweaks pour modifier GNOME,
  - GNOME Extension Application pour gérer les extensions de GNOME,
  - Extension App Indicator pour le systray,
  - Extension GSConnect pour l'accès aux téléphones portables,
  - Extension GameMode pour indiquer son usage - :warning: actuellement cassé-,
  - Extension Caffeine pour empécher la mise en veille.
- Installation d'outils de compression (7zip, rar, ace, lha)
- Installation de [fastfetch](https://github.com/fastfetch-cli/fastfetch) pour obtenir des informations système en ligne de commande
- Installation d'un bloqueur de pubs et de malwares pour le navigateur Firefox ([uBlock Origin](https://ublockorigin.com/fr))
