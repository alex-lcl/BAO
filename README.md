# BAO
# Boîte à Outils
Le projet des boites à outils a pour but d'extraire les titres et description d'un flux RSS afin de les étiqueter et de faire de l'extraction terminologique à partir de patron. Il a également pour but l’apprentissage du langage Perl. Pour ce faire, nous avons réaliser trois boites à outils :

– BàO1 : extraction de texte (Perl, script de filtrage et de nettoyage…)
– BàO2 : Etiquetage (Treetagger, Talismane..)
– BàO3 : Extraction terminologique

Le corpus de fils RSS utilisé est celui du journal Le Monde. Il est constitué de 17 fils RSS archivés une fois par jour à 19h00 sur toute l’année 2020. Chacun des fils est accompagné de sa version « textuelle » (dite profonde) au format Lexico3, format que nous ne traiterons pas : nous nous concentrerons uniquement sur les fichiers au format xml.

Dans notre projet, nous ne traiterons pas toutes les rubriques/tous les fils RSS. Nous en avons choisi que quatre :

- la rubrique « international », numéro 3210
- la rubrique « Europe », numéro 3214
- la rubrique « société », numéro 3224
- la rubrique « idées », numéro 3232
