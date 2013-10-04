/* la liste des coups possibles */
%coups_possibles(+Plateau,+Tuile,-ListeCoupsPossibles)
coups_possibles(Plateau,Tuile,ListeCoupsPossibles):-setof(X,coup_possible(Plateau,Tuile,[_,X]),ListeCoupsPossibles).

%reussi en diagonale
compte_reussi(Joueur,[[Joueur|_],[_,Joueur|_],[_,_,Joueur,_],[_,_,_,Joueur]], 1). 
compte_reussi(Joueur,[[_,_,_,Joueur],[_,_,Joueur,_],[_,Joueur|_],[Joueur|_]], 2). 
%reussi en colonne
compte_reussi(Joueur,[[Joueur|_],[Joueur|_],[Joueur|_],[Joueur|_]], 3).	
compte_reussi(Joueur,[[_,Joueur|_],[_,Joueur|_],[_,Joueur|_],[_,Joueur|_]], 4).
compte_reussi(Joueur,[[_,_,Joueur,_],[_,_,Joueur,_],[_,_,Joueur,_],[_,_,Joueur,_]], 5).
compte_reussi(Joueur,[[_,_,_,Joueur],[_,_,_,Joueur],[_,_,_,Joueur],[_,_,_,Joueur]], 6).
%reussi en ligne
compte_reussi(Joueur, [[Joueur,Joueur,Joueur,Joueur]|_], 7).
compte_reussi(Joueur, [_,[Joueur, Joueur, Joueur, Joueur]|_], 8).
compte_reussi(Joueur, [_,_,[Joueur, Joueur, Joueur, Joueur],_], 9).
compte_reussi(Joueur, [_,_,_,[Joueur, Joueur, Joueur, Joueur]], 10).
%reussi en carre
compte_reussi(Joueur, [[Joueur, Joueur, _, _],[Joueur, Joueur, _, _]|_], 11).
compte_reussi(Joueur, [[_, Joueur, Joueur, _],[_, Joueur, Joueur, _]|_], 12).
compte_reussi(Joueur, [[_, _, Joueur, Joueur],[_, _, Joueur, Joueur]|_], 13).
compte_reussi(Joueur, [_,[Joueur, Joueur, _, _],[Joueur, Joueur, _, _]|_], 14).
compte_reussi(Joueur, [_,[_, Joueur, Joueur, _],[_, Joueur, Joueur, _]|_], 15).
compte_reussi(Joueur, [_,[_, _, Joueur, Joueur],[_, _, Joueur, Joueur]|_], 16).
compte_reussi(Joueur, [_,_,[Joueur, Joueur, _, _],[Joueur, Joueur, _, _]], 17).
compte_reussi(Joueur, [_,_,[_, Joueur, Joueur, _],[_, Joueur, Joueur, _]], 18).
compte_reussi(Joueur, [_,_,[_, _, Joueur, Joueur],[_, _, Joueur, Joueur]], 19).


%ligne_factice(Ligne,Joueur,LigneFactice)
%plateau_factice(+Plateau, +Joueur, -PlateauFactice)
/*  remplacer le plateau par joueur */
ligne_factice([[_,_]|Q],Joueur,[Joueur|R]):-!,ligne_factice(Q,Joueur,R).
ligne_factice([T|Q],Joueur,[T|R]):-ligne_factice(Q,Joueur,R).
ligne_factice([],_,[]).
plateau_factice([T|Q],Joueur,[C|R]):-ligne_factice(T,Joueur,C),plateau_factice(Q,Joueur,R).
plateau_factice([],_,[]).


%evaluer(+Plateau, Joueur -Valeur)
/*  fonction d'evaluation */
evaluer(Plateau,Joueur,Joueur,TuilePrecedente,999):-victoire(Joueur,TuilePrecedente,Plateau),!.
evaluer(Plateau,Joueur,JoueurQuiJoue,TuilePrecedente,-999):-change_joueur(Joueur,JoueurQuiJoue),victoire(Joueur,TuilePrecedente,Plateau),!.
evaluer(Plateau, Joueur, _,_, Valeur):-
	plateau_factice(Plateau, Joueur, PlateauFactice1),
	findall(X, compte_reussi(Joueur, PlateauFactice1, X), ListeJoueur),
	length(ListeJoueur, SommeJoueur),
	change_joueur(Joueur, AutreJoueur),
	plateau_factice(Plateau, AutreJoueur, PlateauFactice2),
	findall(Y, compte_reussi(AutreJoueur, PlateauFactice2, Y), ListeAutreJoueur),
	length(ListeAutreJoueur, SommeAutreJoueur),
	Valeur is SommeJoueur - SommeAutreJoueur.

max(V1,V2,C1,_,V1,C1):-V1 > V2,!.
max(_,V2,_,C2,V2,C2).
min(V1,V2,C1,_,V1,C1):-V1 < V2,!.
min(_,V2,_,C2,V2,C2).


