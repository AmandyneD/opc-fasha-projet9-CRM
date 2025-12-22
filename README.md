Projet Salesforce – Optimisation, Tests & CI/CD

Objectif du projet

Ce projet a pour objectif de corriger, fiabiliser et optimiser une application Salesforce existante, tout en mettant en place :
	•	des tests automatisés robustes (Apex & LWC),
	•	une architecture conforme aux bonnes pratiques Salesforce,
	•	un pipeline CI/CD pour automatiser les déploiements.

Le projet se concentre principalement sur :
	•	le calcul du Net Amount des commandes,
	•	le calcul du chiffre d’affaires des comptes,
	•	la performance et la maintenabilité du code,
	•	la qualité et l’automatisation des tests.


Problèmes identifiés initialement

1. Calcul du Net Amount
	•	Calcul incorrect lors des opérations en masse (Data Loader)
	•	Recalcul non systématique
	•	Dépendance à l’ordre d’exécution Salesforce
	•	Comportement incohérent entre saisie manuelle et import

2. Calcul du chiffre d’affaires (Account)
	•	Erreurs lors de la mise à jour de comptes ayant un grand volume de commandes
	•	Triggers non bulkifiés
	•	Recalculs inutiles lors de mises à jour sans impact métier

3. Absence d’automatisation
	•	Déploiements manuels
	•	Tests non systématiques
	•	Risque de régression élevé



Solutions mises en place

Refonte du calcul du Net Amount
	•	Suppression du trigger existant défaillant
	•	Création de nouveaux triggers compatibles bulk
	•	Centralisation de la logique dans une classe de service
	•	Gestion fiable des imports Data Loader

Refonte du calcul du chiffre d’affaires
	•	Trigger bulkifié et filtré (exécution uniquement si impact métier)
	•	Centralisation du calcul dans AccountRevenueService
	•	Recalcul basé uniquement sur les commandes Activated
	•	Mise en place d’un batch dédié pour les migrations de données

Refactorisation globale
	•	Séparation claire Trigger / Handler / Service
	•	Nommage explicite des classes et méthodes
	•	Code plus lisible, maintenable et évolutif
	•	Aucune altération de la logique métier


Tests & Qualité

Tests Apex
	•	Tests unitaires du Net Amount
	•	Tests bulk (simulation Data Loader)
	•	Tests de recalcul du chiffre d’affaires
	•	Tests de batch
	•	Tests de filtrage du trigger (statut Activated uniquement)

TestDataFactory
	•	Centralisation de la création des données de test
	•	Réduction de la duplication
	•	Meilleure lisibilité et maintenabilité
	•	Adoption progressive sans risque de régression

Tests LWC (Jest)
	•	Tests du composant accountOrdersTotal
	•	Cas testés :
	•	affichage du total > 0
	•	affichage d’un message d’erreur si total = 0
	•	gestion des erreurs Apex
	•	rendu sans crash


Pipeline CI/CD – GitHub Actions

Un pipeline CI/CD a été mis en place avec GitHub Actions.

Fonctionnement

À chaque push ou merge sur la branche main, le pipeline :
	1.	Installe Salesforce CLI
	2.	Authentifie l’org Salesforce via SFDX Auth URL (secret GitHub)
	3.	Déploie les métadonnées
	4.	Exécute les tests Apex avec RunLocalTests

Environnement cible : Salesforce Developer Edition

Bénéfices
	•	Déploiement automatique
	•	Tests systématiques
	•	Sécurisation des évolutions
	•	Réduction du risque de régression


Performance

Avant
	•	Recalculs inutiles
	•	Erreurs sur gros volumes
	•	Temps de traitement élevé

Après
	•	Recalcul uniquement si impact métier
	•	Traitements bulkifiés
	•	Réduction significative du temps d’exécution
	•	Application plus stable et scalable

  Bonnes pratiques appliquées
	•	Triggers fins, sans logique métier
	•	Logique centralisée dans des services
	•	Bulkification systématique
	•	Tests automatisés fiables
	•	CI/CD simple et adapté au contexte du projet


Projet réalisé par Amandyne Desfonds
Formation Développeur Salesforce – OpenClassrooms
