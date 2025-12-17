# Fasha - Projet 9 - Optimisation CRM Salesforce

Objectif : optimiser une application Salesforce existante (performance, code legacy, fiabilité), corriger les bugs critiques (triggers / champs calculés / LWC), et préparer l’intégration CI/CD.

## Tests Apex (CLI)

sf apex run test --test-level RunLocalTests --result-format human --wait 10 --target-org devOrgProjet9

## Tests LWC (Jest)

npm install --legacy-peer-deps  
npm run test:unit