%meilleur_coup(+Plateau,+TuilePrecedente, -Coup)
meilleur_coup(Plateau, TuilePrecedente, Joueur, JoueurQuiJoue, Profondeur, MC, MV):-
	coups_possibles(Plateau, TuilePrecedente, ListeCoups),
	Pr2 is Profondeur-1,
	minmax(Plateau, TuilePrecedente, Joueur, JoueurQuiJoue, Pr2, ListeCoups, MC, MV).

/*  tester si un plateau est un feuille(etat gagant, perdu, ou prod = 0) */
feuille(_,0,_,_):-!.
feuille(Plateau,_,TuilePrecedente,Joueur):-victoire(Joueur,TuilePrecedente,Plateau).

choisir_min_max(Joueur, JoueurQuiJoue, MC1, MV1, MC2, MV2, MC, MV):-
	Joueur == JoueurQuiJoue ->
		max(MV1, MV2, MC1, MC2, MV, MC)
	;
		min(MV1, MV2, MC1, MC2, MV, MC).


minmax(Plateau,_,Joueur,JoueurQuiJoue,Profondeur,[C1],C1,MV):-!,
	jouer_coup(Plateau, [Joueur,C1], NouveauPlateau),
	(
	feuille(NouveauPlateau,Profondeur,C1,Joueur) -> %(si gagnant, perdant ou profondeur=0)
		evaluer(NouveauPlateau, Joueur,JoueurQuiJoue,C1,MV)
	; %(sinon)
		change_joueur(Joueur, Adversaire),
		meilleur_coup(NouveauPlateau, C1, Adversaire,JoueurQuiJoue, Profondeur,_, MV)
	).

minmax(Plateau, TuilePrecedente, Joueur, JoueurQuiJoue, Profondeur, [C1|Autrescoups], MC, MV):-
	jouer_coup(Plateau, [Joueur,C1], NouveauPlateau),
	(feuille(NouveauPlateau,Profondeur,C1,Joueur) -> %(si gagnant, perdant ou profondeur=0)
		evaluer(NouveauPlateau, Joueur,JoueurQuiJoue,C1,V1)
	; %(sinon)
		change_joueur(Joueur, Adversaire),
		meilleur_coup(NouveauPlateau, C1, Adversaire,JoueurQuiJoue, Profondeur, _, V1)
	),
	minmax(Plateau, TuilePrecedente, Joueur, JoueurQuiJoue, Profondeur, Autrescoups, C2, V2),
	choisir_min_max(Joueur, JoueurQuiJoue, C1, V1, C2, V2, MC, MV).


boucle_jeu_IA_humain(Plateau, Joueur, Vainqueur,TuilePrecedente):-
	affiche_plateau(Plateau),
	write('C''est au tour du joueur '),write(Joueur),write(' de jouer :'),nl,
	(Joueur == j2 ->
		meilleur_coup(Plateau,TuilePrecedente,j2,j2,3,Tuile,_),write('Coup joue par IA:'),write(Tuile),nl
	;
		read(Tuile)),
	Coup = [Joueur,Tuile],
	coup_possible(Plateau,TuilePrecedente,Coup)->
		jouer_coup(Plateau, Coup, NouveauPlateau),
		(
			victoire(Joueur, Tuile, NouveauPlateau)->
				Vainqueur = Joueur,
				affiche_plateau(NouveauPlateau)
			;
				change_joueur(Joueur, NouveauJoueur),
				boucle_jeu_IA_humain(NouveauPlateau, NouveauJoueur, Vainqueur,Tuile)
		)
	;
		nl,write('Tuile incorrecte'),nl,nl,
		boucle_jeu_IA_humain(Plateau, Joueur, Vainqueur,TuilePrecedente).

humainIA(Vainqueur):-
plateau_depart(Plateau),
boucle_jeu_IA_humain(Plateau, j1, Vainqueur,[]),
write('Le vainqueur est : '), write(Vainqueur),!.

ia_ia(Vainqueur):-
plateau_depart(Plateau),
boucle_jeu_IA_IA(Plateau, j1, Vainqueur,[]),
write('Le vainqueur est : '), write(Vainqueur),!.

boucle_jeu_IA_IA(Plateau, Joueur, Vainqueur,TuilePrecedente):-
	affiche_plateau(Plateau),
	write('C''est au tour du joueur '),write(Joueur),write(' de jouer :'),nl,
	meilleur_coup(Plateau,TuilePrecedente,Joueur,Joueur,5,Tuile,_),
		Coup=[Joueur,Tuile],write('Coup :'),write(Tuile),nl,
	coup_possible(Plateau,TuilePrecedente,Coup)->
		jouer_coup(Plateau, Coup, NouveauPlateau),
		(
			victoire(Joueur, Tuile, NouveauPlateau)->
				Vainqueur = Joueur,
				affiche_plateau(NouveauPlateau)
			;
				change_joueur(Joueur, NouveauJoueur),
				boucle_jeu_IA_IA(NouveauPlateau, NouveauJoueur, Vainqueur,Tuile)
		)
	;
		nl,write('Tuile incorrecte'),nl,
		boucle_jeu_IA_IA(Plateau, Joueur, Vainqueur,TuilePrecedente).

