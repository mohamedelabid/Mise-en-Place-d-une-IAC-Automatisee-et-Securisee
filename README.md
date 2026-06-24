#  Mise en Place d'une Infrastructure as Code (IaC) Automatisée et Sécurisée

##  Description

Ce projet a pour objectif de déployer et sécuriser automatiquement une infrastructure locale en utilisant les principes de l'Infrastructure as Code (IaC).

L'ensemble de l'environnement est entièrement automatisé afin de faciliter le déploiement, la configuration, la supervision et la sécurisation des services.

---

##  Technologies utilisées

* Terraform
* Ansible
* Docker
* Zabbix
* Fail2ban
* Telegram Bot

---

## Fonctionnalités

###  Déploiement automatique

* Création automatique de l'infrastructure.
* Automatisation des tâches d'administration.
* Configuration centralisée des services.

###  Conteneurisation

* Déploiement des services avec Docker.
* Gestion simplifiée des applications.

###  Sécurisation

* Protection des accès SSH avec Fail2ban.
* Renforcement de la sécurité des serveurs.

###  Supervision

* Surveillance des ressources système avec Zabbix.
* Suivi des performances en temps réel.

###  Notifications

* Envoi d'alertes automatiques via Telegram.

---

## 📁 Structure du projet

```text
iac-project/
│
├── terraform/
├── ansible/
├── docker/
├── Makefile
├── ansible.cfg
└── start.sh
```

---

##  Exécution du projet

### 1. Cloner le dépôt

```bash
git clone https://github.com/mohamedelabid/Mise-en-Place-d-une-IAC-Automatisee-et-Securisee.git
```

### 2. Accéder au projet

```bash
cd Mise-en-Place-d-une-IAC-Automatisee-et-Securisee
```

### 3. Lancer le script principal

```bash
./start.sh
```

---

## Auteur

**https://www.linkedin.com/in/mohamed-elabid-b4b029357/**


