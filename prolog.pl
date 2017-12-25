/*
Naudion
Melvin
p1508533

PROJET
*/

/* 1) Représentation du problème de planification d'examens */

inscrits(lif1,[marc,jean,paul,pierre,anne,sophie,thierry,jacques]).
inscrits(lif2,[anne,pierre,paul,emilie,antoine,juliette]).
inscrits(lif3,[juliette,antoine,thierry,jean,edouard]).
inscrits(lif4,[andre,olivier,beatrice]).
inscrits(lif5,[edouard,paul,pierre,emilie]).
inscrits(lif6,[andre,beatrice,amelie]).

variables([lif1,lif2,lif3,lif4,lif5,lif6]).
valeurs([1,2,3,4,5,6,7,8,9,10]).

/* Renvoi le domaines des variables et des valeurs */
/* sous la forme : domaines([Element1|variables],valeurs) */

domaines(S):- variables(ListVal),domaines(S,ListVal).
domaines([],[]).
domaines([A|S],[B|Var]):- valeurs(ListVal), append([B],[ListVal],A),domaines(S,Var).

/* TEST
?- domaines(S), write(S).
[[lif1,[1,2,3,4,5,6,7,8,9,10]],[lif2,[1,2,3,4,5,6,7,8,9,10]],[lif3,[1,2,3,4,5,6,7,8,9,10]],[lif4,[1,2,3,4,5,6,7,8,9,10]],[lif5,[1,2,3,4,5,6,7,8,9,10]],[lif6,[1,2,3,4,5,6,7,8,9,10]]]
S = [[lif1, [1, 2, 3, 4, 5, 6|...]], [lif2, [1, 2, 3, 4, 5|...]], [lif3, [1, 2, 3, 4|...]], [lif4, [1, 2, 3|...]], [lif5, [1, 2|...]], [lif6, [1|...]]].
*/


/* Appel à ce predicat pour savoir si un éleve n'appartient pas à 2 matieres de la meme sequence*/
elevpareil([],_).
elevpareil([X|X1],X2):-not(member(X,X2)),elevpareil(X1,X2).

/* Permet de regarder si premier eleve de X1, n'appartient pas à X2 */
consistants([X1,X],[X2,X]):-inscrits(X1,Elev1), inscrits(X2,Elev2), elevpareil(Elev1,Elev2).
consistants([_,X],[_,Y]):- X =\= Y.

/* TEST
?- consistants([LIF1,1],[LIF2,3]).
true.
?- consistants([LIF1,1],[LIF2,3]).
true.
*/


/* 2) Resolution par méthode "générer et tester"*/
/* Genere une solution possible puis test si elles consistantes entres elles, si elles ne le sont pas genere une autre solution recursivement etc*/
/* Nouvelle version cette fois avec consistants3, bien plus rapide quand on utilise time */

genereEtTeste(Solution) :- domaines(Domaine), genereEtTeste(Domaine,Solution), consistants3(Solution).
genereEtTeste([],[]).
genereEtTeste([[Matiere,[Sequence|_]]|Domaine],[[Matiere,Sequence]|Solution]) :- genereEtTeste(Domaine,Solution).
genereEtTeste([[Matiere,[_|Sequence]]|Domaine],Solution) :- genereEtTeste([[Matiere,Sequence]|Domaine],Solution).

/*Appel à ce predicat, qui recupere en parametre la matiere, ainsi que le chiffre de sa sequence recursivement*/
consistants3([_]).
consistants3([Matiere|L]) :- consistants2(Matiere,L) , consistants3(L).

/* TEST
?- genereEtTeste(Sol).
Sol = [[lif1, 1], [lif2, 2], [lif3, 3], [lif4, 1], [lif5, 4], [lif6, 2]]
*/




/* 3) Resolution par méthode "retour arriere" */
/*Comme genereETeste, sauf qu'on test si c'est consistant avec le reste au fur et à mesure*/

retourArriere(Sol) :- domaines(Dom), retourArriere(Dom,Sol).
retourArriere([],[]).
retourArriere([[Matiere,[X|_]]|Dom],[[Matiere,X]|Sol]) :- retourArriere(Dom,Sol), consistants2([Matiere,X],Sol), !.
retourArriere([[Matiere,[_|X]]|Dom],Sol) :- retourArriere([[Matiere,X]|Dom],Sol).

/*Appel à ce predicat, pour savoir si une matiere est consistante avec toute une autre liste de matiere. Si X consistant avec ce qu'il y a dans la liste*/
consistants2(_,[]).
consistants2(X,[Matiere|L]) :- consistants(X,Matiere), consistants2(X,L).
/*Genere les solutions possibles, pour que toutes les listes soient consistantes entre elles*/
/*Dans ce predicat, l'ajout de la variable X permet de verifier qu'une affectation n'a aucun conflit dans la liste deja crée*/

/* TEST
?- retourArriere(S).
S = [[lif1, 4], [lif2, 3], [lif3, 2], [lif4, 2], [lif5, 1], [lif6, 1]].
*/




/* 4) Resolution par méthode "filtrage"*/

filtrage(Sol) :- domaines(Dom) , filtrage(Dom,Sol).

filtrage([],[]).
filtrage([[LIF,[X|_]]|Dom],[[LIF,X]|Sol]) :-  filtrage2([LIF,X],Dom,Dom2), filtrage(Dom2,Sol), !. /*Pour eviter un false, en generation*/

filtrage2(_,[],[]).
filtrage2([LIF,X],[[LIF2,L]|Dom],[[LIF2,L2]|Dom1]) :- not(consistants([LIF,X],[LIF2,X])), delete(L,X,L2), filtrage2([LIF,X],Dom,Dom1),!.
filtrage2([LIF,X],[[LIF2,L]|Dom],[[LIF2,L]|Dom1]) :-  filtrage2([LIF,X],Dom,Dom1).

/* TEST
?- filtrage(S).
S = [[lif1, 1], [lif2, 2], [lif3, 3], [lif4, 2], [lif5, 4], [lif6, 3]].
*/




/* 5) Resolution avec affectation de la variable la plus contrainte */





/* 6) Comparaison des différentes méthodes

?- time(findall(Sol,retourArriere(Sol),R)).
% 4,524 inferences, 0.000 CPU in 0.002 seconds (0% CPU, Infinite Lips)
R = [[[lif1, 4], [lif2, 3], [lif3, 2], [lif4, 2], [lif5, 1], [lif6, 1]]].

Pour le predicat genereEtTeste
?- time(findall(Sol,genereEtTeste(Sol),R)).
% 52,638,509 inferences, 3.588 CPU in 3.654 seconds (98% CPU, 14670616 Lips)

Pour le predicat filtrage
?- time(findall(Sol,filt(Sol),R)).
% 635 inferences, 0.000 CPU in 0.001 seconds (0% CPU, Infinite Lips)

On peut donc en conclure que la méthode filtrage est bien plus rapide que genereEtTeste et un peu plus rapide que retourArriere
(Neanmoins, je n'ai pas pu verifier pour la méthode heuristique)
*/




/* 7) Application à un autre problème */

/*Les préférences des stagiaires*/

preferences(s1,[1,e2],[2,e4],[2,e6]).
preferences(s2,[1,e2],[1,e5],[2,e6]).
preferences(s3,[1,e1],[2,e3],[3,e6]).
preferences(s4,[1,e6],[2,e3]).
preferences(s5,[1,e2],[2,e1],[3,e5]).
preferences(s6,[1,e6],[2,e4],[2,e2],[3,e5],[4,e1]).
